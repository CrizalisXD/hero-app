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
    [SerializeField] private Color backgroundColor = new Color(0.051f, 0.051f, 0.071f, 1f);

    [Tooltip("Aim the camera at the avatar's centre so it's always centred.")]
    [SerializeField] private bool autoCenter = true;

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

        if (!autoCenter) return;
        var root = tintTarget != null ? tintTarget.transform.root : transform.root;
        var rends = root.GetComponentsInChildren<Renderer>();
        if (rends.Length == 0) return;
        var b = rends[0].bounds;
        for (int i = 1; i < rends.Length; i++) b.Encapsulate(rends[i].bounds);
        // Keep the camera where it is (front view, distance) and just aim it at
        // the avatar's centre — centres horizontally & vertically, any aspect.
        cam.transform.LookAt(b.center);
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
        if (tintTarget == null || string.IsNullOrEmpty(hex)) return;
        if (ColorUtility.TryParseHtmlString(hex, out var color))
        {
            // Instance the material so we don't edit the shared asset.
            tintTarget.material.color = color;
        }
    }

    private void Send(string message)
    {
        if (UnityMessageManager.Instance != null)
            UnityMessageManager.Instance.SendMessageToFlutter(message);
    }
}
