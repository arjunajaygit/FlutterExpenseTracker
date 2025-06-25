import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_tracker/screens/expense_list_screen.dart';

class ExpenseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Collection reference is now nullable, as it depends on a logged-in user
  CollectionReference? _expenseCollection;

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
    amountController = TextEditingController();
    notesController = TextEditingController();

    // Listen to authentication state to set up the correct Firestore path
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // If user is logged in, point to their specific expenses sub-collection
        _expenseCollection = _firestore.collection('users').doc(user.uid).collection('expenses');
        expenses.bindStream(getExpensesStream());
      } else {
        // If user is logged out, clear the expenses list
        expenses.value = [];
        _expenseCollection = null;
      }
    });

    // Calculate total expenses whenever the expenses list changes
    ever(expenses, (_) => calculateTotal());
  }

  // Stream to get real-time updates from the user-specific collection
  Stream<List<Expense>> getExpensesStream() {
    // If the user is logged out, return an empty stream
    if (_expenseCollection == null) {
      return Stream.value([]);
    }
    return _expenseCollection!
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  // Calculate the total sum of all expenses
  void calculateTotal() {
    totalExpenses.value = expenses.fold(0.0, (currentSum, item) => currentSum + item.amount);
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
    if (_expenseCollection == null) {
      Get.snackbar('Error', 'You must be logged in to save expenses.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (formKey.currentState!.validate()) {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final newExpense = Expense(
        id: docId, // Will be null for new expenses
        category: selectedCategory.value,
        amount: double.parse(amountController.text),
        date: selectedDate.value,
        notes: notesController.text,
        createdAt: Timestamp.now(), // Always update timestamp for sorting
      );

      if (docId == null) {
        await _expenseCollection!.add(newExpense.toMap());
        Get.back();
        Get.snackbar('Success', 'Expense added successfully', snackPosition: SnackPosition.BOTTOM);
      } else {
        await _expenseCollection!.doc(docId).update(newExpense.toMap());
        Get.back();
        Get.snackbar('Success', 'Expense updated successfully', snackPosition: SnackPosition.BOTTOM);
      }
      await Future.delayed(const Duration(milliseconds: 700));
      Get.offAll(() => ExpenseListScreen(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
      clearControllers();
    }
  }

  // Delete an expense from Firestore
  Future<void> deleteExpense(String docId) async {
    if (_expenseCollection == null) return;
    await _expenseCollection!.doc(docId).delete();
    Get.snackbar('Success', 'Expense deleted successfully', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}