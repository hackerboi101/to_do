import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do/app/core/models/task.dart';
import 'package:to_do/app/features/tasks/data/task_repository_impl.dart';

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  return TaskRepositoryImpl();
});

class TaskState {
  final List<Task> tasks;

  TaskState({required this.tasks});
}

class TaskViewModel extends StateNotifier<TaskState> {
  final TaskRepositoryImpl _repository;

  TaskViewModel(ProviderContainer container)
      : _repository = container.read(taskRepositoryProvider),
        super(TaskState(tasks: []));

  Future<List<Task>> fetchTasks() async {
    await _repository.initDatabase();
    final tasks = await _repository.getAllTasks();
    state = TaskState(tasks: tasks);
    return tasks;
  }

  Future<Task?> getTaskById(int taskId) async {
    await _repository.initDatabase();
    return await _repository.getTaskById(taskId);
  }

  Future<void> addTask(Task newTask) async {
    await _repository.initDatabase();
    await _repository.addTask(newTask);

    state = TaskState(tasks: [...state.tasks, newTask]);
    fetchTasks();
  }

  Future<void> editTask(Task editedTask) async {
    await _repository.initDatabase();
    await _repository.editTask(editedTask);
    fetchTasks();
  }

  Future<void> deleteTask(int taskId) async {
    await _repository.initDatabase();
    await _repository.deleteTask(taskId);
    fetchTasks();
  }

  Future<void> markTaskAsCompleted(int taskId) async {
    await _repository.initDatabase();
    await _repository.markTaskAsCompleted(taskId);

    state = TaskState(
      tasks: state.tasks
          .map((task) =>
              task.id == taskId ? task.copyWith(isCompleted: true) : task)
          .toList(),
    );
  }

  Future<void> unmarkTaskAsCompleted(int taskId) async {
    await _repository.initDatabase();
    await _repository.unmarkTaskAsCompleted(taskId);

    state = TaskState(
      tasks: state.tasks
          .map((task) =>
              task.id == taskId ? task.copyWith(isCompleted: false) : task)
          .toList(),
    );
  }
}
