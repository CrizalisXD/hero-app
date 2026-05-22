import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/categories_assets_repository.dart';
import '../domain/models/category_rules.dart';
import '../domain/models/xp_inputs.dart';

/// category_xp = base_xp × difficulty × duration × importance  (§16.2)
class XpEngine {
  const XpEngine(this._bundle);
  final CategoryRulesBundle _bundle;

  int categoryXp({
    required int baseXp,
    required TaskDifficulty difficulty,
    required TaskDuration duration,
    required TaskImportance importance,
  }) {
    final d = _bundle.multipliers.difficulty[difficulty.wire] ?? 1.0;
    final u = _bundle.multipliers.duration[duration.wire] ?? 1.0;
    final i = _bundle.multipliers.importance[importance.wire] ?? 1.0;
    return (baseXp * d * u * i).round();
  }

  int disciplineXpForTask({required bool isRecurring}) =>
      isRecurring
          ? (_bundle.metaStats.disciplineXp['complete_daily_task'] ?? 3)
          : 0;

  int disciplineXpForHabit() =>
      _bundle.metaStats.disciplineXp['complete_habit'] ?? 4;
}

final xpEngineProvider = FutureProvider<XpEngine>((ref) async {
  final bundle = await ref.watch(categoryRulesProvider.future);
  return XpEngine(bundle);
});
