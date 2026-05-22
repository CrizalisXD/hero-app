class TaskCompletionResult {
  const TaskCompletionResult({
    required this.ok,
    required this.duplicate,
    required this.taskId,
    required this.categoryXp,
    required this.disciplineXp,
    required this.levelBefore,
    required this.levelAfter,
    required this.levelsGained,
  });

  final bool ok;
  final bool duplicate;
  final String taskId;
  final int categoryXp;
  final int disciplineXp;
  final int levelBefore;
  final int levelAfter;
  final int levelsGained;

  factory TaskCompletionResult.fromRpc(Map<String, dynamic> j) {
    final character =
        (j['character'] as Map<String, dynamic>?) ?? const {};
    return TaskCompletionResult(
      ok: j['ok'] as bool? ?? false,
      duplicate: j['duplicate'] as bool? ?? false,
      taskId: j['task_id'] as String? ?? '',
      categoryXp: (j['category_xp'] as num?)?.toInt() ?? 0,
      disciplineXp: (j['discipline_xp'] as num?)?.toInt() ?? 0,
      levelBefore: (character['level_before'] as num?)?.toInt() ?? 0,
      levelAfter: (character['level_after'] as num?)?.toInt() ?? 0,
      levelsGained: (character['levels_gained'] as num?)?.toInt() ?? 0,
    );
  }
}
