import 'models/create_task_input.dart';
import 'models/task.dart';
import 'models/task_completion_result.dart';

abstract class TasksRepository {
  Future<List<Task>> getTodayTasks();
  Future<List<Task>> getTasks({String? goalId, bool? isDone});
  Future<Task> createTask(CreateTaskInput input);
  Future<TaskCompletionResult> completeTask(String taskId);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String taskId);
}
