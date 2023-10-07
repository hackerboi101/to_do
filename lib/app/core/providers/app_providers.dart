// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do/app/features/authentication/domain/authentication_viewmodel.dart';
import 'package:to_do/app/features/tasks/domain/task_viewmodel.dart';
import 'package:to_do/app/features/reminders/domain/reminder_viewmodel.dart';

final appNameProvider = Provider<String>((ref) => "To Do");

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

final lightThemeColor = const Color.fromRGBO(253, 240, 224, 1);

final darkThemeColor = const Color.fromRGBO(27, 35, 48, 1);

final authenticationViewModelProvider =
    StateNotifierProvider<AuthenticationViewModel, AuthenticationState>((ref) {
  return AuthenticationViewModel(ref.container);
});

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, TaskState>((ref) {
  return TaskViewModel(ref.container);
});

final reminderViewModelProvider =
    StateNotifierProvider<ReminderViewModel, ReminderState>((ref) {
  return ReminderViewModel();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(253, 240, 224, 1),
    ),
    fontFamily: 'Poppins',
    useMaterial3: true,
    scaffoldBackgroundColor: lightThemeColor,
  );

  final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkThemeColor,
  );

  return themeMode == ThemeMode.dark ? darkTheme : lightTheme;
});
