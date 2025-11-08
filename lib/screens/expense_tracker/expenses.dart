import 'package:expense_tracker/core/bloc/expenses_cubit/expenses_cubit.dart';
import 'package:expense_tracker/core/constants/supabase.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:expense_tracker/core/models/user_model.dart';
import 'package:expense_tracker/core/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/core/widgets/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final TextEditingController _balanceController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return BlocProvider.value(
                value: context.read<ExpensesCubit>(),
                child: AddExpenseDialog(listKey: _listKey),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          if (state is ExpensesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpensesError) {
            return Center(child: Text(state.message));
          }
          if (state is ExpensesLoaded) {
            return Stack(
              children: [
                _buildLoadedState(state.user, state.transactions),
                if (state.isLoading == true)
                  Container(
                    color: Colors.grey.withValues(alpha: 0.5),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          } else {
            return Center(child: Text('Unexpected Error'));
          }
        },
      ),
    );
  }

  Widget _buildLoadedState(
    UserModel user,
    List<TransactionModel> transactions,
  ) {
    _balanceController.text = user.currentBalance.toString();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedDefaultTextStyle(
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.black,
              ),
              duration: Duration(seconds: 2),
              child: Text(user.currentBalance.toString(), key: UniqueKey()),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No Expenses'))
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<ExpensesCubit>().fetchExpensesData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: transactions.length,
                        itemBuilder: (context, index, animation) {
                          final transaction = transactions[index];
                          return SlideTransition(
                            key: UniqueKey(),
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: GestureDetector(
                                onLongPressStart: (details) async {
                                  await showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      details.globalPosition.dx,
                                      details.globalPosition.dy,
                                      details.globalPosition.dx,
                                      details.globalPosition.dy,
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        onTap: () async {
                                          context
                                              .read<ExpensesCubit>()
                                              .handleDeleteExpense(
                                                index,
                                                _listKey,
                                                user,
                                                transactions,
                                              );
                                        },
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                                child: TransactionTile(
                                  transactionModel: transaction,
                                  onTap: () {
                                    context.push(
                                      '/insideTransaction',
                                      extra: {'transactionModel': transaction},
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
