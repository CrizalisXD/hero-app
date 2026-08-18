// AvatarWardrobe.cs
// ────────────────────────────────────────────────────────────────────────────
// Builds the hero out of the modular pieces exported from MakeHuman/Blender:
// one skinned body plus hair / top / bottom / shoes that are skinned to the
// SAME skeleton. Nothing is placed in the scene by hand — everything is loaded
// from Resources by id, so a wardrobe change is a message from Flutter, not a
// re-export of the Unity project.
//
// The trick that makes it modular: a clothing FBX ships with its own copy of
// the skeleton. Instantiating it as-is would give you a second, unanimated
// rig. Instead we keep only its SkinnedMeshRenderers and re-point their `bones`
// arrays at the BODY's bones (matched by name), so one Animator drives the
// hero and everything he wears.
//
// Resource layout (see HeroAvatarImportSettings):
//   Avatar/{Male|Female}/Body_{Gender}_01
//   Avatar/{Male|Female}/{Top|Bottom|Shoes|Hair}_{Gender}_{NN}
//   Avatar/Skins/{Male|Female}/skin_{NN}
// ────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;

public enum WardrobeSlot
{
    Hair,
    Top,
    Bottom,
    Shoes,
}

[DisallowMultipleComponent]
public class AvatarWardrobe : MonoBehaviour
{
    /// Value the app sends for "nothing in this slot" (mirrors
    /// `kAvatarSlotEmpty` on the Dart side).
    public const string Empty = "default";

    [Header("Defaults")]
    [SerializeField] private string defaultGender = "male";
    [SerializeField] private string defaultSkin = "skin_01";


    [Header("Debug")]
    [Tooltip("Log every resolve/equip step. Leave on until the wardrobe has " +
             "been seen working on a device — Resources misses are silent.")]
    [SerializeField] private bool verbose = true;

    /// Root of the currently spawned body, or null before the first build.
    public GameObject Body { get; private set; }

    /// Animator of the current body (humanoid avatar comes from the FBX).
    public Animator Animator { get; private set; }

    /// Raised after the body was (re)spawned, so framing/animation can re-bind.
    public event System.Action BodyRebuilt;

    private string _gender;
    private string _skin;
    private string _hairColor;

    // Bones of the current body, by name — the remap table for worn items.
    private readonly Dictionary<string, Transform> _bones = new();

    // A worn piece can end up in two places: skinned meshes go under a holder
    // on the body, rigid ones (most hair) are parented straight to a bone. Both
    // have to be tracked or unequipping would leave the rigid half behind.
    private readonly Dictionary<WardrobeSlot, List<GameObject>> _worn = new();
    private readonly Dictionary<WardrobeSlot, string> _wornIds = new();
    private SkinnedMeshRenderer _skinRenderer;

    private static readonly Regex TrailingIndex = new(@"(\d+)\s*$", RegexOptions.Compiled);
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int MainTex = Shader.PropertyToID("_MainTex");
    private static readonly int BaseColor = Shader.PropertyToID("_BaseColor");
    private static readonly int LegacyColor = Shader.PropertyToID("_Color");

    // ── Public API ──────────────────────────────────────────────────────────

    /// Spawns the default hero. Safe to call twice — it rebuilds.
    public void EnsureBuilt()
    {
        if (Body == null) SetGender(_gender ?? defaultGender);
    }

    /// Swapping gender swaps the base mesh AND the skeleton, so everything
    /// worn has to be re-equipped onto the new bones.
    public void SetGender(string gender)
    {
        gender = Normalize(gender) == "female" ? "female" : "male";
        if (Body != null && gender == _gender) return;

        var previous = new Dictionary<WardrobeSlot, string>(_wornIds);
        _gender = gender;
        BuildBody();

        foreach (var kv in previous) Equip(kv.Key, kv.Value);
        ApplySkin(_skin ?? defaultSkin);
        ApplyHairColor(_hairColor);
    }

