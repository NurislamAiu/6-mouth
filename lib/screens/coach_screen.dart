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
            title: 'Коуч',
            trailing: 'AI',
            subtitle: _coachLine(gamification.todayScore),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ФОКУС ДНЯ', style: AppTheme.labelStyle),
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
                Text('ЗАКРЫТЬ ДЕНЬ', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                _CoachStep(
                  number: '01',
                  text: gamification.todayScore >= 60
                      ? 'Задача выполнена.'
                      : 'Выполни задачу в разделе Сегодня.',
                  done: gamification.todayScore >= 60,
                ),
                const SizedBox(height: 12),
                _CoachStep(
                  number: '02',
                  text: gamification.todayScore >= 80
                      ? 'Проверка завершена.'
                      : 'Ответь на проверку.',
                  done: gamification.todayScore >= 80,
                ),
                const SizedBox(height: 12),
                _CoachStep(
                  number: '03',
                  text: gamification.todayScore == 100
                      ? 'Рефлексия завершена.'
                      : 'Напиши одну честную рефлексию.',
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
                Text('МОЯ ЦЕЛЬ', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                Text(
                  goal?.goal ?? 'Твоя цель появится здесь.',
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
                Text('ПОСЛЕДНЯЯ РЕФЛЕКСИЯ', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                Text(
                  lastReflection ??
                      'Напиши рефлексию сегодня, и она появится здесь.',
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
    if (score == 100) return 'Хорошо. Защити серию завтра.';
    if (score >= 60) return 'Главное сделано. Закрой петлю.';
    return 'Сделай наименьшее реальное действие сейчас.';
  }

  String _focusFor(int score) {
    if (score == 100) {
      return 'Ты уже победил сегодня. Держи обещание маленьким завтра, чтобы цепь оставалась живой.';
    }
    if (score >= 60) {
      return 'Задача выполнена. Ответь на проверку и оставь одну честную строку до конца дня.';
    }
    return 'Забудь о полном плане на минуту. Выполни одну задачу в разделе Сегодня и возьми победу.';
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
