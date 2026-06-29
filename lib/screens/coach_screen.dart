import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/goal_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/log_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalControllerProvider);
    final logs = ref.watch(logControllerProvider);
    final gamification = ref.watch(gamificationProvider);
    final lastReflection = logs.reversed
        .map((log) => log.reflection)
        .whereType<String>()
        .where((reflection) => reflection.trim().isNotEmpty)
        .firstOrNull;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          AppHeader(
            title: 'Coach',
            trailing: 'AI',
            subtitle: _coachLine(gamification.todayScore),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY FOCUS', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                Text(
                  _focusFor(gamification.todayScore),
                  style: AppTheme.bodyStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLOSE THE DAY', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                _CoachStep(
                  number: '01',
                  text: gamification.todayScore >= 60
                      ? 'Task is complete.'
                      : 'Complete the task on Today.',
                  done: gamification.todayScore >= 60,
                ),
                const SizedBox(height: 12),
                _CoachStep(
                  number: '02',
                  text: gamification.todayScore >= 80
                      ? 'Check-in is complete.'
                      : 'Answer the identity check.',
                  done: gamification.todayScore >= 80,
                ),
                const SizedBox(height: 12),
                _CoachStep(
                  number: '03',
                  text: gamification.todayScore == 100
                      ? 'Reflection is complete.'
                      : 'Write one honest reflection.',
                  done: gamification.todayScore == 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GOAL LENS', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                Text(
                  goal?.goal ?? 'Your goal will appear here.',
                  style: AppTheme.bodyStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LAST REFLECTION', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                Text(
                  lastReflection ??
                      'Write one reflection today and it will show here.',
                  style: AppTheme.secondaryStyle.copyWith(
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _coachLine(int score) {
    if (score == 100) return 'Good. Protect the streak tomorrow.';
    if (score >= 60) return 'Main action done. Close the loop.';
    return 'Do the smallest real action now.';
  }

  String _focusFor(int score) {
    if (score == 100) {
      return 'You already won today. Keep the promise small tomorrow so the chain stays alive.';
    }
    if (score >= 60) {
      return 'The task is handled. Answer the check-in and leave one honest line before the day ends.';
    }
    return 'Ignore the full plan for a moment. Complete the one task on Today and claim the win.';
  }
}

class _CoachStep extends StatelessWidget {
  const _CoachStep({
    required this.number,
    required this.text,
    required this.done,
  });

  final String number;
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? AppTheme.primaryText : AppTheme.background,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            done ? '✓' : number,
            style: AppTheme.labelStyle.copyWith(
              color: done ? AppTheme.background : AppTheme.primaryText,
              letterSpacing: done ? 0 : 1,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTheme.secondaryStyle.copyWith(
              color: done ? AppTheme.secondaryText : AppTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
