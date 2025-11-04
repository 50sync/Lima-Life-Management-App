import 'package:expense_tracker/core/bloc/supabase_cubit/supabase_cubit.dart';
import 'package:expense_tracker/core/constants/supabase.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:expense_tracker/core/models/user_model.dart';
import 'package:expense_tracker/core/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/core/widgets/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> with TickerProviderStateMixin {
  final TextEditingController _balanceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return BlocProvider.value(
                    value: context.read<SupabaseCubit>(),
                    child: AddExpenseDialog(),
                  );
                },
              );
            },
            child: Icon(Icons.add),
          );
        },
      ),
      body: BlocBuilder<SupabaseCubit, SupabaseState>(
        builder: (context, state) {
          if (state is SupabaseLoaded) {
            return _buildLoadedState(state);
          } else if (state is SupabaseLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SupabaseError) {
            return Center(child: Text(state.message));
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildLoadedState(SupabaseLoaded state) {
    final List<TransactionModel> transactions = state.transactions;
    final UserModel user = state.user;
    _balanceController.text = user.currentBalance.toString();
    Future<void> handleDeleteExpense(int index) async {
      await supabase
          .from('transactions')
          .delete()
          .eq('id', transactions[index].id!);
      num currentBalance = user.currentBalance;
      num changeAmount = transactions[index].amount;
      num newBalance = transactions[index].type == TransactionType.expense
          ? currentBalance + changeAmount
          : currentBalance - changeAmount;
      await await supabase
          .from('users')
          .update({'balance': newBalance})
          .eq('id', user.id);
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _balanceController,
              decoration: InputDecoration(border: InputBorder.none),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^-?[0-9]*\.?[0-9]*$'),
                ),
              ],
              keyboardType: TextInputType.number,
              onSubmitted: (value) async {
                await supabase
                    .from('users')
                    .update({'balance': num.parse(value)})
                    .eq('id', user.id);
              },

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
          ),
          if (state.transactions.isEmpty)
            Expanded(child: Center(child: Text('No Expenses')))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<SupabaseCubit>().listenToUserData();
                },
                child: ListView(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final slidableController = SlidableController(this);
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 8.0,
                            left: 8.0,
                          ),
                          child: Slidable(
                            controller: slidableController,
                            key: UniqueKey(),
                            endActionPane: ActionPane(
                              extentRatio: 0.3,
                              motion: GestureDetector(
                                onTap: () async {
                                  await slidableController.dismiss(
                                    ResizeRequest(
                                      Duration(milliseconds: 100),
                                      () {
                                        handleDeleteExpense(index);
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.red,
                                  child: Center(
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              children: [],
                            ),
                            child: TransactionTile(
                              transactionModel: transactions[index],
                              onTap: () {
                                context.push(
                                  '/insideTransaction',
                                  extra: {
                                    'transactionModel': transactions[index],
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
