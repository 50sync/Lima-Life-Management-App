import 'package:expense_tracker/core/bloc/expenses_cubit/expenses_cubit.dart';
import 'package:expense_tracker/screens/auth/login.dart';
import 'package:expense_tracker/screens/expense_tracker/expense_tracker.dart';
import 'package:expense_tracker/screens/expense_tracker/inside_transaction.dart';
import 'package:expense_tracker/screens/home/home.dart';
import 'package:expense_tracker/screens/splash/splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => Splash()),
    GoRoute(
      path: '/loginAndSignup',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return LoginAndSignup(isSignup: data['isSignup']);
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => Home()),
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (context) => ExpensesCubit()..fetchExpensesData(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/expenseTracker',
          builder: (context, state) => ExpenseTracker(),
        ),
        GoRoute(
          path: '/insideTransaction',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return InsideTransaction(
              transactionModel: data['transactionModel'],
            );
          },
        ),
      ],
    ),
  ],
);
