import 'package:flutter_test/flutter_test.dart';
import 'package:mouth6/models/day_log_model.dart';
import 'package:mouth6/models/gamification_model.dart';
import 'package:mouth6/models/goal_model.dart';

void main() {
  test('goal model round trips through Hive-friendly maps', () {
    final startDate = DateTime(2026, 6, 29);
    final goal = GoalModel(
      category: GoalCategory.skill,
      goal: 'I master one valuable skill.',
      why: 'It changes my future.',
      startDate: startDate,
      beforePhotoPath: '/before.jpg',
      afterPhotoPath: '/after.jpg',
      lastMonthlySummary: 'Momentum is building.',
    );

    final restored = GoalModel.fromMap(goal.toMap());

    expect(restored.category, GoalCategory.skill);
    expect(restored.goal, goal.goal);
    expect(restored.why, goal.why);
    expect(restored.startDate, startDate);
    expect(restored.beforePhotoPath, '/before.jpg');
    expect(restored.afterPhotoPath, '/after.jpg');
    expect(restored.lastMonthlySummary, 'Momentum is building.');
  });

  test('day log key normalizes to date only', () {
    final morning = DateTime(2026, 6, 29, 8);
    final night = DateTime(2026, 6, 29, 23, 59);

    expect(DayLogModel.keyForDate(morning), DayLogModel.keyForDate(night));
  });

  test('gamification score rewards task checkin and reflection', () {
    final today = DateTime.now();
    final gamification = buildGamification([
      DayLogModel(
        date: today,
        task: 'Finish the task.',
        taskDone: true,
        checkInAnswer: true,
        reflection: 'I showed up.',
      ),
    ]);

    expect(gamification.todayScore, 100);
    expect(gamification.xp, greaterThanOrEqualTo(150));
    expect(gamification.badges.first.unlocked, isTrue);
  });
}
