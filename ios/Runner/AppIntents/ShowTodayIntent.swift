import AppIntents

@available(iOS 16.0, *)
struct ShowTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Hero today"
    static var description = IntentDescription("Opens Hero showing today's tasks.")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        HeroIntentBridge.stashPending(intent: .showToday)
        return .result(dialog: "Opening Hero.")
    }
}
