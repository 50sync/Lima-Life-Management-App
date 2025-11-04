import 'package:expense_tracker/core/bloc/supabase_cubit/supabase_cubit.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/models/transaction_model.dart';
import 'package:expense_tracker/core/models/transaction_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SupabaseCubit, SupabaseState>(
        builder: (context, state) {
          if (state is SupabaseLoaded) {
            final List<TransactionModel> transactions = state.transactions;
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (transactions.isEmpty)
                    Center(child: Text('No Statistics'))
                  else ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            titleSunbeamLayout: true,
                            sections: [
                              ...List.generate(
                                transactions
                                    .where(
                                      (transaction) =>
                                          transaction.type ==
                                          TransactionType.income,
                                    )
                                    .toList()
                                    .length,
                                (index) {
                                  return PieChartSectionData(
                                    color: Colors.green,
                                  );
                                },
                              ),
                              ...List.generate(
                                transactions
                                    .where(
                                      (transaction) =>
                                          transaction.type ==
                                          TransactionType.expense,
                                    )
                                    .toList()
                                    .length,
                                (index) {
                                  return PieChartSectionData(color: Colors.red);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0.4.sh,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate max count for proportional scaling
                          final categoryCounts = categories.map((category) {
                            return state.transactions
                                .where(
                                  (transaction) =>
                                      transaction.categoryId ==
                                      category.icon.codePoint,
                                )
                                .length;
                          }).toList();

                          final maxCount = categoryCounts.isNotEmpty
                              ? categoryCounts.reduce((a, b) => a > b ? a : b)
                              : 1;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ...List.generate(categories.length, (index) {
                                final categoryCount = categoryCounts[index];
                                final barHeight = maxCount == 0
                                    ? 0
                                    : (categoryCount / maxCount) * 0.3.sh;

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(categoryCount.toString()),
                                    Container(
                                      height: barHeight.toDouble(),
                                      width: 20,
                                      color: Colors
                                          .blue, // Consider using category colors
                                      margin: const EdgeInsets.only(top: 4),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      categories[index].name,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
