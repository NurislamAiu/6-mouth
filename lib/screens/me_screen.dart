import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/log_provider.dart';
import '../services/auth_service.dart';
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
            title: 'Я',
            trailing: 'ДЕНЬ $day',
            subtitle: goal?.category.label ?? 'Твоя трансформация',
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
                Text('МОЯ ЦЕЛЬ', style: AppTheme.labelStyle),
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
              StatBox(label: 'Дней прошло', value: '$day'),
              StatBox(label: 'Дней осталось', value: '$daysLeft'),
              StatBox(label: 'Серия', value: '${logController.streak}'),
              StatBox(
                label: 'Задач выполнено',
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
                child: _PhotoBox(label: 'ДО', path: goal?.beforePhotoPath, isBefore: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoBox(label: 'ПОСЛЕ', path: goal?.afterPhotoPath, isBefore: false),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _MonthlySummaryCard(),
          const SizedBox(height: 14),
          const _AccountCard(),
        ],
      ),
    );
  }
}

class _PhotoBox extends ConsumerWidget {
  const _PhotoBox({required this.label, required this.path, required this.isBefore});

  final String label;
  final String? path;
  final bool isBefore;

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
              final updated = isBefore
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

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? user?.displayName ?? 'Аккаунт';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('АККАУНТ', style: AppTheme.labelStyle),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.person_outline, color: Colors.white38, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(email, style: AppTheme.bodyStyle.copyWith(fontSize: 13))),
          ]),
          const SizedBox(height: 20),
          _AccountButton(
            label: 'ВЫЙТИ',
            onTap: () async {
              await AuthService.instance.signOut();
            },
          ),
          const SizedBox(height: 10),
          _AccountButton(
            label: 'УДАЛИТЬ АККАУНТ',
            destructive: true,
            onTap: () => _confirmDelete(context, ref, user),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User? user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: Text('Удалить аккаунт?', style: AppTheme.bodyStyle),
        content: Text(
          'Все данные будут удалены без возможности восстановления.',
          style: AppTheme.secondaryStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ОТМЕНА', style: AppTheme.labelStyle.copyWith(fontSize: 11)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.instance.deleteAccount();
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login' && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Выйди и войди снова, затем удали аккаунт.'),
                      backgroundColor: Colors.black,
                    ),
                  );
                }
              }
            },
            child: Text('УДАЛИТЬ',
                style: AppTheme.labelStyle.copyWith(
                    fontSize: 11, color: Colors.red[300])),
          ),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  final String label;
  final bool destructive;
  final VoidCallback onTap;

  const _AccountButton({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: destructive ? Colors.red.withOpacity(0.4) : Colors.white12,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: AppTheme.labelStyle.copyWith(
            fontSize: 11,
            color: destructive ? Colors.red[300] : Colors.white,
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
          Text('AI ИТОГ МЕСЯЦА', style: AppTheme.labelStyle),
          const SizedBox(height: 16),
          Text(
            goal?.lastMonthlySummary ??
                'Первый анализ появится после накопления достаточно данных рефлексии.',
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
                _loading ? 'ГЕНЕРАЦИЯ...' : 'СОЗДАТЬ ИТОГ',
                style: AppTheme.labelStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
