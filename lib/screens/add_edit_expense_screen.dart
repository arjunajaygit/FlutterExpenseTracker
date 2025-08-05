// lib/screens/add_edit_expense_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final ExpenseController expenseController = Get.find();
  final Expense? expense;

  AddEditExpenseScreen({super.key, this.expense});

  @override
  Widget build(BuildContext context) {
    final isEditing = expense != null;
    
    final RxString amountDisplay = (expenseController.amountController.text.isEmpty
        ? "0"
        : expenseController.amountController.text).obs;

    expenseController.amountController.addListener(() {
      amountDisplay.value = expenseController.amountController.text.isEmpty
          ? "0"
          : expenseController.amountController.text;
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        // --- THIS IS THE FIX ---
        // The actions property and the IconButton have been completely removed.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: expenseController.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => Text(
                        '₹${amountDisplay.value}',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Category', context),
              _buildCategorySelector(context),
              const SizedBox(height: 24),

              _buildSectionTitle('Amount', context),
              TextFormField(
                controller: expenseController.amountController,
                decoration: const InputDecoration(hintText: 'Enter amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Date', context),
              _buildDatePicker(context),
              const SizedBox(height: 24),

              _buildSectionTitle('Note (Optional)', context),
              TextFormField(
                controller: expenseController.notesController,
                decoration: const InputDecoration(hintText: 'Add a note...'),
                maxLines: 3,
              ),
              const SizedBox(height: 40),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Theme.of(context).colorScheme.secondary, 
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: expenseController.selectedCategory.value,
        decoration: InputDecoration(
          prefixIcon: Icon(IconlyLight.category, color: Theme.of(context).colorScheme.secondary),
        ),
        dropdownColor: Theme.of(context).cardColor, 
        items: expenseController.categories.map((String category) {
          final info = expenseController.categoryDetails[category]!;
          return DropdownMenuItem<String>(
            value: category,
            child: Row(
              children: [
                Icon(info.icon, color: info.color, size: 20),
                const SizedBox(width: 10),
                Text(category),
              ],
            ),
          );
        }).toList(),
        onChanged: (newValue) => expenseController.selectedCategory.value = newValue!,
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: expenseController.selectedDate.value,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context),
                child: child!,
              );
            },
          );
          if (picked != null) expenseController.selectedDate.value = picked;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(IconlyLight.calendar, color: Theme.of(context).colorScheme.secondary), 
              const SizedBox(width: 12),
              Text(
                DateFormat.yMMMd().format(expenseController.selectedDate.value),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () => expenseController.saveExpense(),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 55,
          alignment: Alignment.center,
          child: Obx(
            () => Text(
              expenseController.editingId.value != null ? 'UPDATE EXPENSE' : 'ADD EXPENSE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}