// lib/controllers/expense_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// No need to import responsive_builder here anymore for the controller logic.

class ExpenseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _expenseCollection;

  var expenses = <Expense>[].obs;
  var totalExpenses = 0.0.obs;

  final List<String> categories = ['Food', 'Travel', 'Bills', 'Shopping', 'Other'];

  final formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController notesController;
  var selectedCategory = 'Food'.obs;
  var selectedDate = DateTime.now().obs;
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
        .map((snapshot) => snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  void calculateTotal() {
    totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  void setupEditScreen(Expense expense) {
    editingId.value = expense.id;
    amountController.text = expense.amount.toString();
    notesController.text = expense.notes ?? '';
    selectedCategory.value = expense.category;
    selectedDate.value = expense.date;
  }

  void clearControllers() {
    editingId.value = null;
    amountController.clear();
    notesController.clear();
    selectedCategory.value = 'Food';
    selectedDate.value = DateTime.now();
    formKey.currentState?.reset();
  }

  Future<void> saveExpense() async {
    if (_expenseCollection == null) {
      Get.snackbar('Error', 'You must be logged in to save expenses.');
      return;
    }

    if (formKey.currentState!.validate()) {
      // Show loading dialog
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final isUpdating = editingId.value != null;
      String successMessage = '';

      final newExpense = Expense(
        id: editingId.value,
        category: selectedCategory.value,
        amount: double.parse(amountController.text),
        date: selectedDate.value,
        notes: notesController.text,
        createdAt: Timestamp.now(),
      );

      try {
        if (isUpdating) {
          await _expenseCollection!.doc(editingId.value).update(newExpense.toMap());
          successMessage = 'Expense updated successfully!';
        } else {
          await _expenseCollection!.add(newExpense.toMap());
          successMessage = 'Expense added successfully!';
        }

        // --- THIS IS THE NEW, DEFINITIVE WORKFLOW ---

        // 1. Close the loading dialog if it's open.
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // 2. Navigate robustly using the AuthWrapper.
        // Get.offAll() clears the entire navigation stack and pushes the AuthWrapper.
        // The AuthWrapper will show a loading screen until the user's data is fully loaded,
        // preventing the "Welcome, null!" bug. It is our trusted entry point.
        Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn);

        // 3. Show the success message AFTER a short delay.
        // This gives the AuthWrapper time to build the UI before the snackbar appears.
        Future.delayed(const Duration(milliseconds: 400), () {
          Get.snackbar("Success", successMessage, snackPosition: SnackPosition.BOTTOM);
        });

      } on FirebaseException catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.snackbar('Error', "Failed to save expense: ${e.message}");
      }
    }
  }

  Future<void> deleteExpense(String docId) async {
    if (_expenseCollection == null) return;
    
    // If deleting the expense currently being edited, clear the form.
    if(editingId.value == docId){
      clearControllers();
    }
    
    await _expenseCollection!.doc(docId).delete();
    Get.snackbar('Success', 'Expense deleted successfully',snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}