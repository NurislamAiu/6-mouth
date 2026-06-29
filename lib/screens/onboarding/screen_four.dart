import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'onboarding_flow.dart';
import 'onboarding_layout.dart';

class ScreenFour extends ConsumerWidget {
  const ScreenFour({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final date = DateFormat('MMMM d, yyyy').format(DateTime.now());
    return OnboardingLayout(
      step: 4,
      title: 'Почему это важно?',
      subtitle:
          'Это предложение, к которому возвращаешься, когда дисциплина молчит.',
      action: AppButton(
        label: 'Начать',
        onPressed: state.why.trim().isEmpty ? null : onNext,
        filled: state.why.trim().isNotEmpty,
      ),
      child: Column(
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: TextField(
              minLines: 5,
              maxLines: 8,
              style: AppTheme.bodyStyle,
              onChanged: (value) {
                ref.read(onboardingStateProvider.notifier).state = state
                    .copyWith(why: value);
              },
              decoration: const InputDecoration(
                hintText: 'ПОТОМУ ЧТО...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('НАЧИНАЕТСЯ СЕГОДНЯ', style: AppTheme.labelStyle),
                      const SizedBox(height: 8),
                      Text(date, style: AppTheme.secondaryStyle),
                    ],
                  ),
                ),
                Text(
                  '180',
                  style: AppTheme.displayStyle.copyWith(fontSize: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
