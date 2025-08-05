// lib/screens/expense_list_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
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
        if (expenseController.allTransactions.isEmpty) {
          return Center(
            child: Text(
              'No transactions recorded yet.\nTap the + button to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
            ),
          );
        }

        Map<String, List<dynamic>> groupedTransactions = {};
        for (var transaction in expenseController.allTransactions) {
          String formattedDate = DateFormat.yMMMd().format(transaction.date);
          if (groupedTransactions[formattedDate] == null) {
            groupedTransactions[formattedDate] = [];
          }
          groupedTransactions[formattedDate]!.add(transaction);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: groupedTransactions.keys.length,
          itemBuilder: (context, index) {
            String date = groupedTransactions.keys.elementAt(index);
            List<dynamic> transactionsForDate = groupedTransactions[date]!;
            
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
                // --- THIS IS THE FIX ---
                // Renamed the variable to 'transaction' and passed it to the correct parameter.
                ...transactionsForDate.map((transaction) => TransactionTile(transaction: transaction)).toList(),
              ],
            );
          },
        );
      }),
    );
  }
}