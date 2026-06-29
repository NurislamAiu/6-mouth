import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/day_log_model.dart';
import '../providers/log_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class CheckinCard extends ConsumerWidget {
  const CheckinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(todayLogSyncProvider);
    if (log == null) return const SizedBox.shrink();
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('02', style: AppTheme.labelStyle),
              const SizedBox(width: 12),
              Text(
                'ПРОВЕРКА',
                style: AppTheme.labelStyle.copyWith(
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Твои действия совпадают с тем, кем ты становишься?',
            style: AppTheme.bodyStyle.copyWith(fontSize: 19, height: 1.25),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Choice(log: log, value: true, label: 'ДА'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Choice(log: log, value: false, label: 'НЕТ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Choice extends ConsumerWidget {
  const _Choice({required this.log, required this.value, required this.label});

  final DayLogModel log;
  final bool value;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = log.checkInAnswer == value;
    return GestureDetector(
      onTap: () {
        ref
            .read(logControllerProvider.notifier)
            .upsert(log.copyWith(checkInAnswer: value));
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryText : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppTheme.primaryText : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelStyle.copyWith(
            color: selected ? AppTheme.background : AppTheme.primaryText,
          ),
        ),
      ),
    );
  }
}
