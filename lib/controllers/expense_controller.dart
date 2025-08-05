// lib/controllers/expense_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

class CategoryInfo {
  final IconData icon;
  final Color color;
  CategoryInfo(this.icon, this.color);
}

class ExpenseController extends GetxController {
  // ... (properties are unchanged)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _expenseCollection;
  var expenses = <Expense>[].obs;
  var totalExpenses = 0.0.obs;
  var weeklyTotalSpend = 0.0.obs;
  var monthlyTotalSpend = 0.0.obs;
  var yearlyTotalSpend = 0.0.obs;
  var weeklyCategorySpends = <String, double>{}.obs;
  var monthlyCategorySpends = <String, double>{}.obs;
  var yearlyCategorySpends = <String, double>{}.obs;
  var topWeeklyCategory = 'N/A'.obs;
  var topMonthlyCategory = 'N/A'.obs;
  var topYearlyCategory = 'N/A'.obs;
  final List<String> categories = [
    'Food', 'Shopping', 'Entertainment', 'Travel', 'Bills',
    'Home Rent', 'Pet Groom', 'Recharge', 'Other'
  ];
  final Map<String, CategoryInfo> categoryDetails = {
    'Food': CategoryInfo(IconlyBold.category, Colors.orange.shade300),
    'Shopping': CategoryInfo(IconlyBold.buy, Colors.purple.shade300),
    'Entertainment': CategoryInfo(IconlyBold.game, Colors.red.shade300),
    'Travel': CategoryInfo(IconlyBold.discovery, Colors.green.shade300),
    'Bills': CategoryInfo(IconlyBold.document, Colors.blue.shade300),
    'Home Rent': CategoryInfo(IconlyBold.home, Colors.brown.shade300),
    'Pet Groom': CategoryInfo(IconlyBold.user3, Colors.pink.shade300),
    'Recharge': CategoryInfo(IconlyBold.call, Colors.teal.shade300),
    'Other': CategoryInfo(IconlyBold.moreCircle, Colors.grey.shade400),
  };
  final formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController notesController;
  var selectedCategory = 'Food'.obs;
  var selectedDate = DateTime.now().obs;
  final Rxn<String> editingId = Rxn<String>();

  // A helper for our new standardized snackbar
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 1800),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  // ... (onInit and other data methods are unchanged)
  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController();
    notesController = TextEditingController();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _expenseCollection =
            _firestore.collection('users').doc(user.uid).collection('expenses');
        expenses.bindStream(getExpensesStream());
      } else {
        expenses.value = [];
        _expenseCollection = null;
        clearDashboardData();
      }
    });
    ever(expenses, (_) {
      calculateTotal();
      processDashboardData();
    });
  }
  Stream<List<Expense>> getExpensesStream() {
    if (_expenseCollection == null) return Stream.value([]);
    return _expenseCollection!
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }
  void calculateTotal() {
    totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);
  }
  void processDashboardData() {
    if (expenses.isEmpty) { clearDashboardData(); return; }
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
      if (!expenseDateOnly.isBefore(startOfYear)) { yearMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount); }
      if (!expenseDateOnly.isBefore(startOfMonth)) { monthMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount); }
      if (!expenseDateOnly.isBefore(startOfWeekDateOnly)) { weekMap.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount); }
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
  void setupEditScreen(Expense expense) {
    editingId.value = expense.id;
    amountController.text = expense.amount.toStringAsFixed(0);
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
        createdAt: isUpdating ? null : Timestamp.now(),
      );
      try {
        if (isUpdating) {
          await _expenseCollection!.doc(editingId.value).update(newExpense.toMapForUpdate());
        } else {
          await _expenseCollection!.add(newExpense.toMapForCreate());
        }
        if (Get.isDialogOpen ?? false) Get.back();
        Get.back();
        _showSnackbar("Success", successMessage);
      } on FirebaseException catch (e) {
        if (Get.isDialogOpen ?? false) Get.back();
        _showSnackbar('Error', "Failed to save expense: ${e.message}");
      }
    }
  }

  Future<void> deleteExpense(String docId) async {
    if(editingId.value == docId) clearControllers();
    await _expenseCollection!.doc(docId).delete();
    // Use the standardized snackbar
    _showSnackbar('Success', 'Expense deleted successfully');
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}