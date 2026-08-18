// HeroAvatarBuilder.cs
// ────────────────────────────────────────────────────────────────────────────
// One-click (or one-command) assembly of the avatar scene, plus thin wrappers
// around the FlutterUnityIntegration exporters.
//
// The scene is built from code on purpose: the hero itself is spawned at
// runtime from Resources (AvatarWardrobe), so Avatar.unity only needs a camera,
// a light and the controller object. Rebuilding it is therefore cheap and
// always reproducible — no hand-wiring in the inspector, nothing to forget
// after a model update.
//
// Editor menu:   Hero ▸ Avatar ▸ Rebuild Scene / Export …
// Batch mode:    Unity -batchmode -quit -projectPath <project> \
//                      -executeMethod HeroAvatarBuilder.CI_RebuildScene
//                Unity -batchmode -quit -buildTarget iOS -projectPath <project> \
//                      -executeMethod HeroAvatarBuilder.CI_ExportIOS
//                Unity -batchmode -quit -buildTarget Android -projectPath <project> \
//                      -executeMethod HeroAvatarBuilder.CI_ExportAndroid
// ────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public static class HeroAvatarBuilder
{
    private const string ScenePath = "Assets/Scenes/Avatar.unity";

    // ── Menu ────────────────────────────────────────────────────────────────

    [MenuItem("Hero/Avatar/Rebuild Scene", false, 1)]
    public static void RebuildScene()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        BuildCamera();
        BuildLight();
        BuildAvatarRoot();

        Directory.CreateDirectory(Path.GetDirectoryName(ScenePath) ?? "Assets/Scenes");
        EditorSceneManager.SaveScene(scene, ScenePath);
        EnsureInBuildSettings();

        Debug.Log($"[hero] rebuilt {ScenePath} — camera, light and AvatarController; " +
                  "the hero itself is spawned at runtime from Resources/Avatar.");
    }

    [MenuItem("Hero/Avatar/Export to Flutter (iOS)", false, 21)]
    public static void ExportIOS()
    {
        EnsureInBuildSettings();
        FlutterUnityIntegration.Editor.Build.DoBuildIOSRelease();
    }

    [MenuItem("Hero/Avatar/Export to Flutter (Android)", false, 22)]
    public static void ExportAndroid()
    {
        EnsureInBuildSettings();
        FlutterUnityIntegration.Editor.Build.DoBuildAndroidLibraryRelease();
    }

    [MenuItem("Hero/Avatar/Log Wardrobe Contents", false, 41)]
    public static void LogWardrobe()
    {
        foreach (var gender in new[] { "Male", "Female" })
        {
            var items = Resources.LoadAll<GameObject>($"Avatar/{gender}")
                                 .Select(o => o.name)
                                 .OrderBy(n => n);
            Debug.Log($"[hero] {gender}: {string.Join(", ", items)}");
        }

        var clips = Resources.LoadAll<AnimationClip>("Avatar/Animations")
                             .Where(c => !c.name.StartsWith("__"))
                             .Select(c => $"{c.name} ({c.length:0.00}s{(c.isLooping ? ", loop" : "")})");
        Debug.Log($"[hero] clips: {string.Join(", ", clips)}");
    }

    [MenuItem("Hero/Avatar/Validate Wardrobe", false, 42)]
    public static void ValidateWardrobe()
    {
        foreach (var gender in new[] { "Male", "Female" })
        {
            var body = Resources.Load<GameObject>($"Avatar/{gender}/Body_{gender}_01");
            if (body == null)
            {
                Debug.LogError($"[hero] {gender}: no Body_{gender}_01 in Resources/Avatar/{gender}");
                continue;
            }

            var bones = new System.Collections.Generic.HashSet<string>(
                body.GetComponentsInChildren<Transform>(true).Select(t => t.name));

            var animator = body.GetComponentInChildren<Animator>();
            var avatar = animator != null ? animator.avatar : null;
            Debug.Log($"[hero] {gender} body: {bones.Count} bones, avatar " +
                      $"{(avatar == null ? "MISSING" : avatar.isValid ? (avatar.isHuman ? "humanoid ✓" : "valid, not humanoid") : "INVALID")}");

            foreach (var item in Resources.LoadAll<GameObject>($"Avatar/{gender}"))
            {
                if (item == null || item.name.StartsWith("Body_")) continue;

                var total = 0;
                var matched = 0;
                foreach (var smr in item.GetComponentsInChildren<SkinnedMeshRenderer>(true))
                foreach (var bone in smr.bones)
                {
                    total++;
                    if (bone != null && bones.Contains(bone.name)) matched++;
                }

                var rigid = item.GetComponentsInChildren<MeshFilter>(true).Length;

                if (total == 0 && rigid == 0)
                    Debug.LogError($"[hero]   {item.name}: no renderers at all");
                else if (total == 0)
                    Debug.Log($"[hero]   {item.name}: rigid mesh ×{rigid} (parented to a bone)");
                else if (matched == total)
                    Debug.Log($"[hero]   {item.name}: {matched}/{total} bones ✓");
                else
                    Debug.LogWarning($"[hero]   {item.name}: only {matched}/{total} bones match the body — mesh will tear");
            }
        }

        // Load exactly the way AvatarAnimation does at runtime — per FILE, not
        // per folder — so a lookup that silently returns nothing shows up here
        // and not as a hero frozen in T-pose on a device.
        foreach (var file in new[] { "anim_idle_male", "anim_idle_female", "anim_clap", "anim_upset" })
        {
            var clips = Resources.LoadAll<AnimationClip>("Avatar/Animations/" + file)
                                 .Where(c => c != null && !c.name.StartsWith("__"))
                                 .ToArray();

            if (clips.Length == 0)
            {
                Debug.LogError($"[hero] clip {file}: NOT loadable by file path — AvatarAnimation will not find it");
                continue;
            }

            var clip = clips[0];
            Debug.Log($"[hero] clip {file} -> '{clip.name}': {clip.length:0.00}s, " +
                      $"{(clip.isLooping ? "loop" : "one-shot")}, " +
                      $"{(clip.isHumanMotion ? "humanoid ✓" : "NOT humanoid — will not retarget")}");
        }
    }

    [MenuItem("Hero/Avatar/Inspect Bodies", false, 43)]
    public static void InspectBodies()
    {
        foreach (var gender in new[] { "Male", "Female" })
        {
            var body = Resources.Load<GameObject>($"Avatar/{gender}/Body_{gender}_01");
            if (body == null) continue;

            Debug.Log($"[hero] ── Body_{gender}_01 ──");
            foreach (var smr in body.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            {
                var mesh = smr.sharedMesh;
                Debug.Log($"[hero]   renderer '{smr.name}': mesh '{(mesh != null ? mesh.name : "none")}', " +
                          $"{(mesh != null ? mesh.vertexCount : 0)} verts, " +
                          $"{(mesh != null ? mesh.subMeshCount : 0)} submesh(es), " +
                          $"bounds {(mesh != null ? mesh.bounds.size.ToString("F2") : "-")}, " +
                          $"{smr.sharedMaterials.Length} material(s)");

                foreach (var mat in smr.sharedMaterials)
                {
                    if (mat == null) { Debug.LogWarning("[hero]     material: NULL"); continue; }
                    var tex = mat.HasProperty("_BaseMap") ? mat.GetTexture("_BaseMap") : null;
                    tex ??= mat.HasProperty("_MainTex") ? mat.GetTexture("_MainTex") : null;
                    var color = mat.HasProperty("_BaseColor") ? mat.GetColor("_BaseColor")
                              : mat.HasProperty("_Color") ? mat.GetColor("_Color") : Color.white;
                    Debug.Log($"[hero]     material '{mat.name}' shader '{mat.shader.name}' " +
                              $"albedo {(tex == null ? "NO TEXTURE" : "'" + tex.name + "'")} colour {color}");
                }
            }
        }
    }

    /// Pulls the textures that are embedded inside the FBX out onto disk, next
    /// to the model. Without this every imported material is plain white — the
    /// meshes reference a `<name>.fbm` folder that only existed on the machine
    /// the FBX was exported from.
    [MenuItem("Hero/Avatar/Extract Embedded Textures", false, 44)]
    public static void ExtractEmbeddedTextures()
    {
        var extracted = 0;
        foreach (var guid in AssetDatabase.FindAssets("t:Model", new[] { "Assets/Resources/Avatar" }))
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            if (AssetImporter.GetAtPath(path) is not ModelImporter importer) continue;

            var folder = Path.Combine(Path.GetDirectoryName(path) ?? "", "Textures");
            Directory.CreateDirectory(folder);

            if (importer.ExtractTextures(folder))
            {
                extracted++;
                Debug.Log($"[hero] extracted textures from {Path.GetFileName(path)} -> {folder}");
            }
        }

        AssetDatabase.Refresh();
        Debug.Log(extracted == 0
            ? "[hero] no FBX carried embedded textures — they must be supplied as loose files"
            : $"[hero] extracted textures from {extracted} model(s)");
    }

    /// Re-imports the models so their materials pick up textures that were
    /// added to the project after the FBX were first imported. Unity matches
    /// them by file name, so a texture only has to exist somewhere in the
    /// project — but the binding happens at import time.
    [MenuItem("Hero/Avatar/Reimport Avatar Assets", false, 45)]
    public static void ReimportAvatarAssets()
    {
        var paths = AssetDatabase.FindAssets("t:Texture", new[] { "Assets/AvatarTextures" })
                                 .Select(AssetDatabase.GUIDToAssetPath)
                                 .Concat(AssetDatabase.FindAssets("t:Model", new[] { "Assets/Resources/Avatar" })
                                                      .Select(AssetDatabase.GUIDToAssetPath))
                                 .ToArray();

        AssetDatabase.StartAssetEditing();
        try
        {
            foreach (var path in paths)
                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        }
        finally
        {
            AssetDatabase.StopAssetEditing();
        }

        AssetDatabase.Refresh();
        Debug.Log($"[hero] reimported {paths.Length} asset(s)");
    }

    /// Brings every body to the same real-world height at IMPORT time.
    ///
    /// A body exported in the wrong units (the current male one arrives ~2 cm
    /// tall) cannot be fixed by scaling the spawned object: the wardrobe is
    /// re-skinned onto the body's bones and its bind poses are authored at
    /// human scale, so a scaled root blows the clothes up with it. Scaling the
    /// IMPORT keeps mesh, skeleton and every garment in one coordinate system.
    /// DISABLED BY DEFAULT — see the warning below before using it.
    ///
    /// Matching a body's rig to the wardrobe's rig sounds right and is wrong:
    /// what gets drawn is bone × bindPose × vertex, and the male body ships an
    /// armature and a mesh that are 100× apart with bind poses cancelling the
    /// difference. Rescaling the import "to fix the rig" therefore shrank the
    /// rendered body by 100 while the clothes stayed put. Camera framing was
    /// the only real victim of the odd numbers, and that is solved by asking
    /// the renderer for real skinned bounds instead (AvatarWardrobe).
    [MenuItem("Hero/Avatar/Fix Body Scale (diagnostic)", false, 46)]
    public static void FixBodyScale()
    {
        foreach (var gender in new[] { "Male", "Female" })
        {
            // The reference is the WARDROBE, not a nice round number: every
            // garment was fitted by hand to a body of a particular size, and it
            // is re-skinned onto the body's bones at runtime. Match the body's
            // skeleton to the skeleton the clothes were bound to and both stay
            // in agreement, whatever units the body was exported in.
            var reference = MeasureRig(Resources.Load<GameObject>($"Avatar/{gender}/Top_{gender}_01"))
                          ?? MeasureRig(Resources.Load<GameObject>($"Avatar/{gender}/Bottom_{gender}_01"));

            var path = AssetDatabase.GetAssetPath(Resources.Load<GameObject>($"Avatar/{gender}/Body_{gender}_01"));
            if (reference == null || string.IsNullOrEmpty(path)) continue;
            if (AssetImporter.GetAtPath(path) is not ModelImporter importer) continue;

            for (var attempt = 0; attempt < 4; attempt++)
            {
                var current = MeasureRig(AssetDatabase.LoadAssetAtPath<GameObject>(path));
                if (current == null || current.Value <= 0f) break;

                var ratio = reference.Value / current.Value;
                if (Mathf.Abs(ratio - 1f) < 0.02f)
                {
                    Debug.Log($"[hero] Body_{gender}_01: rig {current.Value:0.000} vs wardrobe " +
                              $"{reference.Value:0.000} — matched");
                    break;
                }

                var scale = importer.useFileScale ? 1f : importer.globalScale;
                importer.useFileScale = false;
                importer.globalScale = scale * ratio;
                importer.SaveAndReimport();

                Debug.Log($"[hero] Body_{gender}_01: rig {current.Value:0.000} vs wardrobe " +
                          $"{reference.Value:0.000} -> globalScale {importer.globalScale:0.####}");
            }
        }
    }

    /// Distance from the rig's root to the head bone — a scale yardstick that
    /// does not depend on the mesh, so a body and a garment can be compared.
    private static float? MeasureRig(GameObject prefab)
    {
        if (prefab == null) return null;

        Transform root = null;
        Transform head = null;

        foreach (var bone in prefab.GetComponentsInChildren<Transform>(true))
        {
            var name = bone.name.ToLowerInvariant();
            if (root == null && name == "root") root = bone;
            if (head == null && name == "head") head = bone;
        }

        if (root == null || head == null) return null;
        return Vector3.Distance(root.position, head.position);
    }

    /// Full report on every model in a folder: rig size, bones, meshes.
    ///
    /// This is the first thing to run on a fresh delivery from Blender —
    /// mismatched rig scale between a body and its clothes is invisible in the
    /// project window and tears the hero apart at runtime.
    [MenuItem("Hero/Avatar/Inspect Incoming Models", false, 47)]
    public static void InspectIncoming()
    {
        foreach (var guid in AssetDatabase.FindAssets("t:Model", new[] { "Assets/Resources/Avatar" }))
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab == null) continue;

            var bones = prefab.GetComponentsInChildren<Transform>(true).Length;
            var rig = MeasureRig(prefab);
            var animator = prefab.GetComponentInChildren<Animator>();
            var avatar = animator != null ? animator.avatar : null;

            Debug.Log($"[hero/in] {Path.GetFileName(path)}: {bones} transforms, " +
                      $"rig root→head {(rig == null ? "n/a" : rig.Value.ToString("0.000"))}, " +
                      $"avatar {(avatar == null ? "none" : avatar.isHuman ? "humanoid" : "generic")}");

            foreach (var smr in prefab.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            {
                var verts = smr.sharedMesh != null ? smr.sharedMesh.vertexCount : 0;
                var shapes = smr.sharedMesh != null ? smr.sharedMesh.blendShapeCount : 0;
                Debug.Log($"[hero/in]    {smr.name}: {verts} verts, {smr.bones.Length} bones, " +
                          $"{shapes} blendshape(s), " +
                          $"{(smr.enabled ? "visible" : "HIDDEN in .blend")}");
            }
        }
    }

    public static void CI_InspectIncoming() => InspectIncoming();

    /// Compares the bind pose of every model against the body's.
    ///
    /// A garment authored on an A-posed body and re-skinned onto a T-posed one
    /// bulges at the shoulders — the meshes agree on bone NAMES and disagree on
    /// where those bones were when the artist fitted the cloth. Bone positions
    /// are the only way to see that before it shows up on a device.
    [MenuItem("Hero/Avatar/Compare Bind Poses", false, 48)]
    public static void CompareBindPoses()
    {
        var probes = new[] { "upperarm_l", "lowerarm_l", "hand_l", "thigh_l", "head" };

        foreach (var guid in AssetDatabase.FindAssets("t:Model", new[] { "Assets/Resources/Avatar/Male" }))
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab == null) continue;

            var bones = new Dictionary<string, Transform>();
            foreach (var t in prefab.GetComponentsInChildren<Transform>(true))
                bones[t.name.ToLowerInvariant()] = t;

            var report = new List<string>();
            foreach (var probe in probes)
            {
                if (bones.TryGetValue(probe, out var bone))
                    report.Add($"{probe} {bone.position:F3}");
            }

            Debug.Log($"[hero/pose] {Path.GetFileName(path)}: {string.Join(" | ", report)}");
        }
    }

    public static void CI_CompareBindPoses() => CompareBindPoses();

    // ── Batch-mode entry points ─────────────────────────────────────────────

    public static void CI_RebuildScene() => RebuildScene();

    public static void CI_Validate() => ValidateWardrobe();

    public static void CI_InspectBodies() => InspectBodies();

    public static void CI_FixBodyScale()
    {
        FixBodyScale();
        InspectBodies();
    }

    public static void CI_ExtractTextures()
    {
        ExtractEmbeddedTextures();
        InspectBodies();
    }

    public static void CI_ReimportAvatar()
    {
        ReimportAvatarAssets();
        InspectBodies();
    }

    public static void CI_ExportIOS()
    {
        RebuildScene();
        ExportIOS();
    }

    public static void CI_ExportAndroid()
    {
        RebuildScene();
        ExportAndroid();
    }

    // ── Pieces ──────────────────────────────────────────────────────────────

    private static void BuildCamera()
    {
        var go = new GameObject("Main Camera", typeof(Camera), typeof(AudioListener))
        {
            tag = "MainCamera",
        };

        // Rough framing only — AvatarController re-frames from the real skinned
        // bounds on the first frame, and again whenever the wardrobe changes.
        go.transform.SetPositionAndRotation(new Vector3(0f, 1.1f, 2.6f),
                                            Quaternion.Euler(2f, 180f, 0f));

        var camera = go.GetComponent<Camera>();
        camera.clearFlags = CameraClearFlags.SolidColor;
        // Transparent clear: the Flutter background shows through the view.
        camera.backgroundColor = new Color(0.051f, 0.051f, 0.071f, 0f);
        camera.fieldOfView = 40f;
        camera.nearClipPlane = 0.05f;
        camera.farClipPlane = 30f;
        camera.allowMSAA = false;
    }

    private static void BuildLight()
    {
        var go = new GameObject("Directional Light", typeof(Light));
        go.transform.SetPositionAndRotation(new Vector3(0f, 3f, 1.5f),
                                            Quaternion.Euler(35f, 200f, 0f));

        var light = go.GetComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1.3f;
        light.shadows = LightShadows.None; // a single hero on a phone; shadows
                                           // cost more than they add here
    }

    private static void BuildAvatarRoot()
    {
        // The name is part of the contract: Flutter addresses messages to the
        // GameObject called exactly "AvatarController".
        var go = new GameObject("AvatarController",
                                typeof(BoxCollider),
                                typeof(AvatarWardrobe),
                                typeof(AvatarAnimation),
                                typeof(AvatarController));
        go.transform.position = Vector3.zero;

        // Placeholder size; AvatarController.FitTapCollider resizes it to the
        // real hero once the mesh exists.
        var box = go.GetComponent<BoxCollider>();
        box.center = new Vector3(0f, 0.9f, 0f);
        box.size = new Vector3(0.8f, 1.8f, 0.5f);
    }

    private static void EnsureInBuildSettings()
    {
        // Drop entries whose scene file is gone (deleted sample/recovery
        // scenes) — they would otherwise sit in the build list forever.
        var scenes = EditorBuildSettings.scenes
                                        .Where(s => File.Exists(s.path))
                                        .ToList();
        var existing = scenes.FindIndex(s => s.path == ScenePath);

        if (existing >= 0)
        {
            scenes[existing] = new EditorBuildSettingsScene(ScenePath, true);
        }
        else
        {
            scenes.Insert(0, new EditorBuildSettingsScene(ScenePath, true));
        }

        // Anything else (SampleScene, the FlutterUnityIntegration demo) would
        // only add weight to the export.
        foreach (var scene in scenes.Where(s => s.path != ScenePath)) scene.enabled = false;

        EditorBuildSettings.scenes = scenes.ToArray();
    }
}
