import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expense_tracker/core/constants/supabase.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:expense_tracker/core/models/user_model.dart';
import 'package:meta/meta.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  ExpensesCubit() : super(ExpensesInitial());

  static const String _usersTable = 'users';
  static const String _transactionsTable = 'transactions';
  static const String _userIdColumn = 'user_id';
  static const String _balanceColumn = 'balance';
  static const String _imageUrlColumn = 'image_url';

  Future<void> fetchExpensesData() async {
    try {
      emit(ExpensesLoading());

      final user = await _fetchUserData();
      final transactions = await _fetchUserTransactions(user.id);

      emit(ExpensesLoaded(user: user, transactions: transactions));
    } catch (error) {
      emit(ExpensesError(message: 'Failed to fetch expenses: $error'));
    }
  }

  Future<UserModel> _fetchUserData() async {
    final response = await supabase
        .from(_usersTable)
        .select()
        .eq('id', _getCurrentUserId())
        .single();

    return UserModel.fromJson(response);
  }

  Future<List<TransactionModel>> _fetchUserTransactions(String userId) async {
    final response = await supabase
        .from(_transactionsTable)
        .select()
        .eq(_userIdColumn, userId)
        .order('created_at', ascending: false);

    return response
        .map((transaction) => TransactionModel.fromJson(transaction))
        .toList();
  }

  Future<void> addTransaction(
    TransactionModel newTransaction, {
    String? imageUrl,
  }) async {
    try {
      final currentState = state;
      if (currentState is! ExpensesLoaded) return;

      emit(currentState.copyWith(isLoading: true));

      // Create transaction
      final createdTransaction = await _createTransaction(
        newTransaction,
        imageUrl,
      );

      // Update user balance
      final updatedUser = await _updateUserBalance(
        currentState.user.id,
        newTransaction.type == TransactionType.expense
            ? currentState.user.currentBalance - newTransaction.amount
            : currentState.user.currentBalance + newTransaction.amount,
      );

      // Update state
      final updatedTransactions = [
        createdTransaction,
        ...currentState.transactions,
      ];

      emit(
        currentState.copyWith(
          user: updatedUser,
          transactions: updatedTransactions,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(ExpensesError(message: 'Failed to add transaction: $error'));
      // Revert to previous state on error
    }
  }

  Future<TransactionModel> _createTransaction(
    TransactionModel transaction,
    String? imageUrl,
  ) async {
    final response = await supabase
        .from(_transactionsTable)
        .insert({
          ...transaction.toJson(),
          _userIdColumn: _getCurrentUserId(),
          if (imageUrl != null) _imageUrlColumn: imageUrl,
        })
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  Future<UserModel> _updateUserBalance(String userId, num newBalance) async {
    final response = await supabase
        .from(_usersTable)
        .update({_balanceColumn: newBalance})
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final currentState = state;
      if (currentState is! ExpensesLoaded) return;

      emit(currentState.copyWith(isLoading: true));

      // Find transaction to delete
      final transactionIndex = currentState.transactions.indexWhere(
        (t) => t.id == transactionId,
      );

      if (transactionIndex == -1) {
        throw Exception('Transaction not found');
      }

      final deletedTransaction = currentState.transactions[transactionIndex];

      // Delete from database
      await supabase.from(_transactionsTable).delete().eq('id', transactionId);

      // Update user balance
      final newBalance = deletedTransaction.type == TransactionType.expense
          ? currentState.user.currentBalance + deletedTransaction.amount
          : currentState.user.currentBalance - deletedTransaction.amount;

      final updatedUser = await _updateUserBalance(
        currentState.user.id,
        newBalance,
      );

      // Update state
      final updatedTransactions = List<TransactionModel>.from(
        currentState.transactions,
      );
      updatedTransactions.removeAt(transactionIndex);

      emit(
        currentState.copyWith(
          user: updatedUser,
          transactions: updatedTransactions,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(ExpensesError(message: 'Failed to delete transaction: $error'));
    }
  }

  String _getCurrentUserId() {
    // Implement your user ID retrieval logic here
    // This should come from your auth system
    return userId!; // Replace with actual implementation
  }
}
