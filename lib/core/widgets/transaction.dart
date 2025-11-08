import 'dart:developer';

import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transactionModel,
    this.onTap,
  });
  final TransactionModel transactionModel;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: transactionModel.type == TransactionType.expense
          ? Colors.red
          : Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      child: InkWell(
        onTap: () {
          log('message');
          if (onTap != null) {
            onTap!();
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          title: Text(transactionModel.amount.toString()),
          subtitle:
              transactionModel.description != null &&
                  transactionModel.description!.isNotEmpty
              ? Text(transactionModel.description!)
              : null,
          trailing: IntrinsicWidth(
            child: Row(
              children: [
                if (transactionModel.type == TransactionType.expense)
                  Icon(
                    categories
                        .firstWhere(
                          (category) =>
                              category.icon.codePoint ==
                              transactionModel.categoryId,
                        )
                        .icon,
                  ),
                Icon(
                  transactionModel.type == TransactionType.expense
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
