part of 'expenses_cubit.dart';

@immutable
sealed class ExpensesState {}

final class ExpensesInitial extends ExpensesState {}

final class ExpensesLoading extends ExpensesState {}

final class BasicLoading extends ExpensesState {}

final class ExpensesLoaded extends ExpensesState {
  final UserModel user;
  final List<TransactionModel> transactions;
  final bool? isLoading;

  ExpensesLoaded({
    required this.user,
    required this.transactions,
     this.isLoading,
  });

  ExpensesLoaded copyWith({
    bool? isLoading,

    UserModel? user,
    List<TransactionModel>? transactions,
  }) {
    return ExpensesLoaded(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      transactions: transactions ?? this.transactions,
    );
  }
}

final class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError({required this.message});
}
