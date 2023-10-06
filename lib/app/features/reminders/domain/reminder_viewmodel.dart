import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a model class to represent a reminder
class Reminder {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
  });
}

// Define the state for the ReminderViewModel
class ReminderState {
  final List<Reminder> reminders;

  ReminderState({required this.reminders});
}

class ReminderViewModel extends StateNotifier<ReminderState> {
  ReminderViewModel() : super(ReminderState(reminders: []));

  // Method to add a new reminder
  void addReminder(Reminder reminder) {
    state = ReminderState(reminders: [...state.reminders, reminder]);
  }

  // Method to update an existing reminder
  void updateReminder(Reminder updatedReminder) {
    final updatedReminders = state.reminders.map((reminder) {
      if (reminder.id == updatedReminder.id) {
        return updatedReminder;
      }
      return reminder;
    }).toList();
    state = ReminderState(reminders: updatedReminders);
  }

  // Method to remove a reminder by its ID
  void removeReminder(int reminderId) {
    final updatedReminders =
        state.reminders.where((reminder) => reminder.id != reminderId).toList();
    state = ReminderState(reminders: updatedReminders);
  }
}
