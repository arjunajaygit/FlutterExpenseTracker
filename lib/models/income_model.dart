// lib/models/income_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  String? id;
  String category;
  double amount;
  DateTime date;
  String? notes;
  Timestamp? createdAt;

  Income({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.createdAt,
  });

  factory Income.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Income(
      id: doc.id,
      category: data['category'] ?? 'Other',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMapForCreate() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }
  
  Map<String, dynamic> toMapForUpdate() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }
}