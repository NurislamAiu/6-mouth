import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/goal_model.dart';
import '../services/claude_service.dart';

final claudeServiceProvider = Provider<ClaudeService>((ref) {
  return ClaudeService();
});

final goalControllerProvider =
    StateNotifierProvider<GoalController, GoalModel?>((ref) {
      return GoalController(Hive.box('app'));
    });

class GoalController extends StateNotifier<GoalModel?> {
  GoalController(this._box) : super(_load(_box));

  static const _key = 'goal';
  final Box _box;

  bool get hasCompletedOnboarding => _box.get('onboardingComplete') == true;

  Future<void> saveGoal(GoalModel goal) async {
    state = goal;
    await _box.put(_key, goal.toMap());
    await _box.put('onboardingComplete', true);
  }

  Future<void> updateGoal(GoalModel goal) async {
    state = goal;
    await _box.put(_key, goal.toMap());
  }

  Future<void> updateMonthlySummary(String summary) async {
    final current = state;
    if (current == null) return;
    await updateGoal(current.copyWith(lastMonthlySummary: summary));
  }

  static GoalModel? _load(Box box) {
    final raw = box.get(_key);
    if (raw is Map) return GoalModel.fromMap(raw);
    return null;
  }
}

final hasOnboardedProvider = Provider<bool>((ref) {
  ref.watch(goalControllerProvider);
  return Hive.box('app').get('onboardingComplete') == true;
});


int currentDayFor(GoalModel goal) {
  final today = DateTime.now();
  final start = DateTime(
    goal.startDate.year,
    goal.startDate.month,
    goal.startDate.day,
  );
  final now = DateTime(today.year, today.month, today.day);
  return now.difference(start).inDays + 1;
}

int currentMonthFor(GoalModel goal) {
  final day = currentDayFor(goal).clamp(1, 180);
  return ((day - 1) ~/ 30) + 1;
}
