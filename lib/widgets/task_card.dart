import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/log_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';
import 'app_card.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key});

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
              Text('01', style: AppTheme.labelStyle),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'СЕГОДНЯ',
                  style: AppTheme.labelStyle.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.curve,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: log.taskDone
                      ? AppTheme.primaryText
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  log.taskDone ? 'ГОТОВО' : '+60 XP',
                  style: AppTheme.labelStyle.copyWith(
                    color: log.taskDone
                        ? AppTheme.background
                        : AppTheme.primaryText,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: AppMotion.normal,
            switchInCurve: AppMotion.curve,
            switchOutCurve: AppMotion.curve,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              log.task,
              key: ValueKey(log.task),
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 28,
                height: 1.08,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: log.taskDone ? 'Выполнено' : 'Выполнить задачу',
            filled: log.taskDone,
            onPressed: () {
              ref
                  .read(logControllerProvider.notifier)
                  .upsert(log.copyWith(taskDone: !log.taskDone));
            },
          ),
        ],
      ),
    );
  }
}
