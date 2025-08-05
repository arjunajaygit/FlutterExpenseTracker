// lib/models/expense_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String? id;
  String category;
  double amount;
  DateTime date;
  String? notes;
  Timestamp? createdAt; // Can be null for updates

  Expense({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.createdAt,
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
      createdAt: data['createdAt'],
    );
  }

  // Method for creating a new expense
  Map<String, dynamic> toMapForCreate() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': createdAt ?? Timestamp.now(), // Ensure it's set
    };
  }
  
  // Method for updating an existing expense
  Map<String, dynamic> toMapForUpdate() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      // We don't update createdAt, so it's not included here
    };
  }
}