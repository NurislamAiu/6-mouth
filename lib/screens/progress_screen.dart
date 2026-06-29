import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gamification_provider.dart';
import '../providers/log_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';
import '../widgets/gamification_widgets.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final logs = ref.watch(logControllerProvider);
    final completed = logs.where((log) => log.taskDone).length;
    final reflections = logs
        .where((log) => (log.reflection ?? '').trim().isNotEmpty)
        .length;
    final nextBadge = gamification.badges.where((badge) => !badge.unlocked);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          AppHeader(
            title: 'Progress',
            trailing: 'LVL ${gamification.level}',
            subtitle: 'Your proof is stacking.',
          ),
          const SizedBox(height: 18),
          LevelCard(gamification: gamification),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT UNLOCK', style: AppTheme.labelStyle),
                const SizedBox(height: 14),
                Text(
                  nextBadge.isEmpty
                      ? 'All current achievements are unlocked.'
                      : nextBadge.first.title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nextBadge.isEmpty
                      ? 'Keep stacking daily wins.'
                      : nextBadge.first.subtitle,
                  style: AppTheme.secondaryStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          StreakPulseCard(days: gamification.recentDays),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: _ProgressMetric(label: 'WINS', value: '$completed'),
                ),
                Container(width: 1, height: 42, color: AppTheme.border),
                Expanded(
                  child: _ProgressMetric(label: 'NOTES', value: '$reflections'),
                ),
                Container(width: 1, height: 42, color: AppTheme.border),
                Expanded(
                  child: _ProgressMetric(
                    label: 'SCORE',
                    value: '${gamification.todayScore}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          BadgeShelf(badges: gamification.badges),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.displayStyle.copyWith(fontSize: 34)),
        const SizedBox(height: 10),
        Text(
          label,
          style: AppTheme.labelStyle.copyWith(
            color: AppTheme.secondaryText,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
