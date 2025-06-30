// lib/controllers/expense_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ExpenseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _expenseCollection;

  // Reactive lists and variables
  var expenses = <Expense>[].obs;
  var totalExpenses = 0.0.obs;

  // List of categories for the dropdown
  final List<String> categories = ['Food', 'Travel', 'Bills', 'Shopping', 'Other'];

  // --- Form State ---
  final formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController notesController;
  var selectedCategory = 'Food'.obs;
  var selectedDate = DateTime.now().obs;
  
  // --- ADDED THIS LINE ---
  // This will hold the ID of the expense we are editing. It's observable and nullable.
  final Rxn<String> editingId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController();
    notesController = TextEditingController();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _expenseCollection = _firestore.collection('users').doc(user.uid).collection('expenses');
        expenses.bindStream(getExpensesStream());
      } else {
        expenses.value = [];
        _expenseCollection = null;
      }
    });

    ever(expenses, (_) => calculateTotal());
  }

  Stream<List<Expense>> getExpensesStream() {
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

  void calculateTotal() {
    totalExpenses.value = expenses.fold(0.0, (currentSum, item) => currentSum + item.amount);
  }

  // --- MODIFIED THIS METHOD ---
  // Set up the form for editing an existing expense
  void setupEditScreen(Expense expense) {
    editingId.value = expense.id; // Set the reactive editing ID
    amountController.text = expense.amount.toString();
    notesController.text = expense.notes ?? '';
    selectedCategory.value = expense.category;
    selectedDate.value = expense.date;
  }

  // --- MODIFIED THIS METHOD ---
  // Reset form fields to their default state
  void clearControllers() {
    editingId.value = null; // Clear the reactive editing ID
    amountController.clear();
    notesController.clear();
    selectedCategory.value = 'Food';
    selectedDate.value = DateTime.now();
    formKey.currentState?.reset(); // Also reset form validation state
  }

  // --- MODIFIED THIS METHOD ---
  // Add or Update an expense in Firestore. The docId argument is no longer needed.
  Future<void> saveExpense() async {
    if (_expenseCollection == null) {
      Get.snackbar('Error', 'You must be logged in to save expenses.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (formKey.currentState!.validate()) {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final isUpdating = editingId.value != null;

      final newExpense = Expense(
        id: editingId.value, // Use the reactive ID
        category: selectedCategory.value,
        amount: double.parse(amountController.text),
        date: selectedDate.value,
        notes: notesController.text,
        createdAt: Timestamp.now(), // Always set/update timestamp for sorting
      );

      try {
        if (isUpdating) {
          await _expenseCollection!.doc(editingId.value).update(newExpense.toMap());
          Get.back(); // Close loading dialog
          Get.snackbar('Success', 'Expense updated successfully', snackPosition: SnackPosition.BOTTOM);
        } else {
          await _expenseCollection!.add(newExpense.toMap());
          Get.back(); // Close loading dialog
          Get.snackbar('Success', 'Expense added successfully', snackPosition: SnackPosition.BOTTOM);
        }

        // Responsive handling after save
        if (getDeviceType(Get.mediaQuery.size) != DeviceScreenType.mobile) {
          // On desktop/tablet, just clear the form, don't navigate
          clearControllers();
        } else {
          // On mobile, navigate back to the list screen
          Get.back();
        }
      } on FirebaseException catch (e) {
        Get.back();
        Get.snackbar('Error', "Failed to save expense: ${e.message}", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  // Delete an expense from Firestore
  Future<void> deleteExpense(String docId) async {
    if (_expenseCollection == null) return;
    
    // If the expense being deleted is the one currently in the form, clear the form.
    if(editingId.value == docId){
      clearControllers();
    }
    
    await _expenseCollection!.doc(docId).delete();
    Get.snackbar('Success', 'Expense deleted successfully', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}