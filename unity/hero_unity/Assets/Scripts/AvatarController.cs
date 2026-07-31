// AvatarController.cs
// ────────────────────────────────────────────────────────────────────────────
// Hero avatar bridge for the Flutter <-> Unity integration.
//
// Drop this onto a GameObject named exactly "AvatarController" in your avatar
// scene. It receives config/emotes from Flutter and reports ready/tap/emote
// events back. Message strings here MUST match the Dart side
// (UnityAvatarBridge in UNITY_SETUP.md):
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
    public string primaryColor;   // "#7F77DD"
    public int level;
    public string renderer;       // "unity"
    public string bodyType;
    public string faceType;
    public string hairType;
    public string clothingType;
    public string unityAvatarId;
}

[RequireComponent(typeof(Collider))] // so OnMouseDown / taps work
public class AvatarController : MonoBehaviour
{
    [Header("Refs")]
    [Tooltip("Renderer whose material gets tinted by primaryColor.")]
    [SerializeField] private Renderer tintTarget;

    [Tooltip("Animator that holds the emote states. Trigger names must match " +
             "the emote wire names: idle, task_done, level_up, wave.")]
    [SerializeField] private Animator animator;

    [Tooltip("Fallback emote length if no Animation Event fires.")]
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

    private static readonly int IdleHash = Animator.StringToHash("idle");

    // ── Lifecycle ───────────────────────────────────────────────────────────

    private void Start()
    {
        ConfigureScene();
        if (animator != null) animator.SetTrigger(IdleHash);
        Send("avatar:ready");
    }

    // Re-aim once more after the first frame, when skinned bounds are final.
    private bool _framedOnce;
    private void LateUpdate()
    {
        if (_framedOnce) return;
        _framedOnce = true;
        ConfigureScene();
    }

    /// Force a solid dark background (no skybox) and centre the avatar in frame.
    /// Done in code so a scene tweak / re-export can't silently undo it.
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
        var root = tintTarget != null ? tintTarget.transform.root : transform.root;
        var rends = root.GetComponentsInChildren<Renderer>();
        if (rends.Length == 0) return;
        var b = rends[0].bounds;
        for (int i = 1; i < rends.Length; i++) b.Encapsulate(rends[i].bounds);

        // Frame the avatar to fill `frameFill` of the view HEIGHT regardless of
        // the model's real size: pull the camera back along its current view
        // direction (angle preserved) so only the on-screen size changes. This
        // shrinks the MODEL without shrinking the full-screen Unity view.
        float h = Mathf.Max(b.size.y, 0.01f);
        float halfFov = cam.fieldOfView * 0.5f * Mathf.Deg2Rad;
        float dist = (h / Mathf.Max(frameFill, 0.05f)) / (2f * Mathf.Tan(halfFov));
        Vector3 dir = cam.transform.position - b.center;
        dir = dir.sqrMagnitude < 0.0001f ? -cam.transform.forward : dir.normalized;
        cam.transform.position = b.center + dir * dist;
        cam.transform.LookAt(b.center); // establish base orientation

        // Re-aim to slide the MODEL within the frame (screen-space offset).
        // Aiming to the RIGHT of the avatar makes it appear on the LEFT.
        float halfH = dist * Mathf.Tan(halfFov);
        float halfW = halfH * cam.aspect;
        Vector3 aim = b.center
            + cam.transform.right * (shiftLeftFrac * 2f * halfW)
            + cam.transform.up * (shiftDownFrac * 2f * halfH);
        cam.transform.LookAt(aim);
    }

    // Tap on the avatar collider -> open avatar screen in Flutter.
    private void OnMouseDown()
    {
        Send("avatar:tapped");
    }

    // ── Flutter -> Unity ─────────────────────────────────────────────────────

    /// Called by Flutter: controller.postJsonMessage("AvatarController",
    /// "SetAvatarConfig", config.toJson()).
    public void SetAvatarConfig(string json)
    {
        AvatarConfig cfg;
        try { cfg = JsonUtility.FromJson<AvatarConfig>(json); }
        catch { return; }
        if (cfg == null) return;

        ApplyTint(cfg.primaryColor);
        // TODO: swap mesh by cfg.unityAvatarId, apply body/face/hair/clothing.
        // TODO: scale aura / VFX by cfg.level if desired.
    }

    /// Called by Flutter: controller.postMessage("AvatarController",
    /// "PlayEmote", "level_up").
    public void PlayEmote(string emote)
    {
        if (string.IsNullOrEmpty(emote)) return;
        if (animator != null) animator.SetTrigger(emote);
        StopAllCoroutines();
        StartCoroutine(EmoteFallback(emote));
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    // Call this from an Animation Event at the end of an emote clip for exact
    // timing; the coroutine below is just a safety fallback.
    public void NotifyEmoteFinished(string emote)
    {
        Send("avatar:emote_finished:" + emote);
    }

    private IEnumerator EmoteFallback(string emote)
    {
        yield return new WaitForSeconds(emoteFallbackSeconds);
        Send("avatar:emote_finished:" + emote);
        if (animator != null) animator.SetTrigger(IdleHash);
    }

    private void ApplyTint(string hex)
    {
        // primaryColor is a UI ACCENT (profile ring, aura, HUD) — NOT a skin
        // tint. Writing it into the body material's albedo painted the whole
        // avatar green/purple. The imported model already ships natural
        // materials (suit, skin), so we must leave them untouched. Kept as a
        // no-op hook: if a dedicated accent renderer (aura/platform/rim) is
        // wired up later, tint THAT here — never the body mesh.
        return;
    }

    private void Send(string message)
    {
        if (UnityMessageManager.Instance != null)
            UnityMessageManager.Instance.SendMessageToFlutter(message);
    }
}
