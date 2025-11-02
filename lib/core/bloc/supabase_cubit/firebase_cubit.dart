import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:expense_tracker/core/constants/firebase.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/user_model.dart';
import 'package:meta/meta.dart';

part 'firebase_state.dart';

class FireBaseCubit extends Cubit<FireBaseState> {
  FireBaseCubit() : super(FireBaseInitial());

  StreamSubscription? _userSubscription;
  StreamSubscription? _transactionsSubscription;

  void listenToUserData() {
    emit(FireBaseLoading());

    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();

    _userSubscription = userCollection.snapshots().listen(
      (userDoc) {
        if (!userDoc.exists) {
          emit(FireBaseError(message: 'User not found'));
          return;
        }

        try {
          final user = UserModel.fromJson(userDoc);
          _listenToTransactions(user);
        } catch (e) {
          emit(FireBaseError(message: 'Failed to parse user data: $e'));
        }
      },
      onError: (error) {
        emit(FireBaseError(message: 'User data error: $error'));
      },
      cancelOnError: false,
    );
  }

  void _listenToTransactions(UserModel user) {
    _transactionsSubscription?.cancel();

    _transactionsSubscription = transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
          (transactionsSnap) {
            try {
              final transactions = transactionsSnap.docs
                  .map((doc) => TransactionModel.fromJson(doc))
                  .toList();

              emit(FireBaseLoaded(user: user, transactions: transactions));
            } catch (e) {
              emit(FireBaseError(message: 'Failed to parse transactions: $e'));
            }
          },
          onError: (error) {
            emit(FireBaseError(message: 'Transactions error: $error'));
          },
          cancelOnError: false,
        );
  }

  void refreshData() {
    listenToUserData();
  }

  void stopListening() {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _userSubscription = null;
    _transactionsSubscription = null;
    emit(FireBaseInitial());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
