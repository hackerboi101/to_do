import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:to_do/app/features/authentication/data/authentication_repository_impl.dart';
import 'package:to_do/app/features/tasks/presentation/task_list_screen.dart';

final authenticationRepositoryProvider =
    Provider<AuthenticationRepositoryImpl>((ref) {
  return AuthenticationRepositoryImpl();
});

enum AuthenticationState {
  authenticated,
  unauthenticated,
}

class AuthenticationViewModel extends StateNotifier<AuthenticationState> {
  final AuthenticationRepositoryImpl _repository;

  AuthenticationViewModel(ProviderContainer container)
      : _repository = container.read(authenticationRepositoryProvider),
        super(AuthenticationState.unauthenticated);

  Future<void> authenticateUser(String email, String password) async {
    try {
      await _repository.initDatabase();
      final isAuthenticated =
          await _repository.authenticateUser(email, password);

      if (isAuthenticated) {
        state = AuthenticationState.authenticated;
        Get.snackbar(
          'Success',
          'Sign in successful!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.to(const TaskListScreen());
      } else {
        state = AuthenticationState.unauthenticated;
        Get.snackbar(
          'Error',
          'Sign in failed!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> signUp(String userName, String email, String password) async {
    await _repository.initDatabase();
    final isRegistered =
        await _repository.registerUser(userName, email, password);

    if (isRegistered) {
      await authenticateUser(email, password);
    } else {
      state = AuthenticationState.unauthenticated;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = AuthenticationState.unauthenticated;
  }

  Future<void> closeDatabase() async {
    await _repository.closeDatabase();
  }

  @override
  void dispose() {
    closeDatabase();
    super.dispose();
  }
}
