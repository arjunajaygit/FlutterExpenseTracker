// /Users/arjun/ExpenseTracker/lib/models/expense_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String? id;
  String category;
  double amount;
  DateTime date;
  String? notes;
  Timestamp createdAt;

  Expense({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  // Factory constructor to create an Expense from a Firestore document
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      category: data['category'] ?? 'General',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert an Expense object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}