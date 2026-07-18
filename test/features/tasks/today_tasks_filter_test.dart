import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/categories/domain/models/category_id.dart';
import 'package:hero/features/tasks/application/tasks_notifier.dart';
import 'package:hero/features/tasks/domain/models/task.dart';

Task _task(
  String id, {
  DateTime? dueAt,
  bool isDone = false,
}) {
  return Task(
    id: id,
    userId: 'u1',
    title: id,
    mainCategory: CategoryId.mind,
    dueAt: dueAt,
    isDone: isDone,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  // Fixed "now" so the test is deterministic: 2026-07-09 14:00 local.
  final now = DateTime(2026, 7, 9, 14, 0);

  group('filterTodayTasks', () {
    test('keeps pending tasks due today (even later in the day) and overdue',
        () {
      final all = [
        _task('today_later', dueAt: DateTime(2026, 7, 9, 17, 30)),
        _task('overdue', dueAt: DateTime(2026, 7, 8, 9, 0)),
      ];
      final ids = filterTodayTasks(all, now: now).map((t) => t.id).toList();
      expect(ids, containsAll(['today_later', 'overdue']));
    });

    test('excludes done, null-due, and tomorrow tasks', () {
      final all = [
        _task('done', dueAt: DateTime(2026, 7, 9, 10, 0), isDone: true),
        _task('no_due'),
        _task('tomorrow', dueAt: DateTime(2026, 7, 10, 9, 0)),
      ];
      expect(filterTodayTasks(all, now: now), isEmpty);
    });

    test('sorts by dueAt ascending', () {
      final all = [
        _task('late', dueAt: DateTime(2026, 7, 9, 20, 0)),
        _task('early', dueAt: DateTime(2026, 7, 8, 8, 0)),
        _task('mid', dueAt: DateTime(2026, 7, 9, 12, 0)),
      ];
      final ids = filterTodayTasks(all, now: now).map((t) => t.id).toList();
      expect(ids, ['early', 'mid', 'late']);
    });
  });
}
