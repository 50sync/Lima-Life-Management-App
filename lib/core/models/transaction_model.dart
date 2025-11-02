import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';

class TransactionModel {
  final String? id;
  final TransactionType type;
  final num amount;
  final String? description;
  final String date;
  final int? categoryId;
  const TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryId,
  });

  factory TransactionModel.fromJson(DocumentSnapshot doc) {
    return TransactionModel(
      id: doc.id,
      type: TransactionType.values.firstWhere((e) => e.name == doc['type']),
      amount: doc['amount'],
      description: doc['description'],
      date: doc['date'] ?? DateTime.now().toUtc().toIso8601String(),
      categoryId: doc['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'amount': amount,
      'description': description,
      'date': date,
      'categoryId': categoryId,
    };
  }
}
