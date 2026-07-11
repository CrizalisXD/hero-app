import Flutter
import UIKit
import flutter_unity_widget

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var siriChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Hand the real argc/argv to Unity BEFORE any UnityWidget boots the
        // framework. Without this, runEmbedded(withArgc: 0, argv: nil) makes
        // Unity's BootConfigData::SetFromParameters dereference null → crash.
        InitUnityIntegrationWithOptions(
            argc: CommandLine.argc,
            argv: CommandLine.unsafeArgv,
            launchOptions
        )

        GeneratedPluginRegistrant.register(with: self)

        // КЛЮЧЕВОЕ для прозрачного Unity: базовый слой Flutter должен быть
        // non-opaque, иначе «дыра», которую Flutter вырезает под platform
        // view, компонуется как непрозрачный чёрный RGB и закрывает
        // подложку. Вместе с installUnderlayBackground ниже это даёт городу
        // просвечивать сквозь прозрачный Unity-слой.
        (window?.rootViewController as? FlutterViewController)?.isViewOpaque = false

        // После полного становления окна (следующий тик main loop).
        DispatchQueue.main.async { [weak self] in
            self?.installUnderlayBackground()
            // Страховка: глушим непрозрачность базового Flutter-слоя
            // напрямую, в обход сеттера движка (вдруг вью уже создан и
            // сеттер не пропагировал).
            if let fvc = self?.window?.rootViewController as? FlutterViewController {
                fvc.isViewOpaque = false
                fvc.viewIfLoaded?.isOpaque = false
                fvc.viewIfLoaded?.backgroundColor = .clear
                fvc.viewIfLoaded?.layer.isOpaque = false
            }
        }

        if let controller = window?.rootViewController as? FlutterViewController {
            siriChannel = FlutterMethodChannel(
                name: "hero.siri",
                binaryMessenger: controller.binaryMessenger
            )
            siriChannel?.setMethodCallHandler { [weak self] call, result in
                switch call.method {
                case "consume_pending_intent":
                    result(self?.consumePendingIntent())
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// Flutter «пробивает дыру» в своём базовом слое под platform view
    /// (Unity), считая его непрозрачным. Наш Unity-слой прозрачен, поэтому
    /// сквозь дыру видно дно окна (чёрное). Кладём ту же фоновую картинку,
    /// что рисует Flutter (_CinematicBackground → home_bg.jpg), ПОД
    /// FlutterView — дыра показывает её, и фон становится бесшовным.
    private func installUnderlayBackground() {
        guard let window = self.window,
              let rootView = window.rootViewController?.view else { return }

        let key = FlutterDartProject.lookupKey(forAsset: "assets/images/home_bg.jpg")
        guard let path = Bundle.main.path(forResource: key, ofType: nil),
              let image = UIImage(contentsOfFile: path) else {
            // Нет ассета — хотя бы не чёрное дно, а цвет фона приложения.
            window.backgroundColor = UIColor(
                red: 0x0B / 255.0, green: 0x0E / 255.0,
                blue: 0x1A / 255.0, alpha: 1
            )
            return
        }

        let bg = UIImageView(image: image)
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        bg.frame = window.bounds
        bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // at:0 — всегда валидно, не требует членства rootView в окне.
        _ = rootView // силой грузим view контроллера до вставки подложки
        window.insertSubview(bg, at: 0)
    }

    /// Reads and clears the payload an App Intent wrote to UserDefaults.
    /// Flutter pulls this on app launch and on every `resumed` lifecycle
    /// event, so commands fired from background hit on next foreground.
    private func consumePendingIntent() -> [String: Any]? {
        let defaults = UserDefaults.standard
        guard let payload = defaults.dictionary(forKey: "hero_pending_intent") else {
            return nil
        }
        defaults.removeObject(forKey: "hero_pending_intent")
        return payload
    }
}
