/// Milestone row from `public.milestones`. Represents a coarse "I'm
/// done with chapter N" checkpoint within a goal — not a recurring
/// task and not a habit, just a one-time accomplishment with XP.
class Milestone {
  const Milestone({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.title,
    this.description,
    required this.xpReward,
    required this.isDone,
    this.targetDate,
    this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  final String userId;
  final String title;
  final String? description;
  final int xpReward;
  final bool isDone;
  final DateTime? targetDate;
  final DateTime? completedAt;
  final DateTime createdAt;

  factory Milestone.fromJson(Map<String, dynamic> j) => Milestone(
        id: j['id'] as String,
        goalId: j['goal_id'] as String,
        userId: j['user_id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        xpReward: (j['xp_reward'] as num?)?.toInt() ?? 50,
        isDone: j['is_done'] as bool? ?? false,
        targetDate: j['target_date'] == null
            ? null
            : DateTime.parse(j['target_date'] as String),
        completedAt: j['completed_at'] == null
            ? null
            : DateTime.parse(j['completed_at'] as String),
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Milestone copyWith({bool? isDone, DateTime? completedAt}) {
    return Milestone(
      id: id,
      goalId: goalId,
      userId: userId,
      title: title,
      description: description,
      xpReward: xpReward,
      isDone: isDone ?? this.isDone,
      targetDate: targetDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}
