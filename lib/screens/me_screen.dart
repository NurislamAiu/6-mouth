import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/goal_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/log_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_card.dart';
import '../widgets/gamification_widgets.dart';
import '../widgets/stat_box.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalControllerProvider);
    final gamification = ref.watch(gamificationProvider);
    final logController = ref.read(logControllerProvider.notifier);
    final day = goal == null ? 1 : currentDayFor(goal).clamp(1, 180);
    final daysLeft = (180 - day).clamp(0, 180);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          AppHeader(
            title: 'Me',
            trailing: 'DAY $day',
            subtitle: goal?.category.label ?? 'Your transformation',
          ),
          const SizedBox(height: 18),
          LevelCard(gamification: gamification),
          const SizedBox(height: 14),
          StreakPulseCard(days: gamification.recentDays),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MY GOAL', style: AppTheme.labelStyle),
                const SizedBox(height: 16),
                Text(goal?.goal ?? '', style: AppTheme.bodyStyle),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              StatBox(label: 'Days in', value: '$day'),
              StatBox(label: 'Days left', value: '$daysLeft'),
              StatBox(label: 'Streak', value: '${logController.streak}'),
              StatBox(
                label: 'Tasks done',
                value: '${logController.completedTasks}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          BadgeShelf(badges: gamification.badges),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PhotoBox(label: 'BEFORE', path: goal?.beforePhotoPath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoBox(label: 'AFTER', path: goal?.afterPhotoPath),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _MonthlySummaryCard(),
        ],
      ),
    );
  }
}

class _PhotoBox extends ConsumerWidget {
  const _PhotoBox({required this.label, required this.path});

  final String label;
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalControllerProvider);
    return GestureDetector(
      onTap: goal == null
          ? null
          : () async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 88,
              );
              if (picked == null) return;
              final updated = label == 'BEFORE'
                  ? goal.copyWith(beforePhotoPath: picked.path)
                  : goal.copyWith(afterPhotoPath: picked.path);
              await ref
                  .read(goalControllerProvider.notifier)
                  .updateGoal(updated);
            },
      child: AppCard(
        padding: EdgeInsets.zero,
        child: AspectRatio(
          aspectRatio: 0.78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: path == null
                ? Center(child: Text(label, style: AppTheme.labelStyle))
                : Image.file(File(path!), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _MonthlySummaryCard extends ConsumerStatefulWidget {
  const _MonthlySummaryCard();

  @override
  ConsumerState<_MonthlySummaryCard> createState() =>
      _MonthlySummaryCardState();
}

class _MonthlySummaryCardState extends ConsumerState<_MonthlySummaryCard> {
  bool _loading = false;

  Future<void> _generate() async {
    final goal = ref.read(goalControllerProvider);
    if (goal == null) return;
    setState(() => _loading = true);
    final logController = ref.read(logControllerProvider.notifier);
    final logs = ref.read(logControllerProvider);
    final reflections = logs
        .map((log) => log.reflection)
        .whereType<String>()
        .where((reflection) => reflection.trim().isNotEmpty)
        .toList();
    final summary = await ref
        .read(claudeServiceProvider)
        .generateMonthlySummary(
          goal: goal.goal,
          monthNumber: currentMonthFor(goal),
          completedTasks: logController.completedTasks,
          streak: logController.streak,
          reflections: reflections,
        );
    await ref
        .read(goalControllerProvider.notifier)
        .updateMonthlySummary(summary);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(goalControllerProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI MONTHLY SUMMARY', style: AppTheme.labelStyle),
          const SizedBox(height: 16),
          Text(
            goal?.lastMonthlySummary ??
                'Your first monthly insight will appear after you build enough reflection data.',
            style: AppTheme.secondaryStyle.copyWith(
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _loading ? null : _generate,
            child: AnimatedOpacity(
              duration: AppMotion.normal,
              curve: AppMotion.curve,
              opacity: _loading ? 0.4 : 1,
              child: Text(
                _loading ? 'GENERATING' : 'GENERATE SUMMARY',
                style: AppTheme.labelStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
