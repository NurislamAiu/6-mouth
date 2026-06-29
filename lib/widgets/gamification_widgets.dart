import 'package:flutter/material.dart';

import '../models/gamification_model.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.gamification});

  final GamificationModel gamification;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEVEL', style: AppTheme.labelStyle),
                    const SizedBox(height: 10),
                    Text(
                      '${gamification.level}',
                      style: AppTheme.displayStyle.copyWith(fontSize: 56),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('XP', style: AppTheme.labelStyle),
                  const SizedBox(height: 10),
                  Text(
                    '${gamification.xp}',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: gamification.levelProgress,
              minHeight: 5,
              backgroundColor: AppTheme.background,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${gamification.xpIntoLevel}/${gamification.xpForNextLevel} XP TO NEXT LEVEL',
            style: AppTheme.labelStyle.copyWith(
              color: AppTheme.secondaryText,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class CompactGameStrip extends StatelessWidget {
  const CompactGameStrip({super.key, required this.gamification});

  final GamificationModel gamification;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _CompactMetric(label: 'LVL', value: '${gamification.level}'),
          ),
          Container(width: 1, height: 34, color: AppTheme.border),
          Expanded(
            child: _CompactMetric(
              label: 'SCORE',
              value: '${gamification.todayScore}',
            ),
          ),
          Container(width: 1, height: 34, color: AppTheme.border),
          Expanded(
            child: _CompactMetric(label: 'XP', value: '${gamification.xp}'),
          ),
        ],
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
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

class DailyScoreCard extends StatelessWidget {
  const DailyScoreCard({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 5,
                  backgroundColor: AppTheme.background,
                  color: AppTheme.primaryText,
                ),
                Center(
                  child: Text(
                    '$score',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAILY SCORE', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                Text(
                  _messageFor(score),
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

  String _messageFor(int score) {
    if (score == 100) return 'Perfect day. XP locked in.';
    if (score >= 60) return 'Main win secured. Finish the check-in.';
    if (score >= 20) return 'You started. Complete the task.';
    return 'Score the day with one action.';
  }
}

class StreakPulseCard extends StatelessWidget {
  const StreakPulseCard({super.key, required this.days});

  final List<DayPulse> days;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7 DAY PULSE', style: AppTheme.labelStyle),
          const SizedBox(height: 18),
          Row(
            children: days.map((day) {
              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.normal,
                      curve: AppMotion.curve,
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: day.completed
                            ? AppTheme.primaryText
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: day.isToday
                              ? AppTheme.primaryText
                              : AppTheme.border,
                        ),
                      ),
                      child: day.completed
                          ? const Icon(
                              Icons.check,
                              color: AppTheme.background,
                              size: 17,
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day.isToday ? 'NOW' : _weekday(day.date),
                      style: AppTheme.labelStyle.copyWith(
                        fontSize: 9,
                        color: day.isToday
                            ? AppTheme.primaryText
                            : AppTheme.secondaryText,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime date) {
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return names[date.weekday - 1];
  }
}

class BadgeShelf extends StatelessWidget {
  const BadgeShelf({super.key, required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACHIEVEMENTS', style: AppTheme.labelStyle),
          const SizedBox(height: 16),
          ...badges.map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedOpacity(
                duration: AppMotion.normal,
                curve: AppMotion.curve,
                opacity: badge.unlocked ? 1 : 0.28,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badge.unlocked
                            ? AppTheme.primaryText
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Icon(
                        badge.unlocked ? Icons.bolt : Icons.lock_outline,
                        size: 17,
                        color: badge.unlocked
                            ? AppTheme.background
                            : AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(badge.title, style: AppTheme.labelStyle),
                          const SizedBox(height: 4),
                          Text(badge.subtitle, style: AppTheme.secondaryStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
