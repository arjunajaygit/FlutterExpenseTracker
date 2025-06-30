// lib/screens/auth_wrapper.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/screens/widgets/responsive_layout.dart'; // <<< IMPORT THIS
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends GetView<AuthController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isInitialized.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.firebaseUser.value != null && controller.firestoreUser.value == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      if (controller.firebaseUser.value == null) {
        return LoginScreen();
      }
      
      // <<< THIS IS THE CHANGE >>>
      // If the user is logged in, show the responsive layout.
      return const ResponsiveLayout();
    });
  }
}