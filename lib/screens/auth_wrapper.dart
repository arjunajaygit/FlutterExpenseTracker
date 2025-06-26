// lib/screens/auth_wrapper.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/screens/expense_list_screen.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends GetView<AuthController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx will react to all observable changes inside it
    return Obx(() {
      // 1. While the controller is checking the initial auth state, show a loading screen.
      if (!controller.isInitialized.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // 2. If user is authenticated, but we are still fetching their data from Firestore,
      //    keep showing the loading screen to prevent a UI flicker.
      if (controller.firebaseUser.value != null && controller.firestoreUser.value == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      // 3. Once we know for sure that there's no authenticated user, show the LoginScreen.
      //    (This covers both the case where the user is logged out, and the case where
      //     firebaseUser is null and firestoreUser is also null).
      if (controller.firebaseUser.value == null) {
        return LoginScreen();
      }
      
      // 4. If both the auth user and their Firestore data are ready, show the main app screen.
      return ExpenseListScreen();
    });
  }
}