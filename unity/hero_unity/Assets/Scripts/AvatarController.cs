// AvatarController.cs
// ────────────────────────────────────────────────────────────────────────────
// Hero avatar bridge for the Flutter <-> Unity integration.
//
// Drop this onto a GameObject named exactly "AvatarController" in the avatar
// scene (HeroAvatarBuilder does it for you). It owns three things:
//   • the wire protocol with Flutter,
//   • the wardrobe (which body/clothes are on screen — AvatarWardrobe),
//   • how the hero is framed by the camera.
//
// Message strings MUST match the Dart side (UnityAvatarBridge):
//   Flutter -> Unity : SetAvatarConfig(json), PlayEmote(name)
//   Unity  -> Flutter: "avatar:ready", "avatar:tapped",
//                      "avatar:emote_finished:<name>"
//
// Requires the FlutterUnityIntegration package (UnityMessageManager).
// ────────────────────────────────────────────────────────────────────────────

using System.Collections;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.Rendering.Universal;

[System.Serializable]
public class AvatarConfig
{
    public string primaryColor;   // "#7F77DD" — UI accent, NOT a skin tint
    public int level;
    public string renderer;       // "unity"

    // Wardrobe. Ids are the app's canonical ones ("male_top_02") or plain
    // resource names ("Top_Male_02"); "default" means "nothing in this slot".
    public string gender;         // "male" | "female"
    public string bodyType;
    public string faceType;
    public string skinColor;      // "skin_01".."skin_03"
    public string hairType;
    public string hairColor;      // "#362419"
    public string outfitType;     // full-body piece; overrides top/bottom
    public string topType;
    public string bottomType;
    public string shoesType;

    /// DEPRECATED — kept so older app builds keep deserialising.
    public string clothingType;
    public string unityAvatarId;
}

[RequireComponent(typeof(Collider))] // so OnMouseDown / taps work
public class AvatarController : MonoBehaviour
{
    [Header("Refs")]
    [Tooltip("Builds the hero from Resources. Added automatically if missing.")]
    [SerializeField] private AvatarWardrobe wardrobe;

    [Tooltip("Idle loop + emotes. Added automatically if missing.")]
    [SerializeField] private AvatarAnimation avatarAnimation;

    [Tooltip("Fallback emote length if the animation graph can't report back.")]
    [SerializeField] private float emoteFallbackSeconds = 1.5f;

    [Header("Scene framing (done in code so it can't drift)")]
    [Tooltip("Camera to drive. Leave empty to use Camera.main.")]
    [SerializeField] private Camera sceneCamera;

    [Tooltip("Solid background colour — kills the skybox. App bg is #0D0D12. "
             + "Set alpha to 0 to try a transparent view.")]
    [SerializeField] private Color backgroundColor = new Color(0.051f, 0.051f, 0.071f, 0f);

    [Tooltip("Aim the camera at the avatar's centre so it's always centred.")]
    [SerializeField] private bool autoCenter = true;

    [Tooltip("How much of the view HEIGHT the avatar fills (0..1). Lower = " +
             "smaller model with more headroom. The Unity view stays " +
             "full-screen; only the model shrinks on screen.")]
    [SerializeField, Range(0.2f, 1f)] private float frameFill = 0.6f;

    [Tooltip("Shift the MODEL left within the full-screen view, as a fraction " +
             "of view width (0 = centred, 0.18 ≈ left third). View stays full.")]
    [SerializeField, Range(-0.5f, 0.5f)] private float shiftLeftFrac = 0.18f;

    [Tooltip("Shift the MODEL down within the view, as a fraction of view " +
             "height (0 = centred, positive = lower).")]
    [SerializeField, Range(-0.5f, 0.5f)] private float shiftDownFrac = 0.14f;

    [Header("Performance")]
    [Tooltip("Frame cap for the embedded avatar view. The hero only breathes " +
             "in idle, so 30 fps is indistinguishable from 60 and halves the " +
             "engine's per-frame cost — which matters a lot here, because on " +
             "Home the Unity layer is composited together with the Flutter " +
             "overlays on every single frame.")]
    [SerializeField, Range(15, 60)] private int targetFps = 30;

