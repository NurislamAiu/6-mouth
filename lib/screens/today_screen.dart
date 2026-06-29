import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/goal_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/log_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';
import '../widgets/checkin_card.dart';
import '../widgets/gamification_widgets.dart';
import '../widgets/reflect_card.dart';
import '../widgets/task_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalControllerProvider);
    final today = ref.watch(todayLogProvider);
    final gamification = ref.watch(gamificationProvider);
    final day = goal == null ? 1 : currentDayFor(goal).clamp(1, 180);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          AppHeader(
            title: '6MONTH',
            trailing: 'DAY $day',
            subtitle: goal == null ? 'Today starts here.' : _todayLine(day),
          ),
          const SizedBox(height: 18),
          CompactGameStrip(gamification: gamification),
          const SizedBox(height: 16),
          today.when(
            data: (log) => Column(
              children: [
                TaskCard(log: log),
                if (log.taskDone) ...[
                  const SizedBox(height: 14),
                  const _CompletionBanner(),
                ],
                const SizedBox(height: 14),
                CheckinCard(log: log),
                const SizedBox(height: 14),
                ReflectCard(log: log),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryText,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, _) =>
                Text('Could not load today.', style: AppTheme.secondaryStyle),
          ),
        ],
      ),
    );
  }

  String _todayLine(int day) {
    if (day <= 30) return 'One clean action. Build the baseline.';
    if (day <= 90) return 'Keep the promise visible today.';
    if (day <= 150) return 'Turn pressure into proof.';
    return 'Finish like this is who you are.';
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryText,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.check,
              color: AppTheme.background,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Task complete. Leave the reflection while the day is still fresh.',
              style: AppTheme.secondaryStyle.copyWith(
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
