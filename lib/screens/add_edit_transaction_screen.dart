// lib/screens/add_edit_transaction_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final dynamic transaction; // Can be an Expense or Income object, can be null
  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final ExpenseController controller = Get.find();
  late bool isExpense;
  late RxString amountDisplay;

  @override
  void initState() {
    super.initState();
    
    // Determine the mode (expense or income) based on the passed transaction
    if (widget.transaction != null) {
      isExpense = widget.transaction is Expense;
      // Controller's setup method should have already been called before navigation
    } else {
      isExpense = true; // Default to expense when adding a new one
      controller.clearControllers(isExpense: true);
    }
    
    // Initialize the amount display listener
    amountDisplay = (controller.amountController.text.isEmpty
        ? "0"
        : controller.amountController.text).obs;

    controller.amountController.addListener(() {
      amountDisplay.value = controller.amountController.text.isEmpty
          ? "0"
          : controller.amountController.text;
    });
  }

  @override
  void dispose() {
    // It's good practice to remove the listener when the widget is disposed
    controller.amountController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the title and categories based on the current mode (expense/income)
    final String title = widget.transaction == null
        ? (isExpense ? 'Add Expense' : 'Add Income')
        : (isExpense ? 'Edit Expense' : 'Edit Income');
    
    final List<String> categories = isExpense 
        ? controller.expenseCategories 
        : controller.incomeCategories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Amount Display ---
              _buildAmountDisplay(),
              const SizedBox(height: 24),
              
              // --- Type Toggle (only for new transactions) ---
              if (widget.transaction == null) ...[
                _buildTypeToggle(),
                const SizedBox(height: 24),
              ],
              
              // --- Form Fields ---
              _buildSectionTitle('Category', context),
              _buildCategorySelector(context, categories),
              const SizedBox(height: 24),

              _buildSectionTitle('Amount', context),
              _buildAmountField(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Date', context),
              _buildDatePicker(context),
              const SizedBox(height: 24),

              _buildSectionTitle('Note (Optional)', context),
              _buildNotesField(),
              const SizedBox(height: 40),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(
        () => Text(
          '₹${amountDisplay.value}',
          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return SegmentedButton<bool>(
      style: SegmentedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedBackgroundColor: Theme.of(context).primaryColor,
      ),
      segments: const [
        ButtonSegment(value: true, label: Text('Expense'), icon: Icon(IconlyBold.arrowUp)),
        ButtonSegment(value: false, label: Text('Income'), icon: Icon(IconlyBold.arrowDown)),
      ],
      selected: {isExpense},
      onSelectionChanged: (newSelection) {
        setState(() {
          isExpense = newSelection.first;
          // When toggling, reset the selected category to the first in the new list
          controller.selectedCategory.value = isExpense 
            ? controller.expenseCategories.first 
            : controller.incomeCategories.first;
        });
      },
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

  Widget _buildCategorySelector(BuildContext context, List<String> categories) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedCategory.value,
        decoration: InputDecoration(
          prefixIcon: Icon(IconlyLight.category, color: Theme.of(context).colorScheme.secondary),
        ),
        dropdownColor: Theme.of(context).cardColor, 
        items: categories.map((String category) {
          final info = controller.categoryDetails[category]!;
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
        onChanged: (newValue) => controller.selectedCategory.value = newValue!,
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: controller.amountController,
      decoration: const InputDecoration(hintText: 'Enter amount'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter an amount';
        if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a valid amount';
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(data: Theme.of(context), child: child!),
          );
          if (picked != null) controller.selectedDate.value = picked;
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
                DateFormat.yMMMd().format(controller.selectedDate.value),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: controller.notesController,
      decoration: const InputDecoration(hintText: 'Add a note...'),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    final bool isUpdating = widget.transaction != null;
    return ElevatedButton(
      onPressed: () {
        // Call the correct save method based on the current mode
        if (isExpense) {
          controller.saveExpense();
        } else {
          controller.saveIncome();
        }
      },
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
          child: Text(
            isUpdating 
              ? (isExpense ? 'UPDATE EXPENSE' : 'UPDATE INCOME')
              : (isExpense ? 'ADD EXPENSE' : 'ADD INCOME'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}