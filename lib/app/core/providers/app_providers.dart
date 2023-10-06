// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do/app/features/authentication/domain/authentication_viewmodel.dart';
import 'package:to_do/app/features/tasks/domain/task_viewmodel.dart';
import 'package:to_do/app/features/reminders/domain/reminder_viewmodel.dart';

// App-wide providers

// App Name Provider
final appNameProvider = Provider<String>((ref) => "To Do");

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // You can use a persistent storage solution (e.g., shared_preferences) to retrieve the user's theme preference.
  // Here, we default to light mode.
  return ThemeMode.light;
});

// Light Theme Color
final lightThemeColor = const Color.fromRGBO(253, 240, 224, 1);

// Dark Theme Color
final darkThemeColor = const Color.fromRGBO(27, 35, 48, 1);

// Authentication Providers
final authenticationViewModelProvider =
    StateNotifierProvider<AuthenticationViewModel, AuthenticationState>((ref) {
  return AuthenticationViewModel(ref.container);
});

// Task Providers
final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, TaskState>((ref) {
  return TaskViewModel(ref.container);
});

// Reminder Providers
final reminderViewModelProvider =
    StateNotifierProvider<ReminderViewModel, ReminderState>((ref) {
  return ReminderViewModel();
});

// Theme Data Provider
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  // Define your light and dark theme data
  final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(253, 240, 224, 1),
    ),
    fontFamily: 'Poppins',
    useMaterial3: true,
    scaffoldBackgroundColor: lightThemeColor,
  );

  final darkTheme = ThemeData.dark().copyWith(
    // Customize your dark theme here
    scaffoldBackgroundColor: darkThemeColor,
  );

  return themeMode == ThemeMode.dark ? darkTheme : lightTheme;
});
