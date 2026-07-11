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
                "Create a task in \(.applicationName)",
                "New task in \(.applicationName)",
                "Add a quest in \(.applicationName)",
                "Добавь задачу в \(.applicationName)",
                "Создай задачу в \(.applicationName)",
                "Добавить задачу в \(.applicationName)",
                "Новая задача в \(.applicationName)",
                "Запиши задачу в \(.applicationName)",
                "Добавь квест в \(.applicationName)",
            ],
            shortTitle: "Add a task",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: CreateHabitIntent(),
            phrases: [
                "Create a habit in \(.applicationName)",
                "Add a habit in \(.applicationName)",
                "New habit in \(.applicationName)",
                "Start a habit in \(.applicationName)",
                "Создай привычку в \(.applicationName)",
                "Добавь привычку в \(.applicationName)",
                "Новая привычка в \(.applicationName)",
                "Заведи привычку в \(.applicationName)",
            ],
            shortTitle: "Create a habit",
            systemImageName: "flame"
        )
        AppShortcut(
            intent: CompleteTaskIntent(),
            phrases: [
                "Complete a task in \(.applicationName)",
                "Mark task done in \(.applicationName)",
                "Finish a task in \(.applicationName)",
                "Check off a task in \(.applicationName)",
                "Отметь задачу в \(.applicationName)",
                "Заверши задачу в \(.applicationName)",
                "Выполни задачу в \(.applicationName)",
                "Закрой задачу в \(.applicationName)",
                "Задача выполнена в \(.applicationName)",
            ],
            shortTitle: "Complete a task",
            systemImageName: "checkmark.seal"
        )
        AppShortcut(
            intent: AskCoachIntent(),
            phrases: [
                "Ask \(.applicationName) coach",
                "Talk to \(.applicationName) coach",
                "Open coach in \(.applicationName)",
                "Спроси тренера \(.applicationName)",
                "Открой тренера в \(.applicationName)",
                "Поговори с тренером \(.applicationName)",
                "Открой коуча в \(.applicationName)",
            ],
            shortTitle: "Ask coach",
            systemImageName: "bubble.left"
        )
        AppShortcut(
            intent: ShowTodayIntent(),
            phrases: [
                "Show \(.applicationName) today",
                "What's on my \(.applicationName) today",
                "Show my tasks in \(.applicationName)",
                "Open my day in \(.applicationName)",
                "Покажи задачи на сегодня в \(.applicationName)",
                "Что у меня на сегодня в \(.applicationName)",
                "Покажи мой день в \(.applicationName)",
                "Открой задачи в \(.applicationName)",
            ],
            shortTitle: "Show today",
            systemImageName: "calendar"
        )
    }
}
