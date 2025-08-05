// lib/screens/expense_list_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/main.dart';
// <<< 3. CHANGE THE IMPORT FROM dashboard_screen TO THE NEW WIDGET FILE
import 'package:expense_tracker/screens/transaction_tile.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController expenseController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (expenseController.expenses.isEmpty) {
          return Center(
            child: Text(
              'No expenses recorded yet.\nTap the + button to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
            ),
          );
        }

        Map<String, List<dynamic>> groupedExpenses = {};
        for (var expense in expenseController.expenses) {
          String formattedDate = DateFormat.yMMMd().format(expense.date);
          if (groupedExpenses[formattedDate] == null) {
            groupedExpenses[formattedDate] = [];
          }
          groupedExpenses[formattedDate]!.add(expense);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: groupedExpenses.keys.length,
          itemBuilder: (context, index) {
            String date = groupedExpenses.keys.elementAt(index);
            List<dynamic> expensesForDate = groupedExpenses[date]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: Text(
                    date,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...expensesForDate.map((expense) => TransactionTile(expense: expense)).toList(),
              ],
            );
          },
        );
      }),
    );
  }
}