# Unity 3D avatar — integration runbook

The Home screen renders the hero through **`HeroAvatarStage`**, a swappable
renderer slot. Today it shows a 2D placeholder. This document is the exact
procedure to drop a **Unity 3D avatar** into that slot, behind the
`unity_avatar_enabled` feature flag.

> ⚠️ The Unity **export step requires Unity Editor** and cannot be produced from
> the Flutter side alone. Until the export exists, **do not** add
> `flutter_unity_widget` to `pubspec.yaml` — the iOS/Android build needs the
> generated `UnityFramework` / `unityLibrary` and will fail to compile without
> it. Everything in steps 4–7 is gated on step 1–3 being done first.

The Flutter-side contract is already in place and dependency-free:
- `lib/features/avatar/unity/avatar_stage_config.dart` — the JSON config +
  emote/event types sent across the bridge.
- `lib/features/avatar/unity/avatar_bridge.dart` — `AvatarBridge` interface +
  `NoopAvatarBridge` (used now). The Unity impl is in step 5.
- Flag: `lib/core/config/feature_flags.dart` → `HERO_UNITY_AVATAR_ENABLED`
  (also a remote flag key `unity_avatar_enabled`).

---

## 1. Unity project + FlutterUnityIntegration

1. Install **Unity 2022.3 LTS** (match the `flutter_unity_widget` `fuw-2022.3`
   branch).
2. Create a Unity project `hero_unity/` (sibling of `hero_app/`).
3. Add the **FlutterUnityIntegration** package: copy `unity/` editor scripts
   from the `flutter_unity_widget` repo (`juicycleff/flutter-unity-view-widget`)
   into `hero_unity/Assets/FlutterUnityIntegration/`. This adds the
   `Flutter → Export Android / Export IOS` menu.
4. Player settings: set scripting backend to **IL2CPP**, target architectures
   ARM64 (iOS) and ARMv7/ARM64 (Android), and **Split Application Binary = off**.

## 2. Avatar scene + C# bridge

Create scene `Assets/Scenes/Avatar.unity` with the avatar model, a camera
framed full-body, and a `GameObject "AvatarController"` with this script:

```csharp
using FlutterUnityIntegration;   // UnityMessageManager
using UnityEngine;

[System.Serializable]
public class AvatarConfig {
    public string primaryColor; public int level; public string renderer;
    public string bodyType; public string faceType; public string hairType;
    public string clothingType; public string unityAvatarId;
}

public class AvatarController : MonoBehaviour {
    void Start() {
        // Tell Flutter we're ready to receive config/emotes.
        UnityMessageManager.Instance.SendMessageToFlutter("avatar:ready");
    }

    // Flutter → Unity: SendMessage("AvatarController", "SetAvatarConfig", json)
    public void SetAvatarConfig(string json) {
        var cfg = JsonUtility.FromJson<AvatarConfig>(json);
        ApplyTint(cfg.primaryColor);
        // TODO: apply bodyType/faceType/hairType/clothingType, swap mesh by unityAvatarId
    }

    // Flutter → Unity: SendMessage("AvatarController", "PlayEmote", "level_up")
    public void PlayEmote(string emote) {
        // TODO: trigger the matching animation state, then:
        UnityMessageManager.Instance.SendMessageToFlutter("avatar:emote_finished:" + emote);
    }

    public void OnAvatarTapped() {
        UnityMessageManager.Instance.SendMessageToFlutter("avatar:tapped");
    }

    void ApplyTint(string hex) { /* parse #RRGGBB → material color */ }
}
```

Message channel naming above (`avatar:ready`, `avatar:tapped`,
`avatar:emote_finished:<name>`) matches the Dart parser in step 5 — keep them in
sync.

## 3. Export to the Flutter project

In Unity: **Flutter → Export Android** and **Flutter → Export IOS**. This writes:
- `hero_app/android/unityLibrary/`
- `hero_app/ios/UnityLibrary/`

Commit these (or keep them as a build artifact per your CI). Re-export whenever
the Unity scene changes.

