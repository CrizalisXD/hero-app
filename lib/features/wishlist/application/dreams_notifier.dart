import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/application/goal_creation_notifier.dart';
import '../data/supabase_dreams_repository.dart';
import '../domain/dream.dart';
import '../domain/dream_follow.dart';

/// Мечта вместе с моим отношением к ней.
///
/// Витрина и «мои мечты» — один и тот же список карточек, отличается лишь
/// фильтр. Поэтому склейка живёт здесь, а не в двух местах UI.
class DreamCard {
  const DreamCard({required this.dream, this.follow});

  final Dream dream;
  final DreamFollow? follow;

  bool get isMine => follow != null;
  bool get isDone => follow?.isDone ?? false;

  /// Мечту ещё никто не пробовал — значит, можно стать первым. Это не
  /// «плохая» мечта с нулевым рейтингом, а незанятая вершина.
  bool get isUncharted => dream.doneCount == 0;
}

class DreamsState {
  const DreamsState({this.cards = const [], this.onlyMine = false});

  final List<DreamCard> cards;
  final bool onlyMine;

  List<DreamCard> get visible =>
      onlyMine ? cards.where((c) => c.isMine).toList() : cards;
}

class DreamsNotifier extends AsyncNotifier<DreamsState> {
  SupabaseDreamsRepository get _repo => ref.read(dreamsRepositoryProvider);

  @override
  Future<DreamsState> build() {
    // Мечта уехала в цель через штатный флоу создания цели. Когда тот
    // завершается успехом и помнит исходную мечту — закрепляем связь
    // converted_goal_id здесь, а не в goals-фиче: направление зависимости
    // wishlist → goals, обратной связи goals не имеет.
    ref.listen(goalCreationProvider, (prev, next) {
      if (next is! GoalCreationDone) return;
      final dreamId = ref.read(goalCreationProvider.notifier).sourceDreamId;
      if (dreamId == null) return;
      _linkGoal(dreamId, next.result.goalId);
    });
    return _load();
  }

  Future<void> _linkGoal(String dreamId, String goalId) async {
    try {
      await _repo.linkGoal(dreamId, goalId);
      await refresh();
    } catch (_) {/* связь не критична — цель уже создана */}
  }

  Future<DreamsState> _load({bool onlyMine = false}) async {
    // Витрина и мои подписки тянутся параллельно: последовательно это две
    // задержки сети на каждом открытии экрана.
    final results = await Future.wait([
      _repo.feed(),
      _repo.myFollows(),
    ]);
    final feed = results[0] as List<Dream>;
    final follows = results[1] as List<DreamFollow>;

    final byId = {for (final f in follows) f.dreamId: f};

    // Мои мечты могут не попасть в топ витрины — дотягиваем их отдельно,
    // иначе фильтр «только мои» показал бы дырявый список.
    final missing =
        byId.keys.where((id) => !feed.any((d) => d.id == id)).toList();
    final extra = await _repo.dreamsByIds(missing);

    final all = [...feed, ...extra];
    return DreamsState(
      cards: [
        for (final d in all) DreamCard(dream: d, follow: byId[d.id]),
      ],
      onlyMine: onlyMine,
    );
  }

  Future<void> refresh() async {
    final onlyMine = state.valueOrNull?.onlyMine ?? false;
    state = await AsyncValue.guard(() => _load(onlyMine: onlyMine));
  }

  void setOnlyMine(bool value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(DreamsState(cards: current.cards, onlyMine: value));
  }

  /// Похожие мечты для подсказки «вы имели в виду ...?» — вызывается на ввод.
  Future<List<Dream>> search(String query) async {
    if (query.trim().length < 2) return const [];
    try {
      return await _repo.search(query);
    } catch (_) {
      return const [];
    }
  }

  /// Захват: найти существующую мечту или завести новую, и подписаться.
  ///
  /// Возвращает id мечты либо null при ошибке. Дедупликацию делает сервер —
  /// клиент не имеет права вставлять в общий справочник.
  Future<String?> wish(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return null;
    try {
      final dreamId = await _repo.findOrCreateDream(trimmed);
      await _repo.follow(dreamId);
      await refresh();
      return dreamId;
    } catch (_) {
      return null;
    }
  }

  /// «Тоже хочу» / отписаться.
  Future<void> toggleWant(String dreamId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final card = current.cards.where((c) => c.dream.id == dreamId).firstOrNull;
    if (card == null) return;

    try {
      if (card.isMine) {
        await _repo.unfollow(dreamId);
      } else {
        await _repo.follow(dreamId);
      }
      await refresh();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> setDone(String dreamId, {required bool done}) async {
    try {
      await _repo.setDone(dreamId, done: done);
      await refresh();
    } catch (_) {
      await refresh();
    }
  }

  /// «Стоило того» — сервер отвергнет оценку без отметки «сделал»
  /// (ck_worth_requires_done), поэтому здесь не выдумываем свою проверку.
  Future<void> setWorth(String dreamId, int? rating) async {
    try {
      await _repo.setWorth(dreamId, rating);
      await refresh();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> voteDifficulty(String dreamId, int value) async {
    try {
      await _repo.voteDifficulty(dreamId, value);
      await refresh();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> setPublic(String dreamId, {required bool isPublic}) async {
    try {
      await _repo.setPublic(dreamId, isPublic: isPublic);
      await refresh();
    } catch (_) {
      await refresh();
    }
  }
}

final dreamsNotifierProvider =
    AsyncNotifierProvider<DreamsNotifier, DreamsState>(DreamsNotifier.new);
