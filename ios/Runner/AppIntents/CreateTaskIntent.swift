import AppIntents

@available(iOS 16.0, *)
struct CreateTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add a task in Hero"
    static var description = IntentDescription("Adds a task to your Hero list.")

    @Parameter(title: "Task title", description: "What's the task?")
    var taskTitle: String

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        HeroIntentBridge.stashPending(
            intent: .createTask,
            extra: ["title": taskTitle]
        )
        return .result(dialog: "Adding «\(taskTitle)» to Hero.")
    }
}
