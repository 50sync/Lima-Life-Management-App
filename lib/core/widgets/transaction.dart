import 'dart:developer';

import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transactionModel});
  final TransactionModel transactionModel;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: transactionModel.type == TransactionType.expense
          ? Colors.red
          : Colors.green,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          log('message');
        },
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
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
