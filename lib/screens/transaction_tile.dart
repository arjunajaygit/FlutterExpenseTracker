// lib/screens/widgets/transaction_tile.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;
  TransactionTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final ExpenseController expenseController = Get.find();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final CategoryInfo categoryInfo =
        expenseController.categoryDetails[expense.category] ??
            expenseController.categoryDetails['Other']!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(expense.id),
        endActionPane: ActionPane(
          dismissible: DismissiblePane(onDismissed: () {
            // The controller's delete method already shows a snackbar.
            expenseController.deleteExpense(expense.id!);
          }),
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                // The controller's delete method already shows a snackbar.
                expenseController.deleteExpense(expense.id!);
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: IconlyBold.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () {
            expenseController.setupEditScreen(expense);
            Get.to(() => AddEditExpenseScreen(expense: expense));
          },
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryInfo.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 24),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat.MMMMd().format(expense.date),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                "-${currencyFormatter.format(expense.amount)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}