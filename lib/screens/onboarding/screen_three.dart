import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/goal_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import 'onboarding_flow.dart';
import 'onboarding_layout.dart';

class ScreenThree extends ConsumerStatefulWidget {
  const ScreenThree({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<ScreenThree> createState() => _ScreenThreeState();
}

class _ScreenThreeState extends ConsumerState<ScreenThree> {
  late final TextEditingController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(onboardingStateProvider).goal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rewrite() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    final rewritten = await ref.read(claudeServiceProvider).rephraseGoal(text);
    _controller.text = rewritten;
    ref.read(onboardingStateProvider.notifier).state = ref
        .read(onboardingStateProvider)
        .copyWith(goal: rewritten);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(onboardingStateProvider).goal;
    return OnboardingLayout(
      step: 3,
      title: 'Запиши цель чётко.',
      subtitle: 'Сделай её конкретной, чтобы завтра было направление.',
      action: AppButton(
        label: 'Продолжить',
        onPressed: goal.trim().isEmpty ? null : widget.onNext,
        filled: goal.trim().isNotEmpty,
      ),
      child: Column(
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _controller,
              style: AppTheme.bodyStyle,
              minLines: 4,
              maxLines: 6,
              onChanged: (value) {
                ref.read(onboardingStateProvider.notifier).state = ref
                    .read(onboardingStateProvider)
                    .copyWith(goal: value);
              },
              decoration: const InputDecoration(
                hintText: 'ЧЕРЕЗ 6 МЕСЯЦЕВ Я...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Помоги написать',
            onPressed: goal.trim().isEmpty ? null : _rewrite,
            loading: _loading,
          ),
        ],
      ),
    );
  }
}
