import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:to_do/app/features/authentication/domain/authentication_viewmodel.dart';
import 'package:to_do/app/features/authentication/presentation/registration_screen.dart';

final emailControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final passwordControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final passwordVisibleProvider = StateProvider<bool>((ref) {
  return false;
});

final authenticationViewModelProvider =
    StateNotifierProvider<AuthenticationViewModel, AuthenticationState>((ref) {
  return AuthenticationViewModel(ref.container);
});

class AuthenticationScreen extends ConsumerWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final passwordVisible = ref.watch(passwordVisibleProvider);
    final passwordVisiblenotifier = ref.read(passwordVisibleProvider.notifier);
    final authenticationViewModel =
        ref.read(authenticationViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 240, 224, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 180),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(97, 97, 97, 1),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      passwordVisiblenotifier.state =
                          !passwordVisiblenotifier.state;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    authenticationViewModel.authenticateUser(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(41, 171, 226, 1),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Color.fromRGBO(97, 97, 97, 1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Get.to(const RegistrationScreen());
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color.fromRGBO(41, 171, 226, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
