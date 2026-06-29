import '../../models/goal_model.dart';

class OnboardingState {
  const OnboardingState({this.category, this.goal = '', this.why = ''});

  final GoalCategory? category;
  final String goal;
  final String why;

  OnboardingState copyWith({
    GoalCategory? category,
    String? goal,
    String? why,
  }) {
    return OnboardingState(
      category: category ?? this.category,
      goal: goal ?? this.goal,
      why: why ?? this.why,
    );
  }
}
