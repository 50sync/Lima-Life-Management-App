import 'dart:developer';
import 'dart:io';

import 'package:expense_tracker/core/bloc/expenses_cubit/expenses_cubit.dart';
import 'package:expense_tracker/core/config/themes/styles.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:expense_tracker/core/utils/attach_transaction_image.dart';
import 'package:expense_tracker/core/utils/upload_transaction_image.dart';
import 'package:expense_tracker/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key, required this.listKey});
  final GlobalKey<AnimatedListState> listKey;
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
  final ValueNotifier<File?> _pickedImage = ValueNotifier<File?>(null);
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
                            ? Column(
                                children: [
                                  Row(
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
                                                  log(
                                                    selectedCategory.toString(),
                                                  );
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
                                                    padding:
                                                        const EdgeInsets.all(
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
                                  ),
                                  10.verticalSpace,
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: SizedBox(
                      child: Row(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _pickedImage,
                            builder: (context, pickedImage, child) {
                              return GestureDetector(
                                onTap: () async {
                                  final File? pickedImage =
                                      await attachTransactionImage();
                                  if (pickedImage != null) {
                                    _pickedImage.value = pickedImage;
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.cyan,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: pickedImage != null
                                      ? Image.file(
                                          pickedImage,
                                          fit: BoxFit.cover,
                                        )
                                      : Center(child: Icon(Icons.add)),
                                ),
                              );
                            },
                          ),
                        ],
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
                          return BlocBuilder<ExpensesCubit, ExpensesState>(
                            builder: (context, state) {
                              return CustomButton(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (state is ExpensesLoaded) {
                                      String? imgUrl;
                                      final user = state.user;

                                      final newTransaction = TransactionModel(
                                        type: selectedType,
                                        amount: double.parse(
                                          _controllerAmount.text.trim(),
                                        ),
                                        description: _controllerDescription.text
                                            .trim(),
                                        createdAt: DateTime.now()
                                            .toUtc()
                                            .toIso8601String(),
                                        categoryId: _selectedCategory.value,
                                      );

                                      try {
                                        if (_pickedImage.value != null) {
                                          imgUrl = await uploadTransactionImage(
                                            _pickedImage.value!,
                                            user.id,
                                          );
                                        }
                                        num currentBalance =
                                            user.currentBalance;
                                        num changeAmount = num.parse(
                                          _controllerAmount.text,
                                        );
                                        num newBalance =
                                            selectedType ==
                                                TransactionType.income
                                            ? currentBalance + changeAmount
                                            : currentBalance - changeAmount;

                                        if (context.mounted) {
                                          context.pop();
                                          await context
                                              .read<ExpensesCubit>()
                                              .addTransaction(
                                                newTransaction,
                                                imageUrl: imgUrl,
                                              );
                                        }
                                      } catch (e) {
                                        log('Error saving transaction: $e');
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
