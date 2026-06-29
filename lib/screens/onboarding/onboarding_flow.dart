import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../theme/app_motion.dart';
import '../paywall_screen.dart';
import 'onboarding_state.dart';
import 'screen_one.dart';
import 'screen_two.dart';
import 'screen_three.dart';
import 'screen_four.dart';

final onboardingStateProvider = StateProvider<OnboardingState>(
  (ref) => const OnboardingState(),
);

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == 3) {
      final state = ref.read(onboardingStateProvider);
      final category = state.category ?? GoalCategory.body;
      ref
          .read(goalControllerProvider.notifier)
          .saveGoal(
            GoalModel(
              category: category,
              goal: state.goal.trim(),
              why: state.why.trim(),
              startDate: DateTime.now(),
            ),
          );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    _controller.nextPage(duration: AppMotion.slow, curve: AppMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) => setState(() => _index = value),
        children: [
          ScreenOne(onNext: _next),
          ScreenTwo(onNext: _next),
          ScreenThree(onNext: _next),
          ScreenFour(onNext: _next),
        ],
      ),
    );
  }
}
