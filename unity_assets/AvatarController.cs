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

    private static readonly int IdleHash = Animator.StringToHash("idle");

    // ── Lifecycle ───────────────────────────────────────────────────────────

    private void Start()
    {
        if (animator != null) animator.SetTrigger(IdleHash);
        Send("avatar:ready");
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
