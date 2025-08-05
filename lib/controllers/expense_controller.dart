// lib/controllers/expense_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/income_model.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _expenseCollection;
  CollectionReference? _incomeCollection;

  var expenses = <Expense>[].obs;
  var incomes = <Income>[].obs;
  var allTransactions = <dynamic>[].obs;

  var totalExpenses = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalBalance = 0.0.obs;

  var weeklyTotalSpend = 0.0.obs;
  var monthlyTotalSpend = 0.0.obs;
  var yearlyTotalSpend = 0.0.obs;
  var weeklyCategorySpends = <String, double>{}.obs;
  var monthlyCategorySpends = <String, double>{}.obs;
  var yearlyCategorySpends = <String, double>{}.obs;
  var topWeeklyCategory = 'N/A'.obs;
  var topMonthlyCategory = 'N/A'.obs;
  var topYearlyCategory = 'N/A'.obs;

  final List<String> expenseCategories = [
    'Food',
    'Shopping',
    'Entertainment',
    'Travel',
    'Bills',
    'Home Rent',
    'Pet Groom',
    'Recharge',
    'Other'
  ];
  final List<String> incomeCategories = ['Salary', 'Bonus', 'Gift', 'Other'];

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
    'Salary': CategoryInfo(IconlyBold.wallet, Colors.green),
    'Bonus': CategoryInfo(IconlyBold.star, Colors.yellow.shade700),
    'Gift': CategoryInfo(IconlyBold.ticketStar, Colors.pinkAccent),
  };

  final formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController notesController;
  var selectedCategory = 'Food'.obs;
  var selectedDate = DateTime.now().obs;
  final Rxn<String> editingId = Rxn<String>();
  var isEditingExpense = true.obs;

  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController();
    notesController = TextEditingController();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _expenseCollection =
            _firestore.collection('users').doc(user.uid).collection('expenses');
        _incomeCollection =
            _firestore.collection('users').doc(user.uid).collection('income');
        expenses.bindStream(getExpensesStream());
        incomes.bindStream(getIncomeStream());
      } else {
        expenses.value = [];
        incomes.value = [];
        allTransactions.value = [];
        _expenseCollection = null;
        _incomeCollection = null;
        clearDashboardData();
        clearTotals();
      }
    });

    everAll([expenses, incomes], (_) {
      calculateTotals();
      combineAndSortTransactions();
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

  Stream<List<Income>> getIncomeStream() {
    if (_incomeCollection == null) return Stream.value([]);
    return _incomeCollection!.orderBy('date', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList());
  }

  void combineAndSortTransactions() {
    List<dynamic> combined = [];
    combined.addAll(expenses);
    combined.addAll(incomes);
    combined.sort((a, b) => b.date.compareTo(a.date));
    allTransactions.value = combined;
  }

  void calculateTotals() {
    totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);
    totalIncome.value = incomes.fold(0.0, (sum, item) => sum + item.amount);
    totalBalance.value = totalIncome.value - totalExpenses.value;
  }

  void clearTotals() {
    totalExpenses.value = 0.0;
    totalIncome.value = 0.0;
    totalBalance.value = 0.0;
  }

  void processDashboardData() {
    if (expenses.isEmpty) {
      clearDashboardData();
      return;
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDateOnly =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    final weekMap = <String, double>{};
    final monthMap = <String, double>{};
    final yearMap = <String, double>{};

    for (var expense in expenses) {
      final expenseDateOnly =
          DateTime(expense.date.year, expense.date.month, expense.date.day);

      if (!expenseDateOnly.isBefore(startOfYear)) {
        yearMap.update(expense.category, (value) => value + expense.amount,
            ifAbsent: () => expense.amount);
      }
      if (!expenseDateOnly.isBefore(startOfMonth)) {
        monthMap.update(expense.category, (value) => value + expense.amount,
            ifAbsent: () => expense.amount);
      }
      if (!expenseDateOnly.isBefore(startOfWeekDateOnly)) {
        weekMap.update(expense.category, (value) => value + expense.amount,
            ifAbsent: () => expense.amount);
      }
    }

    weeklyCategorySpends.value = weekMap;
    weeklyTotalSpend.value =
        weekMap.values.fold(0.0, (sum, item) => sum + item);
    topWeeklyCategory.value = weekMap.isNotEmpty
        ? weekMap.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    monthlyCategorySpends.value = monthMap;
    monthlyTotalSpend.value =
        monthMap.values.fold(0.0, (sum, item) => sum + item);
    topMonthlyCategory.value = monthMap.isNotEmpty
        ? monthMap.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    yearlyCategorySpends.value = yearMap;
    yearlyTotalSpend.value =
        yearMap.values.fold(0.0, (sum, item) => sum + item);
    topYearlyCategory.value = yearMap.isNotEmpty
        ? yearMap.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';
  }

  void clearDashboardData() {
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

  void setupEditScreen(dynamic transaction) {
    clearControllers(isExpense: transaction is Expense);
    if (transaction is Expense) {
      isEditingExpense.value = true;
      editingId.value = transaction.id;
      // --- THIS IS THE FIX ---
      // Use .toString() instead of .toStringAsFixed(0)
      amountController.text = transaction.amount.toString();
      notesController.text = transaction.notes ?? '';
      selectedCategory.value = transaction.category;
      selectedDate.value = transaction.date;
    } else if (transaction is Income) {
      isEditingExpense.value = false;
      editingId.value = transaction.id;
      // --- THIS IS THE FIX ---
      // Use .toString() instead of .toStringAsFixed(0)
      amountController.text = transaction.amount.toString();
      notesController.text = transaction.notes ?? '';
      selectedCategory.value = transaction.category;
      selectedDate.value = transaction.date;
    }
  }

  void clearControllers({bool isExpense = true}) {
    editingId.value = null;
    amountController.clear();
    notesController.clear();
    selectedCategory.value =
        isExpense ? expenseCategories.first : incomeCategories.first;
    selectedDate.value = DateTime.now();
    formKey.currentState?.reset();
  }

  Future<void> saveExpense() async {
    if (formKey.currentState!.validate()) {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      final isUpdating = editingId.value != null;
      String successMessage =
          isUpdating ? 'Expense updated!' : 'Expense added!';
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
          await _expenseCollection!
              .doc(editingId.value)
              .update(newExpense.toMapForUpdate());
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
    if (editingId.value == docId) clearControllers();
    await _expenseCollection!.doc(docId).delete();
    _showSnackbar('Success', 'Expense deleted successfully');
  }

  Future<void> saveIncome() async {
    if (formKey.currentState!.validate()) {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);
      final isUpdating = editingId.value != null;
      String successMessage = isUpdating ? 'Income updated!' : 'Income added!';
      final newIncome = Income(
        id: editingId.value,
        category: selectedCategory.value,
        amount: double.parse(amountController.text),
        date: selectedDate.value,
        notes: notesController.text,
        createdAt: isUpdating ? null : Timestamp.now(),
      );
      try {
        if (isUpdating) {
          await _incomeCollection!
              .doc(editingId.value)
              .update(newIncome.toMapForUpdate());
        } else {
          await _incomeCollection!.add(newIncome.toMapForCreate());
        }
        if (Get.isDialogOpen ?? false) Get.back();
        Get.back();
        _showSnackbar("Success", successMessage);
      } on FirebaseException catch (e) {
        if (Get.isDialogOpen ?? false) Get.back();
        _showSnackbar('Error', "Failed to save income: ${e.message}");
      }
    }
  }

  Future<void> deleteIncome(String docId) async {
    if (editingId.value == docId) clearControllers(isExpense: false);
    await _incomeCollection!.doc(docId).delete();
    _showSnackbar('Success', 'Income entry deleted');
  }

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

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
