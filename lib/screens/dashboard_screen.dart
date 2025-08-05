// lib/screens/dashboard_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:expense_tracker/screens/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final ExpenseController expenseController = Get.find();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          expenseController.clearControllers();
          Get.to(() => AddEditExpenseScreen());
        },
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              automaticallyImplyLeading: false,
              title: Obx(
                () => Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=3'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome!',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          authController.firestoreUser.value?['name'] ?? 'User',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(IconlyLight.logout, color: Theme.of(context).primaryColor),
                  onPressed: () => authController.logout(),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // The Obx is now wrapped around the entire card
                    _buildBalanceCard(expenseController, currencyFormatter),
                    const SizedBox(height: 30),
                    _buildSectionHeader(context, "Recent Transactions", () {
                      Get.find<NavigationController>().changePage(1);
                    }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Obx(
              () => expenseController.expenses.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("No transactions yet.",
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final expense = expenseController.expenses[index];
                            return TransactionTile(expense: expense);
                          },
                          childCount: expenseController.expenses.length > 5 ? 5 : expenseController.expenses.length,
                        ),
                      ),
                    ),
            ),
             const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  // --- THIS IS THE FIX ---
  // The entire widget is now wrapped in an Obx in the build method above.
  Widget _buildBalanceCard(ExpenseController controller, NumberFormat formatter) {
    return Obx( // The Obx wrapper ensures the whole card rebuilds on data change
      () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Expenses',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // This no longer needs its own Obx
            Text(
              formatter.format(controller.totalExpenses.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceDetail(IconlyBold.arrowDownSquare, "Income", "N/A"),
                // This will now always get the fresh value when the card rebuilds
                _buildBalanceDetail(IconlyBold.arrowUpSquare, "Expenses",
                    formatter.format(controller.totalExpenses.value)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onViewAll,
          child: Text('View All', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}