    private bool _framedOnce;

    // ── Lifecycle ───────────────────────────────────────────────────────────

    private void Awake()
    {
        if (wardrobe == null) wardrobe = GetComponent<AvatarWardrobe>() ?? gameObject.AddComponent<AvatarWardrobe>();
        if (avatarAnimation == null) avatarAnimation = GetComponent<AvatarAnimation>() ?? gameObject.AddComponent<AvatarAnimation>();

        wardrobe.BodyRebuilt += OnBodyRebuilt;
    }

    private void OnDestroy()
    {
        if (wardrobe != null) wardrobe.BodyRebuilt -= OnBodyRebuilt;
    }

    private void Start()
    {
        // vSyncCount в QualitySettings стоит 0, а targetFrameRate по умолчанию
        // -1 — то есть потолка кадров у встроенного плеера не было вообще.
        Application.targetFrameRate = targetFps;

        // Show the default hero immediately: Flutter's SetAvatarConfig arrives
        // a beat after the view is created, and an empty stage in between reads
        // as a broken build.
        wardrobe.EnsureBuilt();
        ConfigureScene();
        Send("avatar:ready");
    }

    // Re-aim once more after the first frame, when skinned bounds are final.
    private void LateUpdate()
    {
        if (_framedOnce) return;
        _framedOnce = true;
        ConfigureScene();
    }

    private void OnBodyRebuilt()
    {
        avatarAnimation.Bind(wardrobe.Animator, CurrentGender);
        _framedOnce = false; // bounds changed — re-frame on the next frame
    }

    private string CurrentGender { get; set; } = "male";

    // ── Flutter -> Unity ─────────────────────────────────────────────────────

    /// Called by Flutter: controller.postJsonMessage("AvatarController",
    /// "SetAvatarConfig", config.toJson()).
    public void SetAvatarConfig(string json)
    {
        AvatarConfig cfg;
        try { cfg = JsonUtility.FromJson<AvatarConfig>(json); }
        catch (System.Exception e)
        {
            Debug.LogWarning("[avatar] bad config json: " + e.Message);
            return;
        }

        if (cfg == null) return;

        CurrentGender = string.IsNullOrEmpty(cfg.gender) ? CurrentGender : cfg.gender;
        wardrobe.SetGender(CurrentGender);

        wardrobe.Equip(WardrobeSlot.Hair, cfg.hairType);
        wardrobe.Equip(WardrobeSlot.Shoes, cfg.shoesType);

        // A full-body outfit replaces the two-piece set — the same exclusivity
        // the app enforces in Avatar.withSlot.
        if (!string.IsNullOrEmpty(cfg.outfitType) && cfg.outfitType != AvatarWardrobe.Empty)
        {
            wardrobe.EquipOutfit(cfg.outfitType);
        }
        else
        {
            wardrobe.Equip(WardrobeSlot.Top, cfg.topType);
            wardrobe.Equip(WardrobeSlot.Bottom, cfg.bottomType);
        }

        wardrobe.ApplySkin(cfg.skinColor);
        wardrobe.ApplyHairColor(cfg.hairColor);

        ApplyTint(cfg.primaryColor);
        ConfigureScene();
    }

    /// Called by Flutter: controller.postMessage("AvatarController",
    /// "PlayEmote", "level_up").
    public void PlayEmote(string emote)
    {
        if (string.IsNullOrEmpty(emote)) return;

        StopAllCoroutines();
        StartCoroutine(EmoteFallback(emote));
        avatarAnimation.PlayEmote(emote, NotifyEmoteFinished);
    }

    // Tap on the avatar collider -> Flutter decides what to do with it.
    private void OnMouseDown() => Send("avatar:tapped");

    // ── Scene ────────────────────────────────────────────────────────────────

