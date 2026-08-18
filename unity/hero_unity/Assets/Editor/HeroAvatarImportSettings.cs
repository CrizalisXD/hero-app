// HeroAvatarImportSettings.cs
// ────────────────────────────────────────────────────────────────────────────
// Import rules for the modular hero avatar, applied BY PATH so that dropping a
// new FBX into Assets/Resources/Avatar/ is all it takes — no manual clicking in
// the inspector, and no .meta drift between machines.
//
// Layout the rules assume:
//   Assets/Resources/Avatar/Male|Female/Body_*.fbx    → humanoid, own avatar
//   Assets/Resources/Avatar/Male|Female/Top_*|Bottom_*|Shoes_*|Hair_*.fbx
//                                                    → generic rig, bones kept
//   Assets/Resources/Avatar/Animations/anim_*.fbx     → humanoid clips only
//   Assets/Resources/Avatar/Skins/Male|Female/*.png   → compressed skin maps
//
// Why the rigs differ: the wardrobe meshes are skinned to the SAME MakeHuman
// skeleton as the body, so at runtime we just re-point their bone arrays at the
// body's bones (AvatarWardrobe). That needs the real bone hierarchy, hence
// Generic + optimizeGameObjects = false. The Mixamo animation FBX use a
// different skeleton, so they are imported as Humanoid and retarget onto the
// body's humanoid avatar.
// ────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public class HeroAvatarImportSettings : AssetPostprocessor
{
    private const string Root = "Assets/Resources/Avatar/";
    private const string AnimationsDir = Root + "Animations/";
    private const string SkinsDir = Root + "Skins/";

    /// Albedo maps the FBX materials reference by file name. They live OUTSIDE
    /// Resources on purpose: the materials pull them in as dependencies, so
    /// putting them in Resources would ship them twice.
    private const string TexturesDir = "Assets/Textures/";

    /// Flip on to see exactly what each FBX declares about its materials.
    private const bool VerboseMaterials = true;

    /// Bump when the rules below change: Unity re-imports assets whose
    /// postprocessor version moved, and without that a logic fix quietly does
    /// nothing until someone reimports by hand.
    public override uint GetVersion() => 6;

    private string NormalizedPath => assetPath.Replace('\\', '/');
    private bool InAvatarRoot => NormalizedPath.StartsWith(Root);
    private bool IsAnimationAsset => NormalizedPath.StartsWith(AnimationsDir);

    private void OnPreprocessModel()
    {
        if (!InAvatarRoot) return;

        var importer = (ModelImporter)assetImporter;
        var file = Path.GetFileNameWithoutExtension(assetPath);

        // Scene junk that would otherwise ride along into the app build.
        importer.importCameras = false;
        importer.importLights = false;
        importer.importConstraints = false;

        // Visibility and blend shapes stay ON: both carry authoring decisions
        // made in Blender (hidden geometry under garments, corrective shapes
        // for how a garment sits). Switching them off silently discards that
        // work at import — the fitting is done in the source file, and Unity's
        // job is to bring it in unchanged, not to re-derive it.
        importer.importVisibility = true;
        importer.importBlendShapes = true;
        // Only on first import: a scale override written by
        // HeroAvatarBuilder.FixBodyScale must survive later reimports, or a
        // model exported in the wrong units would snap back to being 100×
        // off every time anything in the folder changes.
        if (importer.importSettingsMissing) importer.useFileScale = true;

        // Mesh data is only ever rendered, never read back on the CPU.
        importer.isReadable = false;
        // Keep compression off: these meshes are skinned, and quantised weights
        // show up as pinching around the shoulders/hips on a 3-bone character.
        importer.meshCompression = ModelImporterMeshCompression.Off;

        if (IsAnimationAsset)
        {
            importer.animationType = ModelImporterAnimationType.Human;
            importer.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
            importer.importAnimation = true;
            // Animation-only FBX carry a placeholder mesh/material we never use.
            importer.materialImportMode = ModelImporterMaterialImportMode.None;
            return;
        }

        importer.importAnimation = false;
        // ImportViaMaterialDescription (not the legacy ImportStandard) is what
        // routes materials through OnPostprocessMaterialDescription — both
        // URP's own converter and the texture fix-up below depend on it.
        importer.materialImportMode = ModelImporterMaterialImportMode.ImportViaMaterialDescription;
        importer.materialLocation = ModelImporterMaterialLocation.InPrefab;
        // Bone GameObjects must survive: the wardrobe matches them BY NAME.
        importer.optimizeGameObjects = false;

        if (file.StartsWith("Body_"))
        {
            importer.animationType = ModelImporterAnimationType.Human;
            importer.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
        }
        else
        {
            // Wardrobe piece — no avatar of its own, it borrows the body's.
            importer.animationType = ModelImporterAnimationType.Generic;
        }
    }

    private void OnPreprocessAnimation()
    {
        if (!IsAnimationAsset) return;

        var importer = (ModelImporter)assetImporter;
        var clips = importer.defaultClipAnimations;
        if (clips == null || clips.Length == 0) return;

        // Idle is the resting state and must loop; emotes are one-shots that
        // AvatarAnimation cross-fades back out of.
        var file = Path.GetFileNameWithoutExtension(assetPath);
        var loop = file.StartsWith("anim_idle");
        for (var i = 0; i < clips.Length; i++)
        {
            // Every Mixamo export calls its clip "mixamo.com"; name it after the
            // file so logs and lookups are readable.
            clips[i].name = clips.Length == 1 ? file : $"{file}_{i + 1:00}";
            clips[i].loopTime = loop;
            clips[i].lockRootHeightY = true;
            clips[i].keepOriginalPositionY = true;
        }

        importer.clipAnimations = clips;
    }

    private static Texture FindTextureByName(string name)
    {
        if (string.IsNullOrEmpty(name)) return null;

        foreach (var guid in AssetDatabase.FindAssets($"{name} t:Texture"))
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            if (!string.Equals(Path.GetFileNameWithoutExtension(path), name,
                               System.StringComparison.OrdinalIgnoreCase)) continue;
            return AssetDatabase.LoadAssetAtPath<Texture>(path);
        }

        return null;
    }

    /// Gives every imported material its albedo map, and makes the alpha-cut
    /// pieces actually cut.
    ///
    /// Unity cannot resolve these textures on its own: the FBX record them as
    /// paths into a `<model>.fbm` folder that only existed on the machine they
    /// were exported from, and Unity's fallback search only walks `Textures`
    /// folders beside or above the model. The result was every material plain
    /// white — which is how the eyes, brows and lashes ended up as blank
    /// shapes on the device. `OnPostprocessMaterialDescription` would be the
    /// tidy hook for this, but Unity never calls it for these assets, so the
    /// texture NAMES are read straight out of the FBX (they are plain ASCII in
    /// the binary) and matched against the project by name.
    private void OnPostprocessModel(GameObject root)
    {
        if (!InAvatarRoot || IsAnimationAsset) return;

        var referenced = TexturesReferencedBy(assetPath);
        var assigned = AssignTextures(root, referenced);

        foreach (var renderer in root.GetComponentsInChildren<Renderer>(true))
        foreach (var material in renderer.sharedMaterials)
        {
            if (material == null) continue;

            var name = (material.name + " " + renderer.name).ToLowerInvariant();

            if (!HasAlbedo(material))
            {
                assigned.TryGetValue(material, out var texture);
                if (texture != null)
                {
                    if (material.HasProperty("_BaseMap")) material.SetTexture("_BaseMap", texture);
                    if (material.HasProperty("_MainTex")) material.SetTexture("_MainTex", texture);
                    // The imported tint (grey, or flat black on the lashes)
                    // would multiply the texture away.
                    if (material.HasProperty("_BaseColor")) material.SetColor("_BaseColor", Color.white);
                    if (material.HasProperty("_Color")) material.SetColor("_Color", Color.white);

                    if (VerboseMaterials)
                        Debug.Log($"[hero/mat] {Path.GetFileName(assetPath)}: '{material.name}' <- {texture.name}");
                }
                else if (VerboseMaterials)
                {
                    Debug.LogWarning($"[hero/mat] {Path.GetFileName(assetPath)}: '{material.name}' has no texture");
                }
            }

            // Brows, lashes and hair are alpha cards. Left opaque they render
            // as solid rectangles glued to the head. Only textured ones though:
            // a lash asset that is plain black geometry has no alpha to cut,
            // and clipping it would just risk punching holes in it.
            var cutout = (name.Contains("eyebrow") || name.Contains("eyelash")
                       || name.Contains("hair") || name.Contains("braid")
                       || name.Contains("bangs"))
                      && HasAlbedo(material);
            if (!cutout) continue;

            material.SetFloat("_AlphaClip", 1f);
            material.SetFloat("_Cutoff", 0.4f);
            material.EnableKeyword("_ALPHATEST_ON");
            material.renderQueue = 2450; // AlphaTest
        }
    }

    private static bool HasAlbedo(Material material)
    {
        if (material.HasProperty("_BaseMap") && material.GetTexture("_BaseMap") != null) return true;
        return material.HasProperty("_MainTex") && material.GetTexture("_MainTex") != null;
    }

    /// Texture file names live in the FBX as plain ASCII, so they can be read
    /// without an FBX SDK.
    private static List<Texture> TexturesReferencedBy(string path)
    {
        var found = new List<Texture>();
        var seen = new HashSet<string>();

        string ascii;
        try { ascii = System.Text.Encoding.ASCII.GetString(File.ReadAllBytes(path)); }
        catch { return found; }

        foreach (Match match in Regex.Matches(ascii, @"[A-Za-z0-9_\-.]+\.(?:png|jpg|jpeg|tga)"))
        {
            var name = Path.GetFileNameWithoutExtension(match.Value);
            if (!seen.Add(name.ToLowerInvariant())) continue;

            var texture = FindTextureByName(name);
            if (texture != null) found.Add(texture);
        }

        return found;
    }

    /// Hands out the textures of a whole file at once, one texture per material.
    ///
    /// Deciding per material in isolation does not work on a file that holds
    /// the entire wardrobe: the polo shirt and the knitted sweater both look
    /// like a decent match for `shirt-knit`, so whichever is processed first
    /// takes it and the other ends up bare (or, worse, wearing the skin map).
    /// Scoring every pair first and then assigning best-match-first, with each
    /// texture used once, resolves those fights the way a human would.
    private static Dictionary<Material, Texture> AssignTextures(GameObject root, List<Texture> textures)
    {
        var result = new Dictionary<Material, Texture>();
        if (textures.Count == 0) return result;

        var materials = new List<Material>();
        foreach (var renderer in root.GetComponentsInChildren<Renderer>(true))
        foreach (var material in renderer.sharedMaterials)
        {
            if (material != null && !HasAlbedo(material) && !materials.Contains(material))
                materials.Add(material);
        }

        var candidates = new List<(Material material, Texture texture, int score)>();
        foreach (var material in materials)
        {
            var key = material.name.ToLowerInvariant();

            // An override may name a texture the FBX never mentions (the eye
            // map lives in the project, not in the body file), so resolve it
            // against the whole project rather than the file's own list.
            var forced = OverrideTextureFor(key);
            if (forced != null)
            {
                var texture = FindTextureByName(forced);
                if (texture != null)
                {
                    result[material] = texture;
                    continue;
                }
            }

            foreach (var texture in textures)
            {
                var score = Score(key, texture.name);
                if (score > 0) candidates.Add((material, texture, score));
            }
        }

        candidates.Sort((a, b) => b.score.CompareTo(a.score));

        var takenTextures = new HashSet<Texture>();
        foreach (var (material, texture, _) in candidates)
        {
            if (result.ContainsKey(material)) continue;
            // Skin is the exception that may be shared: the body, the eyes and
            // any part baked into the same map all legitimately use it.
            if (takenTextures.Contains(texture) && !IsSkinMap(texture.name)) continue;

            result[material] = texture;
            takenTextures.Add(texture);
        }

        return result;
    }

    /// How well a texture name fits a material name. 0 means "no reason to
    /// think they belong together".
    /// Pairs the name matching cannot possibly get right, because the artist's
    /// object name and the texture name share nothing (`toigo_fisherman_sweater`
    /// is textured by `shirt-knit`). Substring match on the material name.
    private static readonly (string material, string texture)[] Overrides =
    {
        // Eyeballs. The body FBX declares no map for them, so without this they
        // inherit the skin texture and the hero ends up with flesh-coloured
        // eyes — which reads as "no eyes at all" on a phone screen.
        ("high-poly", "brown_eye"),
        ("fisherman_sweater", "shirt-knit"),
        ("polo_shirt", "polo_base_color"),
        ("elvs_braided_rows", "mh_cornrowstex1"),
        ("casualsuit03", "male_casualsuit03_diffuse"),
        ("male_suit_3", "newsuit3"),
        ("culturalibre_hair_02", "male02_diffuse_black"),
        ("culturalibre_hair_05", "hair_05"),
    };

    private static string OverrideTextureFor(string materialKey)
    {
        foreach (var (material, texture) in Overrides)
            if (materialKey.Contains(material)) return texture;

        return null;
    }

    private static int Score(string materialKey, string textureName)
    {
        var forced = OverrideTextureFor(materialKey);
        if (forced != null) return textureName.ToLowerInvariant() == forced ? 1000 : 0;

        var isBody = materialKey.Contains("body") || materialKey.Contains("skin")
                  || materialKey.Contains("high-poly");
        var isSkin = IsSkinMap(textureName);

        // Skin maps go on skin, never on clothes — a flesh-coloured polo shirt
        // is what that mix-up looks like.
        if (isSkin != isBody) return 0;
        if (isSkin && isBody) return 100;

        var score = 0;
        foreach (var word in Regex.Split(textureName.ToLowerInvariant(), @"[^a-z0-9]+"))
        {
            if (word.Length < 4 || Generic.Contains(word)) continue;
            if (materialKey.Contains(word)) score += word.Length;
        }

        // `trousers_1` vs `trousers_2`: the words tie, the number decides.
        var materialDigits = Regex.Match(materialKey, @"(\d+)\s*$");
        var textureDigits = Regex.Match(textureName, @"(\d+)");
        if (score > 0 && materialDigits.Success && textureDigits.Success &&
            int.TryParse(materialDigits.Groups[1].Value, out var a) &&
            int.TryParse(textureDigits.Groups[1].Value, out var b) && a == b)
        {
            score += 5;
        }

        return score;
    }

    /// Wardrobe pieces ship a single map, so the choice is trivial. The body
    /// carries several (eyes, brows, lashes) and is matched by name — its skin
    /// map is applied at runtime instead, from the skin-tone the player picked.
    private static Texture PickTexture(List<Texture> textures, string materialKey)
    {
        if (textures.Count == 0) return null;

        foreach (var texture in textures)
        {
            var name = texture.name.ToLowerInvariant();
            if (materialKey.Contains("eyebrow") && name.Contains("eyebrow")) return texture;
            if (materialKey.Contains("eyelash") && name.Contains("eyelash")) return texture;
        }

        // Some lash assets (the male `mind_eyelashes_04`) are plain black
        // geometry with no map at all — never hand them the eye texture.
        if (materialKey.Contains("eyelash")) return null;

        // "Human.high-poly" is MakeHuman's name for the eyeballs.
        if (materialKey.Contains("high-poly") || materialKey.Contains("eye"))
        {
            foreach (var texture in textures)
            {
                var name = texture.name.ToLowerInvariant();
                if (name.Contains("eye") && !name.Contains("eyebrow") && !name.Contains("eyelash"))
                    return texture;
            }
        }

        // The body wears the skin map, and only the body: handing a garment the
        // skin texture is what turned the polo shirt flesh-coloured.
        var isBody = materialKey.Contains("body") || materialKey.Contains("skin");
        foreach (var texture in textures)
        {
            if (IsSkinMap(texture.name) == isBody && isBody) return texture;
        }

        if (textures.Count == 1) return IsSkinMap(textures[0].name) ? null : textures[0];

        // Otherwise match on shared words — the exporter names the material and
        // its texture after the same asset ("…male_polo_shirt" ↔ "Polo_Base…").
        Texture best = null;
        var bestScore = 0;

        foreach (var texture in textures)
        {
            if (IsSkinMap(texture.name)) continue;

            var score = 0;
            foreach (var word in Regex.Split(texture.name.ToLowerInvariant(), @"[^a-z0-9]+"))
            {
                if (word.Length < 4) continue;               // "01", "tex", "png"
                if (Generic.Contains(word)) continue;        // "male" matches everything
                if (materialKey.Contains(word)) score += word.Length;
            }

            if (score <= bestScore) continue;
            bestScore = score;
            best = texture;
        }

        // No convincing match: leave the material untextured. A default grey
        // garment reads as "not finished yet"; a garment wearing somebody's
        // skin map reads as a bug — and hides which asset is actually missing.
        return best;
    }

    /// Words that appear in half the asset names and so carry no signal.
    private static readonly HashSet<string> Generic = new()
    {
        "male", "female", "human", "diffuse", "color", "colour", "base",
        "texture", "tex", "mask", "norm", "normal", "young", "light", "dark",
    };

    private static bool IsSkinMap(string name)
    {
        var n = name.ToLowerInvariant();
        return n.Contains("skin") || n.Contains("lightskinned") || n.Contains("eyeliner");
    }

    private void OnPreprocessTexture()
    {
        if (!NormalizedPath.StartsWith(TexturesDir))
        {
            if (!NormalizedPath.StartsWith(SkinsDir)) return;
            ConfigureSkin();
            return;
        }

        // Model textures: keep the alpha channel — the brow/lash/hair cards are
        // nothing but alpha — and cap the size so the export stays lean.
        var modelTexture = (TextureImporter)assetImporter;
        modelTexture.maxTextureSize = 2048;
        modelTexture.textureCompression = TextureImporterCompression.Compressed;
        modelTexture.mipmapEnabled = true;
        modelTexture.streamingMipmaps = true;
        modelTexture.alphaIsTransparency = true;
    }

    private void ConfigureSkin()
    {
        var importer = (TextureImporter)assetImporter;
        // Source skins are 4K photo scans — far more than a 300 px-tall hero on
        // a phone screen can show, and they would dominate the export size.
        importer.maxTextureSize = 2048;
        importer.textureCompression = TextureImporterCompression.Compressed;
        importer.mipmapEnabled = true;
        importer.streamingMipmaps = true;
        importer.alphaSource = TextureImporterAlphaSource.None;
    }
}
