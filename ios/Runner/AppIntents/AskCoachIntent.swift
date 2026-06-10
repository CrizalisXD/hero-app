import AppIntents

@available(iOS 16.0, *)
struct AskCoachIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask Hero coach"
    static var description = IntentDescription("Opens Hero coach to ask a question.")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        HeroIntentBridge.stashPending(intent: .askCoach)
        return .result(dialog: "Opening Hero coach.")
    }
}
