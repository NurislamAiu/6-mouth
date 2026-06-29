import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/goal_model.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'onboarding_flow.dart';
import 'onboarding_layout.dart';

class ScreenTwo extends ConsumerWidget {
  const ScreenTwo({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    return OnboardingLayout(
      step: 2,
      title: 'Что ты трансформируешь первым?',
      subtitle: 'Выбери область, где шесть месяцев изменят больше всего.',
      action: AppButton(
        label: 'Продолжить',
        onPressed: state.category == null ? null : onNext,
        filled: state.category != null,
      ),
      child: Column(
        children: GoalCategory.values.map((category) {
          final selected = state.category == category;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                ref.read(onboardingStateProvider.notifier).state = state
                    .copyWith(category: category);
              },
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.curve,
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryText
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: AppTheme.background,
                              )
                            : Text(
                                '${GoalCategory.values.indexOf(category) + 1}',
                                style: AppTheme.labelStyle.copyWith(
                                  letterSpacing: 0,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category.label, style: AppTheme.labelStyle),
                            const SizedBox(height: 6),
                            Text(
                              _descriptionFor(category),
                              style: AppTheme.secondaryStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _descriptionFor(GoalCategory category) {
    return switch (category) {
      GoalCategory.body => 'Сила, энергия, дисциплина.',
      GoalCategory.money => 'Доход, траты, контроль.',
      GoalCategory.skill => 'Практика, результат, мастерство.',
      GoalCategory.mindset => 'Уверенность, фокус, идентичность.',
    };
  }
}