    /// Puts `id` in `slot`. `null`/empty/"default" clears the slot.
    public void Equip(WardrobeSlot slot, string id)
    {
        EnsureBuilt();

        id = Normalize(id);
        Unequip(slot);
        _wornIds[slot] = id;

        if (string.IsNullOrEmpty(id) || id == Empty) return;

        // Packs come in two shapes: one FBX per garment, or one FBX holding the
        // whole wardrobe. The map knows which; everything downstream is the
        // same, because in both cases what gets worn is a skinned mesh that is
        // re-pointed at the body's bones.
        var mapped = AvatarCatalogMap.Resolve(_gender, SlotKey(slot), IndexOf(id) ?? 0);
        if (!mapped.IsEmpty)
        {
            var master = Resources.Load<GameObject>($"Avatar/{Capitalize(_gender)}/{mapped.File}");
            if (master != null)
            {
                Wear(slot, master, mapped.Mesh);
                return;
            }

            Debug.LogWarning($"[wardrobe] wardrobe file '{mapped.File}' missing for {slot}='{id}'");
        }

        var prefab = LoadItem(slot, id);
        if (prefab == null)
        {
            Debug.LogWarning($"[wardrobe] no mesh for {slot}='{id}' ({_gender}) — slot left empty");
            return;
        }

        Wear(slot, prefab);
    }

    private static string SlotKey(WardrobeSlot slot) => slot switch
    {
        WardrobeSlot.Hair => "hair",
        WardrobeSlot.Top => "top",
        WardrobeSlot.Bottom => "bottom",
        WardrobeSlot.Shoes => "shoes",
        _ => slot.ToString().ToLowerInvariant(),
    };

    /// Full-body piece (dress, suit). Uses a dedicated `Outfit_{Gender}_{NN}`
    /// mesh when the pack ships one; otherwise it falls back to the top+bottom
    /// of the same index, which is how the current pack represents a set.
    public void EquipOutfit(string id)
    {
        EnsureBuilt();
        id = Normalize(id);

        if (string.IsNullOrEmpty(id) || id == Empty)
        {
            Unequip(WardrobeSlot.Top);
            Unequip(WardrobeSlot.Bottom);
            return;
        }

        var index = IndexOf(id);
        var folder = Capitalize(_gender);
        var outfit = index == null
            ? null
            : Resources.Load<GameObject>($"Avatar/{folder}/Outfit_{folder}_{index.Value:00}");

        if (outfit != null)
        {
            Unequip(WardrobeSlot.Top);
            Unequip(WardrobeSlot.Bottom);
            _wornIds[WardrobeSlot.Top] = id;
            Wear(WardrobeSlot.Top, outfit);
            return;
        }

        Equip(WardrobeSlot.Top, id);
        Equip(WardrobeSlot.Bottom, id);
    }

    /// `meshName` picks a single object out of a multi-item file; null wears
    /// everything the file contains.
    private void Wear(WardrobeSlot slot, GameObject prefab, string meshName = null)
    {
        var holder = new GameObject(slot.ToString());
        holder.transform.SetParent(Body.transform, false);

        var spawned = new List<GameObject> { holder };
        _worn[slot] = spawned;

        var source = Instantiate(prefab);
        source.name = prefab.name;

        var attached = 0;
        foreach (var smr in source.GetComponentsInChildren<SkinnedMeshRenderer>(true))
        {
            if (meshName != null && smr.name != meshName) continue;
            RebindToBody(smr, holder.transform);
            attached++;
        }

        // Some pieces (most hair) are rigid meshes parented to a bone rather
        // than skinned. Hang those off the closest matching bone so they still
        // follow the animation.
        foreach (var filter in source.GetComponentsInChildren<MeshFilter>(true))
        {
            if (meshName != null && filter.name != meshName) continue;
            var bone = FindBone(slot == WardrobeSlot.Hair ? "head" : "root") ?? Body.transform;
            // worldPositionStays keeps the piece where the artist placed it
            // relative to the bind pose, which is the pose we are in right now.
            filter.transform.SetParent(bone, true);
            spawned.Add(filter.gameObject);
            attached++;
        }

        Remove(source);

        if (attached == 0)
            Debug.LogWarning($"[wardrobe] '{prefab.name}' has no renderers to attach");
        else if (verbose)
            Debug.Log($"[wardrobe] {slot} = {prefab.name} ({attached} renderer(s))");

        if (slot == WardrobeSlot.Hair) ApplyHairColor(_hairColor);
        RefreshBodyHiding();
    }

