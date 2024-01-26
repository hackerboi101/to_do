// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:to_do/app/core/models/task.dart';
import 'package:to_do/app/features/tasks/domain/task_viewmodel.dart';
import 'package:to_do/app/features/tasks/presentation/task_list_screen.dart';
import 'package:intl/intl.dart';

class TaskCreateStateNotifier extends StateNotifier<DateTime> {
  TaskCreateStateNotifier() : super(DateTime.now());

  void setDueDate(DateTime newDueDate) {
    state = newDueDate;
  }
}

final titleControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final descriptionControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

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

    final titleController = ref.watch(titleControllerProvider);
    final descriptionController = ref.watch(descriptionControllerProvider);

    if (task != null) {
      titleController.text = task!.title;
      descriptionController.text = task!.description;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
        centerTitle: true,
        title: Column(
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              width: 37,
              height: 37,
            ),
            const SizedBox(height: 3),
            task == null
                ? const Text(
                    'Add Task',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(147, 90, 22, 1),
                    ),
                  )
                : const Text(
                    'Edit Task',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(147, 90, 22, 1),
                    ),
                  ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(147, 90, 22, 1),
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(147, 90, 22, 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color.fromRGBO(147, 90, 22, 1),
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(147, 90, 22, 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 300),
              GestureDetector(
                onTap: () async {
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
                child: Center(
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(147, 90, 22, 0.7),
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
                        children: [
                          const Text(
                            'Due Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(253, 240, 224, 1),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${DateFormat('h:mm a').format(dueDate)} || ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(253, 240, 224, 1),
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy').format(dueDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(253, 240, 224, 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    final editedTask = Task(
                      id: task?.id ?? 0,
                      title: titleController.text,
                      description: descriptionController.text,
                      isCompleted: task?.isCompleted ?? false,
                      dueDate: dueDate,
                    );

                    if (task == null) {
                      taskViewModel.addTask(editedTask);
                    } else {
                      taskViewModel.editTask(editedTask);
                    }

                    titleController.clear();
                    descriptionController.clear();

                    Get.to(const TaskListScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromRGBO(147, 90, 22, 1),
                  ),
                  child: Text(
                    task == null ? 'Add Task' : 'Save Changes',
                    style: const TextStyle(
                      color: Color.fromRGBO(253, 240, 224, 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
