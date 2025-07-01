// lib/screens/auth_wrapper.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/screens/app_shell.dart'; // <<< This is the one you need
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends GetView<AuthController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // While the controller is checking the initial auth state, show a loading screen.
      if (!controller.isInitialized.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // If the user is authenticated but we are still fetching their data, keep showing the loading screen.
      if (controller.firebaseUser.value != null && controller.firestoreUser.value == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      // If there's no authenticated user, show the LoginScreen.
      if (controller.firebaseUser.value == null) {
        return LoginScreen();
      }
      
      // <<< THIS IS THE CORRECTION >>>
      // If the user is logged in, show the AppShell. The AppShell will handle
      // the responsive layout and the bottom navigation bar.
      return const AppShell();
    });
  }
}