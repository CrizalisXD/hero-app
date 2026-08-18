// AvatarAnimation.cs
// ────────────────────────────────────────────────────────────────────────────
// Idle loop + one-shot emotes for the hero, driven by the Playables API
// instead of an AnimatorController.
//
// Why no .controller asset: the body is spawned at runtime and can switch
// gender, so the clip set is decided at runtime too. A state machine asset
// would have to be authored in the editor and re-authored every time a clip is
// added — a graph built in code stays in sync with whatever is in
// Resources/Avatar/Animations.
//
// The clips come from Mixamo (their own skeleton) and are imported as Humanoid,
// so Unity retargets them onto the body's humanoid avatar. That is also why a
// single `anim_clap` can serve both the male and the female hero.
// ────────────────────────────────────────────────────────────────────────────

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

[DisallowMultipleComponent]
public class AvatarAnimation : MonoBehaviour
{
    private const string ClipRoot = "Avatar/Animations/";

    [Tooltip("Cross-fade in/out time for an emote, in seconds.")]
    [SerializeField, Range(0.05f, 1f)] private float blendSeconds = 0.2f;

    /// Emote wire name -> clip file. Wire names are the contract with Dart
    /// (`AvatarEmoteWire` in avatar_stage_config.dart).
    private static readonly Dictionary<string, string> EmoteClips = new()
    {
        { "task_done", "anim_clap" },
        { "level_up", "anim_clap" },
        { "wave", "anim_clap" },
        { "upset", "anim_upset" },
        { "fail", "anim_upset" },
    };

    private PlayableGraph _graph;
    private AnimationMixerPlayable _mixer;
    private AnimationClipPlayable _idle;
    private AnimationClipPlayable _emote;
    private Coroutine _emoteRoutine;
    private Animator _animator;
    private string _gender = "male";

    /// (Re)binds the graph to a freshly spawned body.
    public void Bind(Animator animator, string gender)
    {
        _gender = string.IsNullOrEmpty(gender) ? "male" : gender.ToLowerInvariant();
        _animator = animator;

        Teardown();
        if (_animator == null) return;

        var idleClip = LoadClip($"anim_idle_{_gender}") ?? LoadClip("anim_idle_male");
        if (idleClip == null)
        {
            Debug.LogWarning("[anim] no idle clip found in Resources/" + ClipRoot);
            return;
        }

        _graph = PlayableGraph.Create("HeroAvatar");
        _graph.SetTimeUpdateMode(DirectorUpdateMode.GameTime);

        _mixer = AnimationMixerPlayable.Create(_graph, 2);
        var output = AnimationPlayableOutput.Create(_graph, "HeroAvatarOutput", _animator);
        output.SetSourcePlayable(_mixer);

        _idle = AnimationClipPlayable.Create(_graph, idleClip);
        _idle.SetApplyFootIK(false);
        _graph.Connect(_idle, 0, _mixer, 0);
        _mixer.SetInputWeight(0, 1f);
        _mixer.SetInputWeight(1, 0f);

        _graph.Play();
    }

    /// Plays a one-shot emote over the idle loop. `onFinished` fires with the
    /// same wire name once the clip has played out (the Dart side turns that
    /// into `avatar:emote_finished:<name>`).
    public void PlayEmote(string emote, System.Action<string> onFinished)
    {
        if (string.IsNullOrEmpty(emote)) return;

        if (!_graph.IsValid() || emote == "idle")
        {
            onFinished?.Invoke(emote);
            return;
        }

        if (!EmoteClips.TryGetValue(emote, out var file))
        {
            // Unknown emote: report it as finished immediately rather than
            // leaving Flutter waiting on a callback that never comes.
            onFinished?.Invoke(emote);
            return;
        }

        var clip = LoadClip(file);
        if (clip == null)
        {
            onFinished?.Invoke(emote);
            return;
        }

        if (_emoteRoutine != null) StopCoroutine(_emoteRoutine);
        _emoteRoutine = StartCoroutine(RunEmote(clip, emote, onFinished));
    }

    private IEnumerator RunEmote(AnimationClip clip, string emote, System.Action<string> onFinished)
    {
        DisconnectEmote();

        _emote = AnimationClipPlayable.Create(_graph, clip);
        _emote.SetApplyFootIK(false);
        _graph.Connect(_emote, 0, _mixer, 1);

        var blend = Mathf.Min(blendSeconds, clip.length * 0.25f);
        yield return Fade(0f, 1f, blend);

        var hold = Mathf.Max(clip.length - blend * 2f, 0f);
        if (hold > 0f) yield return new WaitForSeconds(hold);

        yield return Fade(1f, 0f, blend);

        DisconnectEmote();
        _emoteRoutine = null;
        onFinished?.Invoke(emote);
    }

    private IEnumerator Fade(float from, float to, float seconds)
    {
        if (seconds <= 0f)
        {
            SetEmoteWeight(to);
            yield break;
        }

        var elapsed = 0f;
        while (elapsed < seconds)
        {
            elapsed += Time.deltaTime;
            SetEmoteWeight(Mathf.Lerp(from, to, elapsed / seconds));
            yield return null;
        }

        SetEmoteWeight(to);
    }

    private void SetEmoteWeight(float weight)
    {
        if (!_mixer.IsValid()) return;
        _mixer.SetInputWeight(0, 1f - weight);
        _mixer.SetInputWeight(1, weight);
    }

    private void DisconnectEmote()
    {
        if (!_emote.IsValid()) return;
        _graph.Disconnect(_mixer, 1);
        _emote.Destroy();
        SetEmoteWeight(0f);
    }

    private static AnimationClip LoadClip(string file)
    {
        // Clips live INSIDE the FBX, so the direct Load<AnimationClip> misses
        // them — LoadAll returns the sub-assets.
        var direct = Resources.Load<AnimationClip>(ClipRoot + file);
        if (direct != null) return direct;

        foreach (var asset in Resources.LoadAll<AnimationClip>(ClipRoot + file))
        {
            // Skip the __preview__ clips Unity generates in the editor.
            if (asset != null && !asset.name.StartsWith("__")) return asset;
        }

        return null;
    }

    private void Teardown()
    {
        if (_emoteRoutine != null)
        {
            StopCoroutine(_emoteRoutine);
            _emoteRoutine = null;
        }

        if (_graph.IsValid()) _graph.Destroy();
    }

    private void OnDestroy() => Teardown();
}
