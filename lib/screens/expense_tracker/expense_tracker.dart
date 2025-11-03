import 'package:expense_tracker/screens/expense_tracker/expenses.dart';
import 'package:expense_tracker/screens/expense_tracker/statistics.dart';
import 'package:flutter/material.dart';

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: const TabBarView(children: [Expenses(), Statistics()]),
        bottomNavigationBar: const Material(
          color: Colors.white,
          child: SafeArea(
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent,
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Expenses'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
