// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do/app/core/models/task.dart';
import 'package:to_do/app/features/tasks/domain/task_viewmodel.dart';
import 'package:to_do/app/features/tasks/presentation/task_create_screen.dart';

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, TaskState>((ref) {
  return TaskViewModel(ref.container);
});

final selectedSortOptionProvider = StateProvider<String>((ref) => 'name');
final selectedFilterOptionProvider = StateProvider<String>((ref) => 'all');

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskViewModel = ref.watch(taskViewModelProvider.notifier);
    final selectedSortOption = ref.watch(selectedSortOptionProvider.notifier);
    final selectedFilterOption =
        ref.watch(selectedFilterOptionProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              width: 37,
              height: 37,
            ),
            const SizedBox(height: 3),
            const Text(
              'To Do',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(147, 90, 22, 1),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const TaskCreateScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(243, 220, 190, 1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedSortOption.state,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 2,
                  underline: Container(
                    color: Colors.transparent,
                  ),
                  dropdownColor: const Color.fromRGBO(243, 220, 190, 1),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'name',
                      child: Text(
                        'Sort by Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(147, 90, 22, 1),
                        ),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'date',
                      child: Text(
                        'Sort by Date',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(147, 90, 22, 1),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    selectedSortOption.state = value!;
                    ref.refresh(taskViewModelProvider);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(243, 220, 190, 1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedFilterOption.state,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 2,
                  underline: Container(
                    color: Colors.transparent,
                  ),
                  dropdownColor: const Color.fromRGBO(243, 220, 190, 1),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'all',
                      child: Text(
                        'All Tasks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(147, 90, 22, 1),
                        ),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'completed',
                      child: Text(
                        'Completed Tasks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(147, 90, 22, 1),
                        ),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'incomplete',
                      child: Text(
                        'Incomplete Tasks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(147, 90, 22, 1),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    selectedFilterOption.state = value!;
                    ref.refresh(taskViewModelProvider);
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: taskViewModel.fetchTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final tasks = snapshot.data!;
                  final filteredTasks = _filterTasks(
                      taskViewModel, selectedFilterOption.state, tasks);
                  final sortedTasks = _sortTasks(
                      taskViewModel, selectedSortOption.state, filteredTasks);

                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3.0),
                          child: TaskListItem(
                            task: task,
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Task> _sortTasks(
      TaskViewModel taskViewModel, String option, List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);

    if (option == 'name') {
      sortedTasks.sort((a, b) => a.title.compareTo(b.title));
    } else if (option == 'date') {
      sortedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    return sortedTasks;
  }

  List<Task> _filterTasks(
      TaskViewModel taskViewModel, String option, List<Task> tasks) {
    if (option == 'all') {
      return tasks;
    } else if (option == 'completed') {
      return tasks.where((task) => task.isCompleted).toList();
    } else if (option == 'incomplete') {
      return tasks.where((task) => !task.isCompleted).toList();
    } else {
      return tasks;
    }
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final taskViewModel = ref.watch(taskViewModelProvider.notifier);

        return Dismissible(
          key: Key(task.id.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              taskViewModel.deleteTask(task.id);
            }
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              Get.to(TaskCreateScreen(
                task: task,
              ));
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(243, 220, 190, 1),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(147, 90, 22, 1),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor:
                              const Color.fromRGBO(147, 90, 22, 1),
                        ),
                        child: Checkbox(
                          value: task.isCompleted,
                          activeColor: const Color.fromRGBO(147, 90, 22, 1),
                          onChanged: (newValue) async {
                            if (newValue != null) {
                              if (newValue) {
                                await taskViewModel
                                    .markTaskAsCompleted(task.id);
                                ref.refresh(taskViewModelProvider);
                              } else {
                                await taskViewModel
                                    .unmarkTaskAsCompleted(task.id);
                                ref.refresh(taskViewModelProvider);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromRGBO(147, 90, 22, 1),
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(147, 90, 22, 0.7),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${DateFormat('h:mm a').format(task.dueDate)} || ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(253, 240, 224, 1),
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(task.dueDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(253, 240, 224, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
