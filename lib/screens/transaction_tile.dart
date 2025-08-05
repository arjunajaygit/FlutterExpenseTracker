// lib/screens/widgets/transaction_tile.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/screens/add_edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final dynamic transaction; // Accepts both Expense and Income objects
  TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.find();
    final bool isExpense = transaction is Expense;

    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');
        
    final CategoryInfo categoryInfo =
        controller.categoryDetails[transaction.category] ??
            controller.categoryDetails['Other']!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          dismissible: DismissiblePane(onDismissed: () {
            // Call the correct delete method based on the transaction type
            if (isExpense) {
              controller.deleteExpense(transaction.id!);
            } else {
              controller.deleteIncome(transaction.id!);
            }
          }),
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                if (isExpense) {
                  controller.deleteExpense(transaction.id!);
                } else {
                  controller.deleteIncome(transaction.id!);
                }
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
            // Setup and navigate to the versatile edit screen
            controller.setupEditScreen(transaction);
            Get.to(() => AddEditTransactionScreen(transaction: transaction));
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
                      transaction.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat.MMMMd().format(transaction.date),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                "${isExpense ? '-' : '+'} ${currencyFormatter.format(transaction.amount)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpense ? Colors.red : Colors.green, // DYNAMIC COLOR
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