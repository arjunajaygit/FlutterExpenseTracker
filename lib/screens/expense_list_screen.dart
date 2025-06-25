// lib/screens/expense_list_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExpenseListScreen extends StatelessWidget {
  final ExpenseController expenseController = Get.find();
  final AuthController authController = Get.find();

  ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use Obx to make the title reactive to user data changes
        title: Obx(() {
          final userName = authController.firestoreUser?['name'];
          if (userName == null) {
            return Row(
              children: [
                const Text('Welcome'),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ],
            );
          }
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
      body: Column(
        // ... rest of your UI for displaying expenses ...
        children: [
          // Total expenses summary card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() => Text(
                      'Total Expenses: ₹${expenseController.totalExpenses.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                    )),
              ),
            ),
          ),
          // List of expenses
          Expanded(
            child: Obx(() {
              if (expenseController.expenses.isEmpty) {
                return const Center(
                    child: Text('No expenses yet. Add one!',
                        style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                itemCount: expenseController.expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenseController.expenses[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Slidable(
                      key: ValueKey(expense.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              expenseController.deleteExpense(expense.id!);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.receipt_long, color: Colors.teal.shade800),
                        ),
                        title: Text(expense.category,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                        trailing: Text(
                          '₹${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          expenseController.setupEditScreen(expense);
                          Get.to(() => AddEditExpenseScreen(expense: expense));
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          expenseController.clearControllers();
          Get.to(() => AddEditExpenseScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}