import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_dreams_repository.dart';
import '../domain/dream.dart';
import '../domain/dream_comment.dart';
import '../domain/dream_doer.dart';
import 'dreams_notifier.dart';

/// Всё, что показывает детальный экран одной мечты, собранное вместе:
/// сама мечта со счётчиками, мои отношения с ней, кто её сделал, обсуждение
/// и мой голос за сложность.
class DreamDetail {
  const DreamDetail({
    required this.card,
    required this.doers,
    required this.comments,
    this.myDifficultyVote,
  });

  final DreamCard card;
  final List<DreamDoer> doers;
  final List<DreamComment> comments;

  /// Мой голос за сложность (1..5), null — ещё не голосовал.
  final int? myDifficultyVote;

  Dream get dream => card.dream;
}

/// Аргумент — id мечты. `.family`, потому что экран открывается для
/// конкретной мечты, а не для «текущей».
class DreamDetailNotifier extends FamilyAsyncNotifier<DreamDetail, String> {
  SupabaseDreamsRepository get _repo => ref.read(dreamsRepositoryProvider);

  @override
  Future<DreamDetail> build(String dreamId) => _load(dreamId);

  Future<DreamDetail> _load(String dreamId) async {
    // Карточку (мечта + моя подписка) берём из общего списка, если он уже
    // загружен — не гонять сеть ради данных, что уже есть на экране-списке.
    final listState = ref.read(dreamsNotifierProvider).valueOrNull;
    var card = listState?.cards.where((c) => c.dream.id == dreamId).firstOrNull;

    // Открыли по прямой ссылке (список ещё не грузился) — дотягиваем точечно.
    if (card == null) {
      final dreams = await _repo.dreamsByIds([dreamId]);
      final follows = await _repo.myFollows();
      final dream = dreams.firstOrNull;
      if (dream == null) throw StateError('dream_not_found');
      card = DreamCard(
        dream: dream,
        follow: follows.where((f) => f.dreamId == dreamId).firstOrNull,
      );
    }

    final results = await Future.wait([
      _repo.doers(dreamId),
      _repo.comments(dreamId),
      _repo.myDifficultyVote(dreamId),
    ]);

    return DreamDetail(
      card: card,
      doers: results[0] as List<DreamDoer>,
      comments: results[1] as List<DreamComment>,
      myDifficultyVote: results[2] as int?,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load(arg));
  }

  Future<void> toggleWant() async {
    await ref.read(dreamsNotifierProvider.notifier).toggleWant(arg);
    await refresh();
  }

  Future<void> setDone({required bool done}) async {
    await ref.read(dreamsNotifierProvider.notifier).setDone(arg, done: done);
    await refresh();
  }

  Future<void> setWorth(int? rating) async {
    await ref.read(dreamsNotifierProvider.notifier).setWorth(arg, rating);
    await refresh();
  }

  Future<void> setPublic({required bool isPublic}) async {
    await ref
        .read(dreamsNotifierProvider.notifier)
        .setPublic(arg, isPublic: isPublic);
    await refresh();
  }

  Future<void> voteDifficulty(int value) async {
    await ref.read(dreamsNotifierProvider.notifier).voteDifficulty(arg, value);
    await refresh();
  }

  Future<bool> addComment(String body) async {
    final text = body.trim();
    if (text.isEmpty) return false;
    try {
      await _repo.addComment(arg, text);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Пометить мечту уехавшей в цель (converted_goal_id). Саму цель создаёт
  /// штатный флоу целей — здесь только фиксируем связь.
  Future<void> linkGoal(String goalId) async {
    try {
      await _repo.linkGoal(arg, goalId);
      await refresh();
    } catch (_) {/* связь не критична для работы экрана */}
  }

  Future<void> report(String reason) async {
    try {
      await _repo.report('dream', arg, reason);
    } catch (_) {}
  }
}

final dreamDetailProvider = AsyncNotifierProviderFamily<DreamDetailNotifier,
    DreamDetail, String>(
  DreamDetailNotifier.new,
);
