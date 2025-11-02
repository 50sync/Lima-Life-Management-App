part of 'firebase_cubit.dart';

@immutable
sealed class FireBaseState {}

final class FireBaseInitial extends FireBaseState {}

final class FireBaseLoading extends FireBaseState {}

final class FireBaseLoaded extends FireBaseState {
  final UserModel user;
  final List<TransactionModel> transactions;

  FireBaseLoaded({required this.user, required this.transactions});

  FireBaseLoaded copyWith({
    UserModel? user,
    List<TransactionModel>? transactions,
  }) {
    return FireBaseLoaded(
      user: user ?? this.user,
      transactions: transactions ?? this.transactions,
    );
  }
}

final class FireBaseError extends FireBaseState {
  final String message;
  FireBaseError({required this.message});
}