    /// Force a solid dark background (no skybox), centre the avatar in frame
    /// and keep the tap collider on the model. Done in code so a scene tweak /
    /// re-export can't silently undo it.
    private void ConfigureScene()
    {
        var cam = sceneCamera != null ? sceneCamera : Camera.main;
        if (cam == null) return;

        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = backgroundColor;

        // Kill the dark silhouette halo on the transparent view. MSAA resolves
        // edge pixels to PARTIAL alpha over the (transparent, near-black) clear
        // colour, so iOS composites a dark fringe around the avatar. Disabling
        // MSAA makes edges fully opaque/transparent (no partial-alpha rim), and
        // FXAA smooths them in a post pass on the colour buffer instead — no
        // fringe, still anti-aliased.
        cam.allowMSAA = false;
        var camData = cam.GetUniversalAdditionalCameraData();
        if (camData != null)
        {
            camData.antialiasing = AntialiasingMode.FastApproximateAntialiasing;
        }

        if (!autoCenter) return;

        var rends = wardrobe.AllRenderers();
        if (rends.Length == 0) return;

        var b = rends[0].bounds;
        for (var i = 1; i < rends.Length; i++) b.Encapsulate(rends[i].bounds);

        // Frame the avatar to fill `frameFill` of the view HEIGHT regardless of
        // the model's real size: pull the camera back along its current view
        // direction (angle preserved) so only the on-screen size changes. This
        // shrinks the MODEL without shrinking the full-screen Unity view.
        var h = Mathf.Max(b.size.y, 0.01f);
        var halfFov = cam.fieldOfView * 0.5f * Mathf.Deg2Rad;
        var dist = (h / Mathf.Max(frameFill, 0.05f)) / (2f * Mathf.Tan(halfFov));
        // Rebuild the framing from scratch every time instead of nudging the
        // camera from wherever it currently is: state-derived framing drifts as
        // soon as the body changes, and a camera that ends up above the hero
        // looking down makes him read as hunched over on screen.
        cam.transform.position = b.center + Vector3.forward * dist;
        cam.transform.rotation = Quaternion.Euler(0f, 180f, 0f); // level, facing the hero

        // Never let the clip planes cut the hero out of the frame — a model
        // that arrives in different units would otherwise sit entirely behind
        // the far plane and render as nothing at all.
        cam.nearClipPlane = Mathf.Max(0.01f, dist * 0.01f);
        cam.farClipPlane = Mathf.Max(30f, dist * 4f);

        // Slide the MODEL within the frame by MOVING the camera, never by
        // aiming it: a tilted camera foreshortens the figure, a shifted one
        // only changes where he sits on screen.
        var halfH = dist * Mathf.Tan(halfFov);
        var halfW = halfH * cam.aspect;
        // Moving the camera RIGHT puts the hero on the LEFT of the frame.
        cam.transform.position += cam.transform.right * (shiftLeftFrac * 2f * halfW)
                                 + cam.transform.up * (shiftDownFrac * 2f * halfH);

        FitTapCollider(b);
    }

    /// The hero is spawned at runtime, so the tap target is sized in code —
    /// a hand-placed collider in the scene would stop matching the moment the
    /// body or the clothes change.
    private void FitTapCollider(Bounds bounds)
    {
        if (GetComponent<Collider>() is not BoxCollider box) return;
        box.center = transform.InverseTransformPoint(bounds.center);
        box.size = bounds.size;
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    /// Call this from an Animation Event at the end of an emote clip for exact
    /// timing; the coroutine below is just a safety fallback.
    public void NotifyEmoteFinished(string emote)
    {
        StopAllCoroutines();
        Send("avatar:emote_finished:" + emote);
    }

    private IEnumerator EmoteFallback(string emote)
    {
        yield return new WaitForSeconds(emoteFallbackSeconds);
        Send("avatar:emote_finished:" + emote);
    }

    private void ApplyTint(string hex)
    {
        // primaryColor is a UI ACCENT (profile ring, aura, HUD) — NOT a skin
        // tint. Writing it into the body material's albedo painted the whole
        // avatar green/purple. The imported model already ships natural
        // materials (suit, skin), so we must leave them untouched. Kept as a
        // no-op hook: if a dedicated accent renderer (aura/platform/rim) is
        // wired up later, tint THAT here — never the body mesh.
    }

    private void Send(string message)
    {
        if (UnityMessageManager.Instance != null)
            UnityMessageManager.Instance.SendMessageToFlutter(message);
    }
}
