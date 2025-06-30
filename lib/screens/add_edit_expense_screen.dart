// lib/screens/add_edit_expense_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final ExpenseController expenseController = Get.find();
  // We still accept the expense object for the initial tap on mobile
  final Expense? expense; 

  AddEditExpenseScreen({super.key, this.expense});

  @override
  Widget build(BuildContext context) {
    // Determine if we are editing based on the controller's state now.
    // The passed 'expense' object is only for the very first build on mobile.
    final isEditing = expense != null;

    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: expenseController.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // For desktop, add a title inside the form pane.
            if (getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                // This title is now also reactive
                child: Obx(
                  () => Text(
                    expenseController.editingId.value != null ? 'Edit Expense Details' : 'Add a New Expense',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),

            // Category Dropdown
            Obx(() {
              return DropdownButtonFormField<String>(
                value: expenseController.selectedCategory.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: expenseController.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) => expenseController.selectedCategory.value = newValue!,
                validator: (value) => value == null ? 'Please select a category' : null,
              );
            }),
            const SizedBox(height: 16),
            
            // Amount Field
            TextFormField(
              controller: expenseController.amountController,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an amount';
                if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            Obx(() {
              return ListTile(
                title: Text("Date: ${DateFormat.yMMMd().format(expenseController.selectedDate.value)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: expenseController.selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) expenseController.selectedDate.value = picked;
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
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // --- MODIFIED THIS BUTTON ---
            ElevatedButton(
              onPressed: () {
                // The controller is now smart enough to know what to do.
                expenseController.saveExpense();
              },
              // This Obx is now listening to a real .obs variable and is correct.
              child: Obx(() => Text(expenseController.editingId.value != null ? 'Update Expense' : 'Add Expense')),
            ),
            const SizedBox(height: 16),

            // Add a clear button for desktop convenience
            if (getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile)
              TextButton(
                onPressed: () => expenseController.clearControllers(), 
                child: const Text('Clear Form')
              )
          ],
        ),
      ),
    );

    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => Scaffold(
        appBar: AppBar(
          // On mobile, the title is static based on the initial state
          title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        ),
        body: formBody,
      ),
      // On desktop/tablet, no Scaffold is needed as it's part of a larger layout
      tablet: (BuildContext context) => formBody,
      desktop: (BuildContext context) => formBody,
    );
  }
}