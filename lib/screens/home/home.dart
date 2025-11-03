import 'package:expense_tracker/core/bloc/supabase_cubit/firebase_cubit.dart';
import 'package:expense_tracker/core/models/home_section_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<HomeSectionModel> items = [
    HomeSectionModel(
      label: 'Expenses 💸',
      route: '/expenseTracker',
      color: Colors.green,
    ),
    HomeSectionModel(label: 'Tasks', route: '', color: Colors.red),
  ];

  int? draggingIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return DragTarget<int>(
                onWillAcceptWithDetails: (fromIndex) => fromIndex.data != index,
                onAcceptWithDetails: (fromIndex) {
                  setState(() {
                    final moved = items.removeAt(fromIndex.data);
                    items.insert(index, moved);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return BlocProvider(
                    create: (context) => FireBaseCubit()..listenToUserData(),
                    child: Draggable<int>(
                      data: index,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildTile(
                          item,
                          Colors.blueAccent.withValues(alpha: 0.8),
                        ),
                      ),
                      onDragStarted: () =>
                          setState(() => draggingIndex = index),
                      onDragEnd: (_) => setState(() => draggingIndex = null),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildTile(item),
                      ),
                      child: _buildTile(item),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(HomeSectionModel homeSectionModel, [Color? color]) {
    final ValueNotifier<double> scale = ValueNotifier(1.0);
    return ValueListenableBuilder(
      valueListenable: scale,
      builder: (context, scaleValue, child) {
        return GestureDetector(
          onTapDown: (_) => scale.value = 0.98,
          onTapUp: (_) {
            scale.value = 1;
            context.push(homeSectionModel.route);
          },
          onTapCancel: () => scale.value = 1,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: scaleValue,
            child: Card(
              elevation: 3,
              color: color ?? homeSectionModel.color,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    homeSectionModel.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
