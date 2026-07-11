import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../categories/application/category_classifier_service.dart';
import '../../categories/application/xp_engine.dart';
import '../../categories/data/categories_assets_repository.dart';
import '../../categories/data/categories_db_repository.dart';
import '../../categories/domain/models/category_id.dart';
import '../../categories/domain/models/xp_inputs.dart';
import '../../energy/data/energy_service.dart';
import '../../habits/application/habits_notifier.dart';
import '../../habits/domain/models/create_habit_input.dart';
import '../../tasks/application/tasks_notifier.dart';
import '../../tasks/domain/models/create_task_input.dart';
import '../data/voice_command_logs_repository.dart';
import 'siri_channel.dart';

/// Pulls the pending Siri intent (if any) and dispatches it to the
/// existing notifiers / router. Always writes a row to
/// voice_command_logs — success or failure — so we have audit coverage.
class SiriCommandHandler {
  SiriCommandHandler(this._ref);
  final Ref _ref;

  Future<void> handlePendingIfAny(BuildContext context) async {
    final payload = await SiriChannel.consumePending();
    if (payload == null) return;

    final intent = payload['intent'] as String? ?? '';
    final logger = _ref.read(voiceCommandLogsRepositoryProvider);

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      await logger.log(
        intentName: intent,
        status: 'failed',
        resultPayload: const {'reason': 'not_authenticated'},
      );
      return;
    }

