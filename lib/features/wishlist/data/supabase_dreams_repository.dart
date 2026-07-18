import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../categories/domain/models/category_id.dart';
import '../domain/dream.dart';
import '../domain/dream_comment.dart';
import '../domain/dream_doer.dart';
import '../domain/dream_follow.dart';

/// Доступ к общему справочнику мечт.
///
/// Разделение запросов здесь не случайно и повторяет приём социалки:
///   • своё (подписки, голоса, свои реплики) — прямыми запросами, их
///     стережёт RLS «только своя строка»;
///   • чужое (кто сделал, обсуждение, поиск) — через SECURITY DEFINER RPC,
///     потому что RLS-политика не умеет спросить is_blocked_between и
///     заблокированный человек всё равно бы просочился в выдачу.
class SupabaseDreamsRepository {
  SupabaseDreamsRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not_authenticated');
    return id;
  }

  /// Витрина: самые желанные мечты. Читает вью со средними — считать
  /// difficulty_sum/votes на клиенте значит показать «4.7999999».
  Future<List<Dream>> feed({int limit = 50}) async {
    final rows = await _client
        .from('dreams_with_stats')
        .select()
        .order('want_count', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => Dream.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Мои «хочу». Это личное — идёт прямым запросом под RLS.
  Future<List<DreamFollow>> myFollows() async {
    final rows = await _client
        .from('dream_follows')
        .select()
        .eq('user_id', _uid)
        .eq('is_deleted', false)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => DreamFollow.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Мечты, на которые я подписан, одним запросом — чтобы витрина знала,
  /// что у меня уже есть, без N+1.
  Future<List<Dream>> dreamsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows =
        await _client.from('dreams_with_stats').select().inFilter('id', ids);
    return (rows as List)
        .map((e) => Dream.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Похожие мечты для подсказки «вы имели в виду ...?».
  Future<List<Dream>> search(String query) async {
    final rows = await _client.rpc<dynamic>(
      'search_dreams',
      params: {'p_query': query},
    );
    return (rows as List? ?? [])
        .map((e) => Dream.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Найти существующую мечту или завести новую.
  ///
  /// Клиент сознательно не вставляет в `dreams` напрямую (и RLS ему не даст):
  /// дедупликация обязана происходить на сервере, иначе «Прыгнуть с
  /// парашютом» и «прыгнуть с парашютом» станут двумя мечтами, и
  /// обсуждение расколется надвое.
  Future<String> findOrCreateDream(String title, {CategoryId? category}) async {
    final id = await _client.rpc<dynamic>(
      'find_or_create_dream',
      params: {'p_title': title.trim(), 'p_category': category?.wire},
    );
    return id as String;
  }

  /// «Тоже хочу».
  Future<DreamFollow> follow(String dreamId) async {
    final row = await _client
        .from('dream_follows')
        .upsert(
          {'dream_id': dreamId, 'user_id': _uid, 'is_deleted': false},
          onConflict: 'dream_id,user_id',
        )
        .select()
        .single();
    return DreamFollow.fromJson(row);
  }

  Future<void> unfollow(String dreamId) async {
    await _client
        .from('dream_follows')
        .update({'is_deleted': true})
        .eq('dream_id', dreamId)
        .eq('user_id', _uid);
  }

  /// Отметить сделанной. Снятие отметки обязано занулить и оценку: без
  /// done_at оценка «стоило того» не имеет права на существование, и БД
  /// отвергнет её через ck_worth_requires_done.
  Future<void> setDone(String dreamId, {required bool done}) async {
    await _client
        .from('dream_follows')
        .update({
          'done_at': done ? DateTime.now().toUtc().toIso8601String() : null,
          if (!done) 'worth_rating': null,
        })
        .eq('dream_id', dreamId)
        .eq('user_id', _uid);
  }

  /// «Стоило того», 1..5. Ставится только сделавшим.
  Future<void> setWorth(String dreamId, int? rating) async {
    await _client
        .from('dream_follows')
        .update({'worth_rating': rating})
        .eq('dream_id', dreamId)
        .eq('user_id', _uid);
  }

  /// Показывать ли меня в «кто уже сделал». По умолчанию нет.
  Future<void> setPublic(String dreamId, {required bool isPublic}) async {
    await _client
        .from('dream_follows')
        .update({'is_public': isPublic})
        .eq('dream_id', dreamId)
        .eq('user_id', _uid);
  }

  Future<void> setNote(String dreamId, String? note) async {
    await _client
        .from('dream_follows')
        .update({'note': note})
        .eq('dream_id', dreamId)
        .eq('user_id', _uid);
  }

  Future<void> linkGoal(String dreamId, String goalId) async {
    await _client
        .from('dream_follows')
        .update({'converted_goal_id': goalId})
        .eq('dream_id', dreamId)
        .eq('user_id', _uid);
  }

  /// Голос за сложность реализации.
  Future<void> voteDifficulty(String dreamId, int value) async {
    await _client.from('dream_difficulty_votes').upsert(
      {'dream_id': dreamId, 'user_id': _uid, 'value': value},
      onConflict: 'dream_id,user_id',
    );
  }

  Future<int?> myDifficultyVote(String dreamId) async {
    final row = await _client
        .from('dream_difficulty_votes')
        .select('value')
        .eq('dream_id', dreamId)
        .eq('user_id', _uid)
        .maybeSingle();
    return (row?['value'] as num?)?.toInt();
  }

  Future<List<DreamDoer>> doers(String dreamId) async {
    final rows = await _client.rpc<dynamic>(
      'list_dream_doers',
      params: {'p_dream_id': dreamId},
    );
    return (rows as List? ?? [])
        .map((e) => DreamDoer.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<DreamComment>> comments(String dreamId) async {
    final rows = await _client.rpc<dynamic>(
      'list_dream_comments',
      params: {'p_dream_id': dreamId},
    );
    return (rows as List? ?? [])
        .map((e) => DreamComment.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> addComment(String dreamId, String body) async {
    await _client.from('dream_comments').insert({
      'dream_id': dreamId,
      'user_id': _uid,
      'body': body.trim(),
    });
  }

  Future<void> deleteComment(String id) async {
    await _client
        .from('dream_comments')
        .update({'is_deleted': true})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> report(
    String targetType,
    String targetId,
    String? reason,
  ) async {
    await _client.from('dream_reports').upsert(
      {
        'target_type': targetType,
        'target_id': targetId,
        'user_id': _uid,
        'reason': reason,
      },
      onConflict: 'target_type,target_id,user_id',
    );
  }
}

final dreamsRepositoryProvider = Provider<SupabaseDreamsRepository>(
  (ref) => SupabaseDreamsRepository(ref.watch(supabaseClientProvider)),
);
