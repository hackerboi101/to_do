import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do/app/core/models/task.dart';
import 'package:to_do/app/features/tasks/data/task_repository_impl.dart';

final taskRepositoryProvider = Provider<TaskRepositoryImpl>((ref) {
  return TaskRepositoryImpl();
});

// Define the state for the TaskViewModel
class TaskState {
  final List<Task> tasks;

  TaskState({required this.tasks});
}

class TaskViewModel extends StateNotifier<TaskState> {
  final TaskRepositoryImpl _repository;

  TaskViewModel(ProviderContainer container)
      : _repository = container.read(taskRepositoryProvider),
        super(TaskState(tasks: []));

  // Function to fetch all tasks
  Future<List<Task>> fetchTasks() async {
    await _repository.initDatabase();
    final tasks = await _repository.getAllTasks();
    state = TaskState(tasks: tasks);
    return tasks;
  }

  // Function to get a task by its ID
  Future<Task?> getTaskById(int taskId) async {
    await _repository.initDatabase();
    return await _repository.getTaskById(taskId);
  }

  // Function to add a new task
  Future<void> addTask(Task newTask) async {
    await _repository.initDatabase();
    await _repository.addTask(newTask);
    // Update the state of the TaskState object
    state = TaskState(tasks: [...state.tasks, newTask]);
    fetchTasks(); // Refresh the task list
  }

  // Function to edit an existing task
  Future<void> editTask(Task editedTask) async {
    await _repository.initDatabase();
    await _repository.editTask(editedTask);
    fetchTasks(); // Refresh the task list
  }

  // Function to delete a task by its ID
  Future<void> deleteTask(int taskId) async {
    await _repository.initDatabase();
    await _repository.deleteTask(taskId);
    fetchTasks(); // Refresh the task list
  }

  // Function to mark a task as completed
  Future<void> markTaskAsCompleted(int taskId) async {
    await _repository.initDatabase();
    await _repository.markTaskAsCompleted(taskId);
    // Update the task's completion status in the state
    state = TaskState(
      tasks: state.tasks
          .map((task) =>
              task.id == taskId ? task.copyWith(isCompleted: true) : task)
          .toList(),
    );
  }

  // Function to unmark a task as completed
  Future<void> unmarkTaskAsCompleted(int taskId) async {
    await _repository.initDatabase();
    await _repository.unmarkTaskAsCompleted(taskId);
    // Update the task's completion status in the state
    state = TaskState(
      tasks: state.tasks
          .map((task) =>
              task.id == taskId ? task.copyWith(isCompleted: false) : task)
          .toList(),
    );
  }
}
