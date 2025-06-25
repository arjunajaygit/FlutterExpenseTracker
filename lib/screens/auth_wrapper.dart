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
    // Obx will react to changes in BOTH isInitialized and user
    return Obx(() {
      // While the controller is checking the auth state, show a loading screen
      if (!controller.isInitialized.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      // Once initialized, decide which screen to show
      return controller.user == null ? LoginScreen() : ExpenseListScreen();
    });
  }
}