import 'day_log_model.dart';

class GamificationModel {
  const GamificationModel({
    required this.xp,
    required this.level,
    required this.levelProgress,
    required this.todayScore,
    required this.badges,
    required this.recentDays,
  });

  final int xp;
  final int level;
  final double levelProgress;
  final int todayScore;
  final List<BadgeModel> badges;
  final List<DayPulse> recentDays;

  int get xpIntoLevel => xp % 300;
  int get xpForNextLevel => 300;
}

class BadgeModel {
  const BadgeModel({
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  final String title;
  final String subtitle;
  final bool unlocked;
}

class DayPulse {
  const DayPulse({
    required this.date,
    required this.completed,
    required this.isToday,
  });

  final DateTime date;
  final bool completed;
  final bool isToday;
}

GamificationModel buildGamification(List<DayLogModel> logs) {
  final completed = logs.where((log) => log.taskDone).length;
  final checkins = logs.where((log) => log.checkInAnswer != null).length;
  final reflections = logs
      .where((log) => (log.reflection ?? '').trim().isNotEmpty)
      .length;
  final streak = _streakFor(logs);
  final xp = completed * 100 + checkins * 20 + reflections * 30 + streak * 10;
  final level = (xp ~/ 300) + 1;
  final today = _todayLog(logs);
  final todayScore = _scoreFor(today);

  return GamificationModel(
    xp: xp,
    level: level,
    levelProgress: (xp % 300) / 300,
    todayScore: todayScore,
    recentDays: _recentDays(logs),
    badges: [
      BadgeModel(
        title: 'ПЕРВАЯ ПОБЕДА',
        subtitle: 'Выполни одну задачу',
        unlocked: completed >= 1,
      ),
      BadgeModel(
        title: 'СЕРИЯ 3 ДНЯ',
        subtitle: 'Удержи серию 3 дня',
        unlocked: streak >= 3,
      ),
      BadgeModel(
        title: '10 ЗАДАЧ',
        subtitle: 'Накопи десять побед',
        unlocked: completed >= 10,
      ),
      BadgeModel(
        title: 'ЧЕСТНЫЙ ЛОГ',
        subtitle: 'Напиши пять рефлексий',
        unlocked: reflections >= 5,
      ),
    ],
  );
}

DayLogModel? _todayLog(List<DayLogModel> logs) {
  final key = DayLogModel.keyForDate(DateTime.now());
  return logs.where((log) => log.key == key).firstOrNull;
}

int _scoreFor(DayLogModel? log) {
  if (log == null) return 0;
  var score = 0;
  if (log.taskDone) score += 60;
  if (log.checkInAnswer != null) score += 20;
  if ((log.reflection ?? '').trim().isNotEmpty) score += 20;
  return score;
}

List<DayPulse> _recentDays(List<DayLogModel> logs) {
  final today = DateTime.now();
  return List.generate(7, (index) {
    final date = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: 6 - index));
    final key = DayLogModel.keyForDate(date);
    final log = logs.where((item) => item.key == key).firstOrNull;
    return DayPulse(
      date: date,
      completed: log?.taskDone == true,
      isToday: index == 6,
    );
  });
}

int _streakFor(List<DayLogModel> logs) {
  var count = 0;
  var cursor = DateTime.now();
  while (true) {
    final key = DayLogModel.keyForDate(cursor);
    final match = logs.where((log) => log.key == key).firstOrNull;
    if (match == null || !match.taskDone) break;
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}
