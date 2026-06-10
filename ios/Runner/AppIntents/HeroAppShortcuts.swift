import AppIntents

/// Registers the five voice phrases that Siri can match against.
/// `\(.applicationName)` is replaced with CFBundleDisplayName from
/// Info.plist (currently "hero" — bump to "Hero" if you want the
/// nicer-sounding phrase).
@available(iOS 16.0, *)
struct HeroAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Add task to \(.applicationName)",
                "Добавь задачу в \(.applicationName)",
                "Создай задачу в \(.applicationName)",
            ],
            shortTitle: "Add a task",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: CreateHabitIntent(),
            phrases: [
                "Create a habit in \(.applicationName)",
                "Создай привычку в \(.applicationName)",
            ],
            shortTitle: "Create a habit",
            systemImageName: "flame"
        )
        AppShortcut(
            intent: CompleteTaskIntent(),
            phrases: [
                "Complete a task in \(.applicationName)",
                "Mark task done in \(.applicationName)",
                "Отметь задачу в \(.applicationName)",
                "Заверши задачу в \(.applicationName)",
            ],
            shortTitle: "Complete a task",
            systemImageName: "checkmark.seal"
        )
        AppShortcut(
            intent: AskCoachIntent(),
            phrases: [
                "Ask \(.applicationName) coach",
                "Спроси тренера \(.applicationName)",
            ],
            shortTitle: "Ask coach",
            systemImageName: "bubble.left"
        )
        AppShortcut(
            intent: ShowTodayIntent(),
            phrases: [
                "Show \(.applicationName) today",
                "What's on my \(.applicationName) today",
                "Покажи задачи на сегодня в \(.applicationName)",
            ],
            shortTitle: "Show today",
            systemImageName: "calendar"
        )
    }
}