    /// Drives body-hiding shape keys, IF the body mesh ships any.
    ///
    /// The fitting itself is done in Blender — nothing here reshapes the body.
    /// This only forwards the equipped slots to shape keys named `hide_top` /
    /// `hide_bottom` / `hide_shoes` when the artist chose to author them; a
    /// body without those keys is left exactly as exported.
    private static readonly (WardrobeSlot slot, string shape)[] HideShapes =
    {
        (WardrobeSlot.Top, "hide_top"),
        (WardrobeSlot.Bottom, "hide_bottom"),
        (WardrobeSlot.Shoes, "hide_shoes"),
    };

    private void RefreshBodyHiding()
    {
        if (_skinRenderer == null) return;

        var mesh = _skinRenderer.sharedMesh;
        if (mesh == null || mesh.blendShapeCount == 0) return;

        foreach (var (slot, shape) in HideShapes)
        {
            var index = mesh.GetBlendShapeIndex(shape);
            if (index < 0) continue;

            var worn = _wornIds.TryGetValue(slot, out var id)
                       && !string.IsNullOrEmpty(id)
                       && id != Empty;

            _skinRenderer.SetBlendShapeWeight(index, worn ? 100f : 0f);
            if (verbose) Debug.Log($"[wardrobe] {shape} = {(worn ? "on" : "off")}");
        }
    }

    public void Unequip(WardrobeSlot slot)
    {
        if (_worn.TryGetValue(slot, out var spawned))
        {
            foreach (var go in spawned)
                if (go != null) Remove(go);
        }

        _worn.Remove(slot);
        _wornIds[slot] = Empty;
        RefreshBodyHiding();
    }

    /// Swaps the body's albedo for one of the prepared skin tones.
    public void ApplySkin(string skinId)
    {
        _skin = string.IsNullOrEmpty(Normalize(skinId)) ? defaultSkin : Normalize(skinId);
        if (_skinRenderer == null) return;

        // skin_01 IS the map the body FBX ships with (that is how the catalogue
        // describes it), and it is authored for that exact model. Overwriting
        // it with a loose texture would only risk a mismatch.
        if (_skin == defaultSkin && HasAlbedo(_skinRenderer.sharedMaterial)) return;

        var index = IndexOf(_skin) ?? 1;
        var texture = Resources.Load<Texture2D>($"Avatar/Skins/{Capitalize(_gender)}/skin_{index:00}");
        if (texture == null)
        {
            if (verbose) Debug.Log($"[wardrobe] skin '{_skin}' not found — keeping the model's own");
            return;
        }

        var material = _skinRenderer.material; // instance, never the shared asset
        if (material.HasProperty(BaseMap)) material.SetTexture(BaseMap, texture);
        if (material.HasProperty(MainTex)) material.SetTexture(MainTex, texture);
        // The body material imports with URP's default grey tint, which would
        // multiply the skin map down to half brightness.
        if (material.HasProperty(BaseColor)) material.SetColor(BaseColor, Color.white);
        if (material.HasProperty(LegacyColor)) material.SetColor(LegacyColor, Color.white);
    }

    /// Tints the hair mesh. Hair ships white/blond, so the colour comes from
    /// the app's palette rather than from a per-colour mesh variant.
    public void ApplyHairColor(string hex)
    {
        _hairColor = hex;
        if (string.IsNullOrEmpty(hex)) return;
        if (!_worn.TryGetValue(WardrobeSlot.Hair, out var hair)) return;
        if (!ColorUtility.TryParseHtmlString(hex.StartsWith("#") ? hex : "#" + hex, out var color)) return;

        foreach (var go in hair)
        {
            if (go == null) continue;
            foreach (var renderer in go.GetComponentsInChildren<Renderer>(true))
            foreach (var material in renderer.materials)
            {
                if (material.HasProperty(BaseColor)) material.SetColor(BaseColor, color);
                else if (material.HasProperty(LegacyColor)) material.SetColor(LegacyColor, color);
            }
        }
    }

