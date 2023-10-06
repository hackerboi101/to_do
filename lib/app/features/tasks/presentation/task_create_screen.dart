// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do/app/core/models/task.dart';
import 'package:to_do/app/features/tasks/domain/task_viewmodel.dart';

class TaskCreateStateNotifier extends StateNotifier<DateTime> {
  TaskCreateStateNotifier() : super(DateTime.now());

  void setDueDate(DateTime newDueDate) {
    state = newDueDate;
  }
}

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, TaskState>((ref) {
  return TaskViewModel(ref.container);
});

final taskCreateStateProvider =
    StateNotifierProvider<TaskCreateStateNotifier, DateTime>((ref) {
  return TaskCreateStateNotifier();
});

class TaskCreateScreen extends ConsumerWidget {
  final Task? task;

  const TaskCreateScreen({Key? key, this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskViewModel = ref.read(taskViewModelProvider.notifier);
    final dueDate = ref.watch(taskCreateStateProvider);

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    // Initialize text controllers with task details if provided
    if (task != null) {
      titleController.text = task!.title;
      descriptionController.text = task!.description;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
      appBar: AppBar(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Due Date: '),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(dueDate),
                      );
                      if (selectedTime != null) {
                        final newDueDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        ref
                            .read(taskCreateStateProvider.notifier)
                            .setDueDate(newDueDate);
                      }
                    }
                  },
                  child: Text(
                    "${dueDate.toLocal()}"
                        .split(' ')[0], // Display selected date
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final editedTask = Task(
                  id: task?.id ?? 0,
                  title: titleController.text,
                  description: descriptionController.text,
                  isCompleted: task?.isCompleted ?? false,
                  dueDate: dueDate, // Use selected due date and time
                );

                if (task == null) {
                  // Add new task
                  taskViewModel.addTask(editedTask);
                } else {
                  // Edit existing task
                  taskViewModel.editTask(editedTask);
                }

                Navigator.pop(context);
              },
              child: Text(task == null ? 'Add Task' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
