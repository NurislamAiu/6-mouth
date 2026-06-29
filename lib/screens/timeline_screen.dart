import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/goal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_card.dart';
import '../widgets/month_row.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  static const _months = [
    'Foundation',
    'Consistency',
    'Momentum',
    'Expansion',
    'Pressure',
    'Identity',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalControllerProvider);
    final day = goal == null ? 1 : currentDayFor(goal).clamp(1, 180);
    final progress = (day / 180).clamp(0.0, 1.0);
    final currentMonth = goal == null ? 1 : currentMonthFor(goal);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          AppHeader(
            title: 'Timeline',
            trailing: '${(progress * 100).round()}%',
            subtitle: _months[currentMonth - 1],
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR 6 MONTHS', style: AppTheme.labelStyle),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppTheme.background,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: List.generate(6, (index) {
                final number = index + 1;
                return MonthRow(
                  number: number,
                  name: _months[index],
                  completed: number < currentMonth,
                  current: number == currentMonth,
                  summary: goal?.lastMonthlySummary,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
