// /Users/arjun/ExpenseTracker/lib/screens/expense_list_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends StatelessWidget {
  final ExpenseController expenseController = Get.find();

  ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Total Expenses Display
          Obx(() {
            return Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Spending:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat.simpleCurrency(locale: 'en_IN')
                        .format(expenseController.totalExpenses.value),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ],
              ),
            );
          }),
          // Expense List
          Expanded(
            child: Obx(() {
              if (expenseController.expenses.isEmpty) {
                return const Center(child: Text('No expenses yet. Add one!'));
              }
              return ListView.builder(
                itemCount: expenseController.expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenseController.expenses[index];
                  return Dismissible(
                    key: Key(expense.id!),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      expenseController.deleteExpense(expense.id!);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade50,
                          child: Text(
                            expense.category[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                        title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(expense.notes ?? ''),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              NumberFormat.simpleCurrency(locale: 'en_IN')
                                  .format(expense.amount),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(DateFormat.yMMMd().format(expense.date)),
                          ],
                        ),
                        onTap: () {
                          // Setup form for editing and navigate to Add/Edit screen
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
          // Clear form for adding new and navigate to Add/Edit screen
          expenseController.clearControllers();
          Get.to(() => AddEditExpenseScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}