import AppIntents

@available(iOS 16.0, *)
struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete task in Hero"
    static var description = IntentDescription("Marks the closest matching task as done.")

    @Parameter(title: "Task name")
    var taskName: String

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        HeroIntentBridge.stashPending(
            intent: .completeTask,
            extra: ["title": taskName]
        )
        return .result(dialog: "Completing «\(taskName)» in Hero.")
    }
}
