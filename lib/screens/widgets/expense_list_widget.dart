// lib/screens/widgets/expense_list_widget.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ExpenseListWidget extends StatelessWidget {
  final ExpenseController expenseController = Get.find();

  ExpenseListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No expenses yet.', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        expenseController.clearControllers();
                        if (getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile) {
                          Get.to(() => AddEditExpenseScreen());
                        }
                      }, 
                      icon: const Icon(Icons.add), 
                      label: const Text("Add First Expense"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 45)
                      ),
                    )
                  ],
                )
              );
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
                          onPressed: (context) => expenseController.deleteExpense(expense.id!),
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
                        // THIS IS THE RESPONSIVE LOGIC
                        // 1. Always set up the controller with the selected expense data.
                        expenseController.setupEditScreen(expense);
                        
                        // 2. On mobile, navigate to a new screen.
                        // On desktop/tablet, the form is already visible, so we don't need to navigate.
                        if (getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile) {
                          Get.to(() => AddEditExpenseScreen(expense: expense));
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}