    /// Destroy that also works outside play mode, so the editor tooling can
    /// build a hero with the REAL assembly code instead of a copy of it that
    /// drifts. `Destroy` is deferred and does nothing useful in edit mode.
    private static void Remove(Object target)
    {
        if (target == null) return;

        if (Application.isPlaying) Destroy(target);
        else DestroyImmediate(target);
    }

    private static bool HasAlbedo(Material material)
    {
        if (material == null) return false;
        if (material.HasProperty(BaseMap) && material.GetTexture(BaseMap) != null) return true;
        return material.HasProperty(MainTex) && material.GetTexture(MainTex) != null;
    }

    /// Renderers of the hero and everything he wears — used for camera framing.
    public Renderer[] AllRenderers()
    {
        return Body == null ? System.Array.Empty<Renderer>()
                            : Body.GetComponentsInChildren<Renderer>(false);
    }

    // ── Building ────────────────────────────────────────────────────────────

    private void BuildBody()
    {
        if (Body != null) Remove(Body);
        _bones.Clear();
        _worn.Clear();
        _skinRenderer = null;

        var path = $"Avatar/{Capitalize(_gender)}/Body_{Capitalize(_gender)}_01";
        var prefab = Resources.Load<GameObject>(path);
        if (prefab == null)
        {
            Debug.LogError($"[wardrobe] body mesh missing at Resources/{path}");
            return;
        }

        Body = Instantiate(prefab, transform);
        Body.name = "Body";
        Body.transform.localPosition = Vector3.zero;
        Body.transform.localRotation = Quaternion.identity;

        foreach (var bone in Body.GetComponentsInChildren<Transform>(true))
            _bones[bone.name] = bone;

        // Anything hidden in Blender comes in disabled (Import Visibility is on
        // so the artist's own hiding survives) — but the hero must always be
        // fully visible: that is how the eyes disappeared, they were hidden in
        // the source scene while the artist worked on the face.
        foreach (var renderer in Body.GetComponentsInChildren<Renderer>(true))
            renderer.enabled = true;

        // A skinned renderer reports the bounds baked into the mesh, not the
        // ones it actually occupies once the skeleton poses it. The male body
        // ships a mesh whose baked bounds are ~2 cm while its rig is human
        // sized, and the camera dutifully framed those 2 cm — the hero ended up
        // inside the near clip plane and vanished. Recomputing from the real
        // skinned vertices costs a little CPU and removes the whole class of
        // bug for any future export.
        foreach (var smr in Body.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            smr.updateWhenOffscreen = true;

        Animator = Body.GetComponent<Animator>() ?? Body.GetComponentInChildren<Animator>();
        if (Animator == null) Debug.LogWarning("[wardrobe] body has no Animator — emotes will not play");

        AttachFace();
        _skinRenderer = PickSkinRenderer();

        if (verbose)
            Debug.Log($"[wardrobe] body '{prefab.name}' built: {_bones.Count} bones, " +
                      $"skin renderer '{(_skinRenderer != null ? _skinRenderer.name : "none")}'");

        BodyRebuilt?.Invoke();
    }

    /// Parts of the face that are never taken off: eyeballs, brows, lashes.
    ///
    /// The male body was exported as a bare skin — its eyes, brows and lashes
    /// live in a separate file (that is why the hero stared out of empty
    /// sockets). They are skinned to the same rig as everything else, so they
    /// are attached exactly like a garment, just permanently. A body that
    /// already carries its own face (the female one does) simply has no
    /// `Face_*` asset and this does nothing.

    private void AttachFace()
    {
        var parts = _gender == "male" ? AvatarCatalogMap.MaleFace : System.Array.Empty<AvatarItem>();
        if (parts.Length == 0) return;

        var holder = new GameObject("Face");
        holder.transform.SetParent(Body.transform, false);

        var attached = 0;
        var folder = Capitalize(_gender);

        foreach (var part in parts)
        {
            var prefab = Resources.Load<GameObject>($"Avatar/{folder}/{part.File}");
            if (prefab == null) continue;

            var source = Instantiate(prefab);
            foreach (var smr in source.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            {
                if (smr.name != part.Mesh) continue;
                RebindToBody(smr, holder.transform);
                attached++;
            }

            Remove(source);
        }

        if (verbose) Debug.Log($"[wardrobe] face parts attached: {attached}");
        if (attached == 0) Remove(holder);
    }

    /// The body FBX also carries eyes/brows/lashes; the skin map belongs to the
    /// largest mesh, which is the torso+limbs shell.
    private SkinnedMeshRenderer PickSkinRenderer()
    {
        SkinnedMeshRenderer best = null;
        var bestSize = -1f;

        foreach (var smr in Body.GetComponentsInChildren<SkinnedMeshRenderer>(true))
        {
            var name = smr.name.ToLowerInvariant();
            if (name.Contains("body") || name.Contains("skin")) return smr;

            var size = smr.bounds.size.sqrMagnitude;
            if (size <= bestSize) continue;
            bestSize = size;
            best = smr;
        }

        return best;
    }

    /// Re-skins a worn mesh onto the body's skeleton.
    private void RebindToBody(SkinnedMeshRenderer smr, Transform holder)
    {
        var bones = smr.bones;
        var mapped = new Transform[bones.Length];
        var missing = 0;

        for (var i = 0; i < bones.Length; i++)
        {
            if (bones[i] != null && _bones.TryGetValue(bones[i].name, out var bone)) mapped[i] = bone;
            else missing++;
        }

        if (missing > 0)
            Debug.LogWarning($"[wardrobe] '{smr.name}': {missing}/{bones.Length} bones " +
                             "have no match on the body — the mesh may tear");

        smr.transform.SetParent(holder, false);
        smr.enabled = true; // may have been hidden in the source .blend
        smr.bones = mapped;
        if (smr.rootBone != null && _bones.TryGetValue(smr.rootBone.name, out var root))
            smr.rootBone = root;

        // Bounds come from the body's skeleton now, so let Unity recompute them
        // instead of keeping the source file's (which would cause the piece to
        // be culled while the hero is still on screen).
        smr.updateWhenOffscreen = true;
    }

    // ── Id → resource ───────────────────────────────────────────────────────

    /// Accepts both catalogue ids (`male_top_02`, `top_02`) and raw resource
    /// names (`Top_Male_02`). Anything with a trailing number resolves; the
    /// rest falls back to the first item so a bad id never leaves a hole.
    private GameObject LoadItem(WardrobeSlot slot, string id)
    {
        var folder = Capitalize(_gender);
        var direct = Resources.Load<GameObject>($"Avatar/{folder}/{id}");
        if (direct != null) return direct;

        var index = IndexOf(id);
        if (index == null) return null;

        var byConvention = Resources.Load<GameObject>(
            $"Avatar/{folder}/{slot}_{folder}_{index.Value:00}");
        if (byConvention != null) return byConvention;

        return Resources.Load<GameObject>($"Avatar/{folder}/{slot}_{folder}_01");
    }

    private Transform FindBone(string nameFragment)
    {
        foreach (var kv in _bones)
            if (kv.Key.ToLowerInvariant().Contains(nameFragment)) return kv.Value;
        return null;
    }

    private static int? IndexOf(string id)
    {
        var match = TrailingIndex.Match(id ?? string.Empty);
        return match.Success && int.TryParse(match.Groups[1].Value, out var n) ? n : null;
    }

    private static string Normalize(string value) => (value ?? string.Empty).Trim().ToLowerInvariant();

    private static string Capitalize(string value) =>
        string.IsNullOrEmpty(value) ? value : char.ToUpperInvariant(value[0]) + value.Substring(1);
}