    switch (intent) {
      case 'create_task':
        await _createTask(payload['title'] as String? ?? '');
      case 'create_habit':
        await _createHabit(payload['title'] as String? ?? '');
      case 'complete_task':
        await _completeTask(payload['title'] as String? ?? '');
      case 'ask_coach':
        await logger.log(intentName: intent, status: 'success');
        if (context.mounted) context.go('/coach');
      case 'show_today':
        await logger.log(intentName: intent, status: 'success');
        if (context.mounted) context.go('/home');
      default:
        await logger.log(
          intentName: intent,
          status: 'failed',
          resultPayload: const {'reason': 'unknown_intent'},
        );
    }
  }

  /// Mirrors EnergyGuard.spendOrBlock for the headless voice path:
  /// fail closed when the server refuses or errors, fail open only on
  /// transport failures (offline/timeout). No dialog — callers log
  /// `not_enough_energy` to voice_command_logs instead.
  Future<bool> _spendEnergy(int amount) async {
    try {
      final res = await _ref.read(energyServiceProvider).spend(amount);
      return res.ok;
    } on PostgrestException catch (e) {
      debugPrint('siri energy spend rejected: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('siri energy spend infra err: $e');
      return true;
    }
  }

  Future<void> _createTask(String title) async {
    final logger = _ref.read(voiceCommandLogsRepositoryProvider);
    if (title.trim().length < 2) {
      await logger.log(
        intentName: 'create_task',
        transcript: title,
        status: 'failed',
        resultPayload: const {'reason': 'empty_title'},
      );
      return;
    }
    try {
      final svc =
          await _ref.read(categoryClassifierServiceProvider.future);
      final cls = await svc.classify(text: title);
      final bundle = await _ref.read(categoryRulesProvider.future);
      final engine = XpEngine(bundle);
      final main =
          cls.isConfident ? cls.mainCategory : CategoryId.mind;
      // [D4] base_xp — из БД; серверный пересчёт всё равно главнее (D5).
      final baseXpMap =
          await _ref.read(categoryBaseXpProvider.future);
      final baseXp = baseXpMap[main] ?? bundle.defaultBaseXp;
      final xp = engine.categoryXp(
        baseXp: baseXp,
        difficulty: TaskDifficulty.normal,
        duration: TaskDuration.medium,
        importance: TaskImportance.normal,
      );
      final input = CreateTaskInput(
        title: title,
        mainCategory: main,
        difficulty: TaskDifficulty.normal,
        duration: TaskDuration.medium,
        importance: TaskImportance.normal,
        xpReward: xp,
      );
      if (!await _spendEnergy(EnergyCosts.taskNormal)) {
        await logger.log(
          intentName: 'create_task',
          transcript: title,
          status: 'failed',
          resultPayload: const {'reason': 'not_enough_energy'},
        );
        return;
      }
      final task =
          await _ref.read(tasksNotifierProvider.notifier).createTask(input);
      await logger.log(
        intentName: 'create_task',
        transcript: title,
        status: task == null ? 'failed' : 'success',
        resultPayload: task == null
            ? const {}
            : {'task_id': task.id, 'category': main.wire},
      );
    } catch (e) {
      await logger.log(
        intentName: 'create_task',
        transcript: title,
        status: 'failed',
        resultPayload: {'error': e.toString()},
      );
    }
  }

  Future<void> _createHabit(String title) async {
    final logger = _ref.read(voiceCommandLogsRepositoryProvider);
    if (title.trim().length < 2) {
      await logger.log(
        intentName: 'create_habit',
        transcript: title,
        status: 'failed',
        resultPayload: const {'reason': 'empty_title'},
      );
      return;
    }
    try {
      final svc =
          await _ref.read(categoryClassifierServiceProvider.future);
      final cls = await svc.classify(text: title, entityType: 'habit');
      final bundle = await _ref.read(categoryRulesProvider.future);
      final engine = XpEngine(bundle);
      final main =
          cls.isConfident ? cls.mainCategory : CategoryId.mind;
      // [D4] base_xp — из БД; серверный пересчёт всё равно главнее (D5).
      final baseXpMap =
          await _ref.read(categoryBaseXpProvider.future);
      final baseXp = baseXpMap[main] ?? bundle.defaultBaseXp;
      final xp = engine.categoryXp(
        baseXp: baseXp,
        difficulty: TaskDifficulty.easy,
        duration: TaskDuration.short,
        importance: TaskImportance.normal,
      );
      final input = CreateHabitInput(
        title: title,
        mainCategory: main,
        difficulty: TaskDifficulty.easy,
        duration: TaskDuration.short,
        importance: TaskImportance.normal,
        xpReward: xp,
        disciplineXpReward: engine.disciplineXpForHabit(),
      );
      if (!await _spendEnergy(EnergyCosts.habitGood)) {
        await logger.log(
          intentName: 'create_habit',
          transcript: title,
          status: 'failed',
          resultPayload: const {'reason': 'not_enough_energy'},
        );
        return;
      }
      final habit = await _ref
          .read(habitsNotifierProvider.notifier)
          .createHabit(input);
      await logger.log(
        intentName: 'create_habit',
        transcript: title,
        status: habit == null ? 'failed' : 'success',
        resultPayload: habit == null
            ? const {}
            : {'habit_id': habit.id, 'category': main.wire},
      );
    } catch (e) {
      await logger.log(
        intentName: 'create_habit',
        transcript: title,
        status: 'failed',
        resultPayload: {'error': e.toString()},
      );
    }
  }

  Future<void> _completeTask(String query) async {
    final logger = _ref.read(voiceCommandLogsRepositoryProvider);
    final q = query.toLowerCase().trim();
    if (q.length < 2) {
      await logger.log(
        intentName: 'complete_task',
        transcript: query,
        status: 'failed',
        resultPayload: const {'reason': 'empty_query'},
      );
      return;
    }
    try {
      // Await the load rather than reading .value: on a Siri cold start
      // the notifier hasn't fetched yet and .value would be an empty
      // list → every voice completion logs 'no_match'.
      final tasks = await _ref.read(tasksNotifierProvider.future);
      final matched = tasks
          .where((t) => !t.isDone && t.title.toLowerCase().contains(q))
          .toList();
      if (matched.isEmpty) {
        await logger.log(
          intentName: 'complete_task',
          transcript: query,
          status: 'failed',
          resultPayload: const {'reason': 'no_match'},
        );
        return;
      }
      // Completing a task awards XP/discipline with NO confirmation UI, so
      // the voice payload must resolve to an unambiguous target. A short
      // fragment ('a') substring-matching half the task list must not
      // silently complete an arbitrary matched.first.
      final exact = matched
          .where((t) => t.title.toLowerCase().trim() == q)
          .toList();
      final target = exact.length == 1
          ? exact.first
          : (matched.length == 1 ? matched.first : null);
      if (target == null) {
        await logger.log(
          intentName: 'complete_task',
          transcript: query,
          status: 'failed',
          resultPayload: {'reason': 'ambiguous', 'matches': matched.length},
        );
        return;
      }
      await _ref
          .read(tasksNotifierProvider.notifier)
          .completeTask(target.id);
      await logger.log(
        intentName: 'complete_task',
        transcript: query,
        status: 'success',
        resultPayload: {'task_id': target.id},
      );
    } catch (e) {
      await logger.log(
        intentName: 'complete_task',
        transcript: query,
        status: 'failed',
        resultPayload: {'error': e.toString()},
      );
    }
  }
}

final siriCommandHandlerProvider = Provider<SiriCommandHandler>(
  (ref) => SiriCommandHandler(ref),
);
