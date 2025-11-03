import 'dart:developer';

import 'package:expense_tracker/core/bloc/supabase_cubit/firebase_cubit.dart';
import 'package:expense_tracker/core/config/themes/styles.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/constants/firebase.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:expense_tracker/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController _controllerAmount = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();
  final ValueNotifier<TransactionType> _selectedType =
      ValueNotifier<TransactionType>(TransactionType.income);
  final ValueNotifier<int?> _selectedCategory = ValueNotifier<int?>(null);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controllerAmount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
              decoration: InputDecoration(
                border: inputBorder,
                hintText: 'Amount',
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _controllerDescription,
            decoration: InputDecoration(
              border: inputBorder,
              hintText: 'Description',
            ),
          ),
          SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: _selectedType,
            builder: (context, selectedType, child) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectedType.value = TransactionType.income;
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedType == TransactionType.income
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green,
                              ),
                              child: Center(
                                child: Text(
                                  'in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectedType.value = TransactionType.expense;
                            _selectedCategory.value =
                                categories.first.icon.codePoint;
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedType == TransactionType.expense
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                              ),
                              child: Center(
                                child: Text(
                                  'out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.verticalSpace,
                  IntrinsicHeight(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: selectedType == TransactionType.expense
                            ? 1
                            : 0,
                        child: selectedType == TransactionType.expense
                            ? Row(
                                children: List.generate(categories.length, (
                                  index,
                                ) {
                                  return ValueListenableBuilder(
                                    valueListenable: _selectedCategory,
                                    builder:
                                        (context, selectedCategory, child) {
                                          return GestureDetector(
                                            onTap: () {
                                              _selectedCategory.value =
                                                  categories[index]
                                                      .icon
                                                      .codePoint;
                                              log(selectedCategory.toString());
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      selectedCategory ==
                                                          categories[index]
                                                              .icon
                                                              .codePoint
                                                      ? Colors.black
                                                      : Colors.transparent,
                                                  width: 3,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                child: Icon(
                                                  categories[index].icon,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  );
                                }),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: _selectedCategory,
                    builder: (context, selectedCategory, child) {
                      return ValueListenableBuilder(
                        valueListenable: _selectedType,
                        builder: (context, selectedType, child) {
                          return BlocBuilder<FireBaseCubit, FireBaseState>(
                            builder: (context, state) {
                              return CustomButton(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (state is FireBaseLoaded) {
                                      final user = state.user;
                                      transactionsCollection.add(
                                        TransactionModel(
                                          type: selectedType,
                                          amount: double.parse(
                                            _controllerAmount.text,
                                          ),
                                          description: _controllerDescription
                                              .text
                                              .trim(),
                                          date: DateTime.now()
                                              .toUtc()
                                              .toIso8601String(),
                                          categoryId: selectedCategory,
                                        ).toJson(),
                                      );
                                      num currentBalance = user.currentBalance;
                                      num changeAmount = num.parse(
                                        _controllerAmount.text,
                                      );

                                      num newBalance =
                                          selectedType == TransactionType.income
                                          ? currentBalance + changeAmount
                                          : currentBalance - changeAmount;
                                      fireStore
                                          .collection('users')
                                          .doc(user.id)
                                          .update({'balance': newBalance});
                                      if (context.mounted) {
                                        context.pop();
                                      }
                                    }
                                  }
                                },
                                text: 'Save',
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
