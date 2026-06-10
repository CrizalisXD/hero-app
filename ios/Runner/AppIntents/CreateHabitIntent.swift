import AppIntents

@available(iOS 16.0, *)
struct CreateHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Create a habit in Hero"
    static var description = IntentDescription("Creates a new habit in Hero.")

    @Parameter(title: "Habit title")
    var habitTitle: String

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        HeroIntentBridge.stashPending(
            intent: .createHabit,
            extra: ["title": habitTitle]
        )
        return .result(dialog: "Adding habit «\(habitTitle)» to Hero.")
    }
}
