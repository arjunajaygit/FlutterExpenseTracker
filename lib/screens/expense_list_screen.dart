// lib/screens/expense_list_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:expense_tracker/screens/widgets/expense_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// This screen is now just the mobile view.
class ExpenseListScreen extends StatelessWidget {
  final ExpenseController expenseController = Get.find();
  final AuthController authController = Get.find();

  ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final userName = authController.firestoreUser.value?['name'];
          return Text('Welcome, $userName!');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authController.logout();
            },
          )
        ],
      ),
      // The body is now the reusable widget we created.
      body: ExpenseListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // On mobile, tapping the FAB clears the form controllers and navigates
          // to the dedicated form screen.
          expenseController.clearControllers();
          Get.to(() => AddEditExpenseScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}