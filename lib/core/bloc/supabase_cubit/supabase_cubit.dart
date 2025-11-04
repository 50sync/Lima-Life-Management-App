import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expense_tracker/core/constants/supabase.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/user_model.dart';
import 'package:meta/meta.dart';

part 'supabase_state.dart';

class SupabaseCubit extends Cubit<SupabaseState> {
  SupabaseCubit() : super(SupabaseInitial());

  StreamSubscription? _userSubscription;
  StreamSubscription? _transactionsSubscription;

  void listenToUserData() {
    emit(SupabaseLoading());

    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();

    // Stream the user row from Supabase
    _userSubscription = supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId!)
        .listen(
          (users) {
            if (users.isEmpty) {
              emit(SupabaseError(message: 'User not found'));
              return;
            }

            try {
              final user = UserModel.fromJson(users.first);
              _listenToTransactions(user);
            } catch (e) {
              emit(SupabaseError(message: 'Failed to parse user data: $e'));
            }
          },
          onError: (error) {
            emit(SupabaseError(message: 'User data error: $error'));
          },
          cancelOnError: false,
        );
  }

  void _listenToTransactions(UserModel user) {
    _transactionsSubscription?.cancel();

    _transactionsSubscription = supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .listen(
          (transactionsSnap) {
            try {
              final transactions = transactionsSnap
                  .map((row) => TransactionModel.fromJson(row))
                  .toList();

              emit(SupabaseLoaded(user: user, transactions: transactions));
            } catch (e) {
              emit(SupabaseError(message: 'Failed to parse transactions: $e'));
            }
          },
          onError: (error) {
            emit(SupabaseError(message: 'Transactions error: $error'));
          },
          cancelOnError: false,
        );
  }

  void stopListening() {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _userSubscription = null;
    _transactionsSubscription = null;
    emit(SupabaseInitial());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
