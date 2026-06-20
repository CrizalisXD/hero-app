# Unity avatar — пошаговый гайд (от нуля до экспорта)

Цель: получить Unity-проект, который экспортируется в `hero_app/android/unityLibrary`
и `hero_app/ios/UnityLibrary`. После этого я (Claude) делаю шаги 4–7 из
`UNITY_SETUP.md` и 3D-герой встаёт в центр Home.

Готовый скрипт моста: **`unity_assets/AvatarController.cs`** (копируешь как есть).

---

## 0. Что установить

1. **Unity Hub** → https://unity.com/download
2. В Hub: Installs → Install Editor → **Unity 2022.3 LTS** (любая `2022.3.x`).
   В модулях обязательно отметь:
   - **iOS Build Support**
   - **Android Build Support** (+ Android SDK & NDK Tools, OpenJDK)

> Важно: версия `2022.3` нужна, чтобы совпасть с веткой `fuw-2022.3`
> пакета `flutter_unity_widget`.

## 1. Создать проект

- Hub → New project → шаблон **3D (Core)** → имя `hero_unity`, расположение —
  рядом с `hero_app` (например `Desktop/hero v1.01/hero_unity`).

## 2. Подключить FlutterUnityIntegration

1. Скачай репозиторий `flutter_unity_widget`:
   https://github.com/juicycleff/flutter-unity-view-widget
2. Из него скопируй папку
   `unity/<DemoApp>/Assets/FlutterUnityIntegration/`
   в `hero_unity/Assets/FlutterUnityIntegration/`.
3. Перезапусти Unity. В верхнем меню появится пункт **Flutter** (Export Android /
   Export IOS). Если появился — интеграция подключена.

## 3. Собрать сцену аватара

1. File → New Scene → Save As `Assets/Scenes/Avatar.unity`.
2. Добавь модель героя:
   - на старт можно **Capsule** (GameObject → 3D Object → Capsule) как заглушку,
     потом заменишь на нормальную модель;
   - переименуй объект в **`Avatar`**.
3. Создай пустой объект **`AvatarController`** (GameObject → Create Empty,
   переименуй ровно так).
4. Перетащи `unity_assets/AvatarController.cs` в `Assets/Scripts/`, затем
   перетащи скрипт на объект **AvatarController** (Add Component).
5. На объекте **AvatarController** в инспекторе:
   - **Collider**: добавь любой коллайдер (Add Component → Box Collider) — нужен
     для тапа по аватару. Размести его по фигуре героя.
   - **Tint Target**: перетащи сюда объект `Avatar` (его Renderer) — его материал
     будет краситься в `primaryColor`.
   - **Animator**: см. шаг 4.
6. Камера: расположи `Main Camera` так, чтобы герой был в полный рост по центру
   кадра. Добавь свет (Directional Light уже есть в Core-шаблоне).

## 4. Аниматор и эмоции (можно упростить на старте)

1. Выдели `Avatar` → Add Component → **Animator**.
2. Создай Animator Controller (`Assets/Animations/Avatar.controller`), назначь
   его в Animator.
3. Добавь **Trigger-параметры** ровно с этими именами (важно — совпадают с
   кодом):
   - `idle`, `task_done`, `level_up`, `wave`
4. Сделай состояния под каждый триггер (на старте можно пустые/одинаковые — лишь
   бы переходы работали). Позже подставишь реальные анимации.
5. (Опционально, для точного тайминга) в конце клипа эмоции добавь **Animation
   Event** → функция `NotifyEmoteFinished` со строкой-именем эмоции. Без этого
   сработает безопасный таймер-фолбэк в скрипте.

## 5. Player Settings (Edit → Project Settings → Player)

- **Company Name / Product Name** — на свой вкус.
- **Other Settings → Scripting Backend = IL2CPP**.
- **Target Architectures**: iOS — ARM64; Android — ARMv7 + ARM64.
- iOS → **Bundle Identifier**: поставь такой же, как у Flutter-приложения
  (узнать можно в `hero_app/ios/Runner.xcodeproj` → Bundle Identifier).
- Android → **Minimum API Level** ≥ 21.

## 6. Экспорт в Flutter-проект

1. Меню **Flutter → Export Android** → выбери папку
   `hero_app/android/unityLibrary` (создастся, если нет).
2. Меню **Flutter → Export IOS** → выбери папку
   `hero_app/ios/UnityLibrary`.
3. Дождись «Export complete». Проверь, что папки появились и не пустые.

## 7. Передать мне

Напиши: **«Unity экспортирован»**. Я тогда:
- добавлю `flutter_unity_widget` в `pubspec.yaml`;
- пропишу нативную проводку (Android `settings.gradle` / iOS Podfile);
- добавлю `UnityAvatarBridge` и активирую `_UnityAvatar` в `HeroAvatarStage` за
  флагом `unity_avatar_enabled`;
- соберу на устройство и проверю, что 3D-герой появился в центре Home, а
  плейсхолдер показывается до готовности Unity.

---

## Частые грабли

- **Нет меню «Flutter»** → не та папка FlutterUnityIntegration или не
  перезапущен редактор.
- **iOS не собирается после экспорта** → проверь IL2CPP + ARM64 + что
  `ENABLE_BITCODE = NO` (это я выставлю на шаге 4 рунбука).
- **Чёрный экран вместо аватара** → камера не смотрит на героя / нет света.
- **Тап не работает** → нет коллайдера на `AvatarController` или он не покрывает
  фигуру.
- **Большой вес сборки** → это нормально для Unity; уменьшается стриппингом
  IL2CPP, ASTC-сжатием текстур и LOD (см. раздел Performance в `UNITY_SETUP.md`).
