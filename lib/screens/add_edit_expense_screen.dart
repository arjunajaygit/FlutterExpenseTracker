// /Users/arjun/ExpenseTracker/lib/screens/add_edit_expense_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final ExpenseController expenseController = Get.find();
  final Expense? expense; // Null when adding, has value when editing

  AddEditExpenseScreen({super.key, this.expense});

  @override
  Widget build(BuildContext context) {
    final isEditing = expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: expenseController.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Dropdown
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: expenseController.selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: expenseController.categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    expenseController.selectedCategory.value = newValue!;
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                );
              }),
              const SizedBox(height: 16),
              // Amount Field
              TextFormField(
                controller: expenseController.amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date Picker
              Obx(() {
                return ListTile(
                  title: Text(
                      "Date: ${DateFormat.yMMMd().format(expenseController.selectedDate.value)}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: expenseController.selectedDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      expenseController.selectedDate.value = picked;
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey.shade400)
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Notes Field
              TextFormField(
                controller: expenseController.notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Save Button
              ElevatedButton(
                onPressed: () {
                  expenseController.saveExpense(docId: expense?.id);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Update Expense' : 'Add Expense', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}