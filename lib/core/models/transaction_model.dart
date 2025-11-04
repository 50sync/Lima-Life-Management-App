import 'package:expense_tracker/core/constants/supabase.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';

class TransactionModel {
  final String? id;
  final TransactionType type;
  final num amount;
  final String? description;
  final String createdAt;
  final int? categoryId;
  final String? imageUrl;

  const TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.imageUrl,
    this.categoryId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id']?.toString(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense, // fallback if null
      ),
      amount: data['amount'] ?? 0,
      description: data['description'] ?? '',
      createdAt: data['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
      categoryId: data['category_id'],
      imageUrl: data['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'created_at': createdAt,
      'category_id': categoryId,
    };
  }
}
