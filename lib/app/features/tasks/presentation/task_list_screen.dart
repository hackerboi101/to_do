import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:to_do/app/core/models/task.dart';
import 'package:to_do/app/features/tasks/domain/task_viewmodel.dart';
import 'package:to_do/app/features/tasks/presentation/task_create_screen.dart';

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, TaskState>((ref) {
  return TaskViewModel(ref.container);
});

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskViewModel = ref.read(taskViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the task creation screen
          Get.to(const TaskCreateScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Task>>(
        future: taskViewModel.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tasks = snapshot.data ?? [];

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskListItem(task: task, taskViewModel: taskViewModel);
              },
            );
          }
        },
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final TaskViewModel taskViewModel;

  const TaskListItem(
      {super.key, required this.task, required this.taskViewModel});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id.toString()),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Delete task
          taskViewModel.deleteTask(task.id);
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to the task details screen with the task ID
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(243, 220, 190, 1), // Your custom color
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (newValue) {
                      // Mark task as completed
                      taskViewModel.markTaskAsCompleted(task.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
