import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var siriChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

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
