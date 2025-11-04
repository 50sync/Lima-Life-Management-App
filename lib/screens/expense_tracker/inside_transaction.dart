import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:flutter/material.dart';

class InsideTransaction extends StatelessWidget {
  const InsideTransaction({super.key, required this.transactionModel});
  final TransactionModel transactionModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (transactionModel.description != null)
              Text(transactionModel.description!),
            if (transactionModel.imageUrl != null)
              SizedBox(
                height: 100,
                child: Image.network(
                  transactionModel.imageUrl!,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
