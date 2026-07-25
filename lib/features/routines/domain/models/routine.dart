/// One step of a routine — a small action, optionally time-boxed.
class RoutineStep {
  const RoutineStep({
    required this.id,
    required this.title,
    this.durationMinutes,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final int? durationMinutes;
  final int sortOrder;

  factory RoutineStep.fromJson(Map<String, dynamic> j) => RoutineStep(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        durationMinutes: (j['duration_minutes'] as num?)?.toInt(),
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      );
}

/// A routine: an ordered bundle of steps done together, once per day.
class Routine {
  const Routine({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.reminderEnabled,
    required this.xpReward,
    required this.currentStreak,
    required this.bestStreak,
    required this.sortOrder,
    required this.steps,
  });

  final String id;
  final String title;

  /// "HH:mm" local time-of-day for the daily reminder, or null.
  final String? scheduledTime;
  final bool reminderEnabled;
  final int xpReward;
  final int currentStreak;
  final int bestStreak;
  final int sortOrder;
  final List<RoutineStep> steps;

  int get totalMinutes =>
      steps.fold(0, (sum, s) => sum + (s.durationMinutes ?? 0));

  Routine copyWith({int? currentStreak, int? bestStreak}) => Routine(
        id: id,
        title: title,
        scheduledTime: scheduledTime,
        reminderEnabled: reminderEnabled,
        xpReward: xpReward,
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
        sortOrder: sortOrder,
        steps: steps,
      );

  /// Parses `scheduled_time` (Postgres TIME, e.g. "07:30:00") into "HH:mm".
  static String? _parseTime(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  factory Routine.fromJson(Map<String, dynamic> j) {
    final rawSteps = j['routine_steps'] ?? j['steps'];
    final steps = rawSteps is List
        ? (rawSteps
            .map(
              (e) => RoutineStep.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
        : <RoutineStep>[];
    return Routine(
      id: j['id'] as String,
      title: j['title'] as String? ?? '',
      scheduledTime: _parseTime(j['scheduled_time']),
      reminderEnabled: j['reminder_enabled'] as bool? ?? false,
      xpReward: (j['xp_reward'] as num?)?.toInt() ?? 25,
      currentStreak: (j['current_streak'] as num?)?.toInt() ?? 0,
      bestStreak: (j['best_streak'] as num?)?.toInt() ?? 0,
      sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      steps: steps,
    );
  }
}

/// View-model: routines + the set of ids already completed today.
class RoutinesView {
  const RoutinesView({required this.routines, required this.completedToday});

  final List<Routine> routines;
  final Set<String> completedToday;

  bool isDoneToday(String id) => completedToday.contains(id);

  RoutinesView copyWith({
    List<Routine>? routines,
    Set<String>? completedToday,
  }) =>
      RoutinesView(
        routines: routines ?? this.routines,
        completedToday: completedToday ?? this.completedToday,
      );
}
