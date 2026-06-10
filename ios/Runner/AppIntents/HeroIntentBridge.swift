import Foundation

/// Names of every intent the Flutter handler knows about. Wire values
/// match the Dart `switch (intent)` in SiriCommandHandler.
@available(iOS 16.0, *)
enum HeroIntentName: String {
    case createTask       = "create_task"
    case createHabit      = "create_habit"
    case completeTask     = "complete_task"
    case askCoach         = "ask_coach"
    case showToday        = "show_today"
    case createGoalDraft  = "create_goal_draft"
}

/// Helper that an Intent.perform() uses to leave a payload for the
/// Flutter side to pick up. We avoid Headless FlutterEngine and instead
/// stash the payload in UserDefaults — AppDelegate.consumePendingIntent
/// reads it once on next foreground.
@available(iOS 16.0, *)
enum HeroIntentBridge {
    static let pendingKey = "hero_pending_intent"

    static func stashPending(intent: HeroIntentName, extra: [String: Any] = [:]) {
        var payload: [String: Any] = [
            "intent": intent.rawValue,
            "ts": Date().timeIntervalSince1970,
        ]
        payload.merge(extra) { _, new in new }
        UserDefaults.standard.set(payload, forKey: pendingKey)
    }
}
