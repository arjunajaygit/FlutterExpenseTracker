// /Users/arjun/ExpenseTracker/lib/controllers/expense_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  // Firestore instance and collection reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _expenseCollection;

  // Reactive lists and variables
  var expenses = <Expense>[].obs;
  var totalExpenses = 0.0.obs;

  // List of categories for the dropdown
  final List<String> categories = ['Food', 'Travel', 'Bills', 'Shopping', 'Other'];

  // Form controllers and state
  final formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController notesController;
  var selectedCategory = 'Food'.obs;
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _expenseCollection = _firestore.collection('expenses');
    amountController = TextEditingController();
    notesController = TextEditingController();
    // Bind the stream of expenses to our reactive list
    expenses.bindStream(getExpensesStream());
    // Calculate total expenses whenever the expenses list changes
    ever(expenses, (_) => calculateTotal());
  }

  // Stream to get real-time updates from Firestore
  Stream<List<Expense>> getExpensesStream() {
    return _expenseCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  // Calculate the total sum of all expenses
  void calculateTotal() {
    totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Set up the form for editing an existing expense
  void setupEditScreen(Expense expense) {
    amountController.text = expense.amount.toString();
    notesController.text = expense.notes ?? '';
    selectedCategory.value = expense.category;
    selectedDate.value = expense.date;
  }

  // Reset form fields to their default state
  void clearControllers() {
    amountController.clear();
    notesController.clear();
    selectedCategory.value = 'Food';
    selectedDate.value = DateTime.now();
  }

  // Add or Update an expense in Firestore
  Future<void> saveExpense({String? docId}) async {
    if (formKey.currentState!.validate()) {
      final newExpense = Expense(
        id: docId, // Will be null for new expenses
        category: selectedCategory.value,
        amount: double.parse(amountController.text),
        date: selectedDate.value,
        notes: notesController.text,
        createdAt: Timestamp.now(), // Always update timestamp for sorting
      );

      if (docId == null) {
        // Add new expense
        await _expenseCollection.add(newExpense.toMap());
        Get.snackbar('Success', 'Expense added successfully', snackPosition: SnackPosition.BOTTOM);
      } else {
        // Update existing expense
        await _expenseCollection.doc(docId).update(newExpense.toMap());
        Get.snackbar('Success', 'Expense updated successfully', snackPosition: SnackPosition.BOTTOM);
      }
      Get.back(); // Go back to the list screen
      clearControllers();
    }
  }

  // Delete an expense from Firestore
  Future<void> deleteExpense(String docId) async {
    await _expenseCollection.doc(docId).delete();
    Get.snackbar('Success', 'Expense deleted successfully', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}