## 4. Native wiring

**Android** — `android/settings.gradle`:
```gradle
include ":unityLibrary"
project(":unityLibrary").projectDir = file("./unityLibrary")
```
and in `android/app/build.gradle` add `implementation project(':unityLibrary')`.

**iOS** — `ios/Podfile`: add the generated `UnityFramework` pod per the
`flutter_unity_widget` iOS guide; set `ENABLE_BITCODE = NO`.

## 5. Flutter: add the dependency + Unity bridge

`pubspec.yaml`:
```yaml
dependencies:
  flutter_unity_widget: ^2022.2.0
```

Create `lib/features/avatar/unity/unity_avatar_bridge.dart`:

```dart
import 'dart:async';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'avatar_bridge.dart';
import 'avatar_stage_config.dart';

class UnityAvatarBridge implements AvatarBridge {
  UnityWidgetController? _c;
  final _events = StreamController<AvatarEvent>.broadcast();
  bool _ready = false;

  @override
  Stream<AvatarEvent> get events => _events.stream;
  @override
  bool get isReady => _ready;

  void attach(UnityWidgetController c) => _c = c;

  void onUnityMessage(dynamic message) {
    final m = message.toString();
    if (m == 'avatar:ready') { _ready = true; _events.add(const AvatarReady()); }
    else if (m == 'avatar:tapped') { _events.add(const AvatarTapped()); }
    else if (m.startsWith('avatar:emote_finished:')) {
      _events.add(AvatarEmoteFinished(m.split(':').last));
    }
  }

  @override
  Future<void> sendConfig(AvatarStageConfig config) async {
    await _c?.postJsonMessage(
      'AvatarController', 'SetAvatarConfig', config.toJson());
  }

  @override
  Future<void> playEmote(AvatarEmote emote) async {
    await _c?.postMessage('AvatarController', 'PlayEmote', emote.wire);
  }

  @override
  Future<void> dispose() async { await _events.close(); _c?.dispose(); }
}
```

## 6. Flutter: the `_UnityAvatar` widget in the stage slot

In `lib/features/home/presentation/widgets/hero_avatar_stage.dart`, replace the
commented Unity branch with a real one:

```dart
// at top: import 'package:flutter_unity_widget/flutter_unity_widget.dart';
//         import '../../../avatar/unity/unity_avatar_bridge.dart';
//         import '../../../avatar/unity/avatar_stage_config.dart';

if (unityOn) {
  final bridge = UnityAvatarBridge();
  final config = AvatarStageConfig(
    primaryColor: avatar.primaryColor, level: level, renderer: 'unity');
  return UnityWidget(
    onUnityCreated: (c) { bridge.attach(c); bridge.sendConfig(config); },
    onUnityMessage: bridge.onUnityMessage,
    fullscreen: false,
  );
}
```

(For production, hoist the bridge into a Riverpod provider so config/emote calls
— e.g. `playEmote(AvatarEmote.levelUp)` on level-up — can be made from anywhere.)

## 7. Enable

- Local: `flutter run --dart-define-from-file=.env --dart-define=HERO_UNITY_AVATAR_ENABLED=true`
- Remote: flip the `unity_avatar_enabled` feature flag.

When off (default), the app builds and runs with the 2D placeholder and **no
Unity dependency**.

---

## Performance notes (the "lags / size" concern)

- **Size**: a stripped IL2CPP Unity export adds ~30–60 MB. Mitigate with
  asset bundles, texture compression (ASTC), mesh LODs, and stripping unused
  engine modules in Player Settings.
- **Lag**: render the avatar in a *paused* Unity loop and only step it when
  visible (Home foreground). Lower the target frame rate of the Unity view to
  30 fps for an idle avatar. Use `UnityWidget(fullscreen: false)` inside a fixed
  box, not full-screen.
- **Cold start**: Unity init is ~1–2 s. Keep the placeholder visible until
  `AvatarReady`, then cross-fade — the `HeroAvatarStage` slot already isolates
  this so the rest of Home is never blocked.
