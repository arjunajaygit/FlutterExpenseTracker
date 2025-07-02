// lib/controllers/expense_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _expenseCollection;

  // --- Core State ---
  var expenses = <Expense>[].obs;
  var totalExpenses = 0.0.obs; // <<< ADDED BACK

  // --- NEW DASHBOARD STATE ---
  var weeklyTotalSpend = 0.0.obs;
  var monthlyTotalSpend = 0.0.obs;
  var yearlyTotalSpend = 0.0.obs;
  var weeklyCategorySpends = <String, double>{}.obs;
  var monthlyCategorySpends = <String, double>{}.obs;
  var yearlyCategorySpends = <String, double>{}.obs;
  var topWeeklyCategory = 'N/A'.obs;
  var topMonthlyCategory = 'N/A'.obs;
  var topYearlyCategory = 'N/A'.obs;

  // --- Form State ---
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
        clearDashboardData();
      }
    });

    // --- MODIFIED LISTENER ---
    ever(expenses, (_) {
      calculateTotal(); // <<< ADDED BACK
      processDashboardData();
    });
  }

  Stream<List<Expense>> getExpensesStream() {
    if (_expenseCollection == null) return Stream.value([]);
    return _expenseCollection!.orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  // <<< ADDED THIS METHOD BACK ---
  void calculateTotal() {
    totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  // --- NEW, CATEGORY-FOCUSED DATA PROCESSING ---
  void processDashboardData() {
    if (expenses.isEmpty) {
      clearDashboardData();
      return;
    }
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDateOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    final weekMap = <String, double>{};
    final monthMap = <String, double>{};
    final yearMap = <String, double>{};

    for (var expense in expenses) {
      final expenseDateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);

      if (!expenseDateOnly.isBefore(startOfYear)) {
        yearMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount);
      }
      if (!expenseDateOnly.isBefore(startOfMonth)) {
        monthMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount);
      }
      if (!expenseDateOnly.isBefore(startOfWeekDateOnly)) {
        weekMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount);
      }
    }

    weeklyCategorySpends.value = weekMap;
    weeklyTotalSpend.value = weekMap.values.fold(0.0, (sum, item) => sum + item);
    topWeeklyCategory.value = weekMap.isNotEmpty ? weekMap.entries.reduce((a, b) => a.value > b.value ? a : b).key : 'N/A';
    
    monthlyCategorySpends.value = monthMap;
    monthlyTotalSpend.value = monthMap.values.fold(0.0, (sum, item) => sum + item);
    topMonthlyCategory.value = monthMap.isNotEmpty ? monthMap.entries.reduce((a, b) => a.value > b.value ? a : b).key : 'N/A';

    yearlyCategorySpends.value = yearMap;
    yearlyTotalSpend.value = yearMap.values.fold(0.0, (sum, item) => sum + item);
    topYearlyCategory.value = yearMap.isNotEmpty ? yearMap.entries.reduce((a, b) => a.value > b.value ? a : b).key : 'N/A';
  }

  void clearDashboardData() {
    totalExpenses.value = 0.0;
    weeklyTotalSpend.value = 0.0;
    monthlyTotalSpend.value = 0.0;
    yearlyTotalSpend.value = 0.0;
    weeklyCategorySpends.value = {};
    monthlyCategorySpends.value = {};
    yearlyCategorySpends.value = {};
    topWeeklyCategory.value = 'N/A';
    topMonthlyCategory.value = 'N/A';
    topYearlyCategory.value = 'N/A';
  }

  // --- Form and CRUD Methods ---
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
    if (formKey.currentState!.validate()) {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final isUpdating = editingId.value != null;
      String successMessage = isUpdating ? 'Expense updated successfully!' : 'Expense added successfully!';
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
        } else {
          await _expenseCollection!.add(newExpense.toMap());
        }
        if (Get.isDialogOpen ?? false) Get.back();
        Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn);
        Future.delayed(const Duration(milliseconds: 400), () {
          Get.snackbar("Success", successMessage, snackPosition: SnackPosition.BOTTOM);
        });
      } on FirebaseException catch (e) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar('Error', "Failed to save expense: ${e.message}");
      }
    }
  }

  Future<void> deleteExpense(String docId) async {
    if(editingId.value == docId) clearControllers();
    await _expenseCollection!.doc(docId).delete();
    Get.snackbar('Success', 'Expense deleted successfully');
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}