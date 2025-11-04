part of 'supabase_cubit.dart';

@immutable
sealed class SupabaseState {}

final class SupabaseInitial extends SupabaseState {}

final class SupabaseLoading extends SupabaseState {}

final class SupabaseLoaded extends SupabaseState {
  final UserModel user;
  final List<TransactionModel> transactions;

  SupabaseLoaded({required this.user, required this.transactions});

  SupabaseLoaded copyWith({
    UserModel? user,
    List<TransactionModel>? transactions,
  }) {
    return SupabaseLoaded(
      user: user ?? this.user,
      transactions: transactions ?? this.transactions,
    );
  }
}

final class SupabaseError extends SupabaseState {
  final String message;
  SupabaseError({required this.message});
}
