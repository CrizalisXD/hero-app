import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';

class Task {
  const Task({
    required this.id,
    required this.userId,
    this.goalId,
    required this.title,
    this.description,
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.difficulty = TaskDifficulty.normal,
    this.duration = TaskDuration.medium,
    this.importance = TaskImportance.normal,
    this.xpReward = 20,
    this.disciplineXpReward = 0,
    this.isDone = false,
    this.isRecurring = false,
    this.recurrence,
    this.dueDate,
    this.dueAt,
    this.completedAt,
    this.externalCalendarEventId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? goalId;
  final String title;
  final String? description;
  final CategoryId mainCategory;
  final List<CategoryId> secondaryCategories;
  final TaskDifficulty difficulty;
  final TaskDuration duration;
  final TaskImportance importance;
  final int xpReward;
  final int disciplineXpReward;
  final bool isDone;
  final bool isRecurring;
  final String? recurrence;
  final DateTime? dueDate;
  final DateTime? dueAt;
  final DateTime? completedAt;
  /// Set when this task has been mirrored into the device calendar.
  /// CalendarSyncAgent uses this to detect deletions on the OS side.
  final String? externalCalendarEventId;
  final DateTime createdAt;

  factory Task.fromJson(Map<String, dynamic> j) {
    final rawSecondaries =
        (j['secondary_categories'] as List<dynamic>?)?.cast<String>() ?? [];
    return Task(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      goalId: j['goal_id'] as String?,
      title: j['title'] as String,
      description: j['description'] as String?,
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
      disciplineXpReward:
          (j['discipline_xp_reward'] as num?)?.toInt() ?? 0,
      isDone: j['is_done'] as bool? ?? false,
      isRecurring: j['is_recurring'] as bool? ?? false,
      recurrence: j['recurrence'] as String?,
      dueDate: j['due_date'] == null
          ? null
          : DateTime.parse(j['due_date'] as String),
      dueAt: j['due_at'] == null
          ? null
          : DateTime.parse(j['due_at'] as String),
      completedAt: j['completed_at'] == null
          ? null
          : DateTime.parse(j['completed_at'] as String),
      externalCalendarEventId:
          j['external_calendar_event_id'] as String?,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  Task copyWith({
    String? id,
    String? userId,
    Object? goalId = _sentinel,
    String? title,
    Object? description = _sentinel,
    CategoryId? mainCategory,
    List<CategoryId>? secondaryCategories,
    TaskDifficulty? difficulty,
    TaskDuration? duration,
    TaskImportance? importance,
    int? xpReward,
    int? disciplineXpReward,
    bool? isDone,
    bool? isRecurring,
    Object? recurrence = _sentinel,
    Object? dueDate = _sentinel,
    Object? dueAt = _sentinel,
    Object? completedAt = _sentinel,
    Object? externalCalendarEventId = _sentinel,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId == _sentinel ? this.goalId : goalId as String?,
      title: title ?? this.title,
      description:
          description == _sentinel ? this.description : description as String?,
      mainCategory: mainCategory ?? this.mainCategory,
      secondaryCategories: secondaryCategories ?? this.secondaryCategories,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      importance: importance ?? this.importance,
      xpReward: xpReward ?? this.xpReward,
      disciplineXpReward: disciplineXpReward ?? this.disciplineXpReward,
      isDone: isDone ?? this.isDone,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence:
          recurrence == _sentinel ? this.recurrence : recurrence as String?,
      dueDate: dueDate == _sentinel ? this.dueDate : dueDate as DateTime?,
      dueAt: dueAt == _sentinel ? this.dueAt : dueAt as DateTime?,
      completedAt: completedAt == _sentinel
          ? this.completedAt
          : completedAt as DateTime?,
      externalCalendarEventId: externalCalendarEventId == _sentinel
          ? this.externalCalendarEventId
          : externalCalendarEventId as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Sentinel for nullable copyWith fields.
const Object _sentinel = Object();
