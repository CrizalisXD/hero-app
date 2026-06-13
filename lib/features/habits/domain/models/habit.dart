import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';
import 'habit_type.dart';

/// Immutable domain model for a habit.
///
/// Written manually (no Freezed) to work with the broken build_runner
/// (analyzer_plugin 0.12.0 ↔ Dart SDK 3.10.3 incompatibility).
class Habit {
  const Habit({
    required this.id,
    required this.userId,
    this.goalId,
    required this.title,
    this.description,
    this.type = HabitType.good,
    this.lastSlipDate,
    this.inputType = 'boolean',
    this.recurrence = 'daily',
    this.targetValue = 1,
    this.unit,
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.difficulty = TaskDifficulty.normal,
    this.duration = TaskDuration.medium,
    this.importance = TaskImportance.normal,
    this.xpReward = 20,
    this.disciplineXpReward = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isArchived = false,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? goalId;
  final String title;
  final String? description;
  final HabitType type;
  /// For bad habits — last day the user logged a slip. Used to compute
  /// "days since last slip" for display. Null = never slipped.
  final DateTime? lastSlipDate;
  final String inputType;
  final String recurrence;
  final int targetValue;
  final String? unit;
  final CategoryId mainCategory;
  final List<CategoryId> secondaryCategories;
  final TaskDifficulty difficulty;
  final TaskDuration duration;
  final TaskImportance importance;
  final int xpReward;
  final int disciplineXpReward;
  final int currentStreak;
  final int bestStreak;
  final bool isArchived;
  final DateTime createdAt;

  factory Habit.fromJson(Map<String, dynamic> j) {
    final rawSecondaries =
        (j['secondary_categories'] as List<dynamic>?)?.cast<String>() ?? [];
    return Habit(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      goalId: j['goal_id'] as String?,
      title: j['title'] as String,
      description: j['description'] as String?,
      type: HabitType.fromWire(j['type'] as String?),
      lastSlipDate: j['last_slip_date'] == null
          ? null
          : DateTime.parse(j['last_slip_date'] as String),
      inputType: j['input_type'] as String? ?? 'boolean',
      recurrence: j['recurrence'] as String? ?? 'daily',
      targetValue: (j['target_value'] as num?)?.toInt() ?? 1,
      unit: j['unit'] as String?,
      mainCategory:
          CategoryId.fromWire(j['main_category'] as String?) ?? CategoryId.mind,
      secondaryCategories: rawSecondaries
          .map(CategoryId.fromWire)
          .whereType<CategoryId>()
          .toList(),
      difficulty: TaskDifficulty.fromWire(j['difficulty'] as String?),
      duration: TaskDuration.fromWire(j['duration'] as String?),
      importance: TaskImportance.fromWire(j['importance'] as String?),
      xpReward: (j['xp_reward'] as num?)?.toInt() ?? 20,
      disciplineXpReward: (j['discipline_xp_reward'] as num?)?.toInt() ?? 0,
      currentStreak: (j['current_streak'] as num?)?.toInt() ?? 0,
      bestStreak: (j['best_streak'] as num?)?.toInt() ?? 0,
      isArchived: j['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  Habit copyWith({
    String? id,
    String? userId,
    Object? goalId = _sentinel,
    String? title,
    Object? description = _sentinel,
    HabitType? type,
    Object? lastSlipDate = _sentinel,
    String? inputType,
    String? recurrence,
    int? targetValue,
    Object? unit = _sentinel,
    CategoryId? mainCategory,
    List<CategoryId>? secondaryCategories,
    TaskDifficulty? difficulty,
    TaskDuration? duration,
    TaskImportance? importance,
    int? xpReward,
    int? disciplineXpReward,
    int? currentStreak,
    int? bestStreak,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId == _sentinel ? this.goalId : goalId as String?,
      title: title ?? this.title,
      description:
          description == _sentinel ? this.description : description as String?,
      type: type ?? this.type,
      lastSlipDate: lastSlipDate == _sentinel
          ? this.lastSlipDate
          : lastSlipDate as DateTime?,
      inputType: inputType ?? this.inputType,
      recurrence: recurrence ?? this.recurrence,
      targetValue: targetValue ?? this.targetValue,
      unit: unit == _sentinel ? this.unit : unit as String?,
      mainCategory: mainCategory ?? this.mainCategory,
      secondaryCategories: secondaryCategories ?? this.secondaryCategories,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      importance: importance ?? this.importance,
      xpReward: xpReward ?? this.xpReward,
      disciplineXpReward: disciplineXpReward ?? this.disciplineXpReward,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Sentinel for nullable copyWith fields.
const Object _sentinel = Object();

extension HabitDisplay on Habit {
  /// What we actually show under the title.
  ///
  /// • Good habit → server-tracked [currentStreak].
  /// • Bad habit  → days since [lastSlipDate], or since [createdAt] if
  ///   the user has never logged a slip. Always >= 0.
  int get displayStreak {
    if (type == HabitType.good) return currentStreak;
    final reference = lastSlipDate ?? createdAt;
    final now = DateTime.now();
    final ref = DateTime(reference.year, reference.month, reference.day);
    final today = DateTime(now.year, now.month, now.day);
    final delta = today.difference(ref).inDays;
    return delta < 0 ? 0 : delta;
  }
}
