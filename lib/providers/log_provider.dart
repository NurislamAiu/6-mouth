import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/day_log_model.dart';
import 'goal_provider.dart';

final logControllerProvider =
    StateNotifierProvider<LogController, List<DayLogModel>>((ref) {
      return LogController(Hive.box('logs'));
    });

final todayLogProvider = FutureProvider<DayLogModel>((ref) async {
  final goal = ref.watch(goalControllerProvider);
  final logs = ref.watch(logControllerProvider);
  final controller = ref.read(logControllerProvider.notifier);
  final service = ref.read(claudeServiceProvider);
  final todayKey = DayLogModel.keyForDate(DateTime.now());
  final existing = logs.where((log) => log.key == todayKey).firstOrNull;

  if (existing != null) return existing;
  if (goal == null) {
    return DayLogModel(date: DateTime.now(), task: 'Define your goal first.');
  }

  final task = await service.generateDailyTask(
    goal: goal.goal,
    category: goal.category,
    monthNumber: currentMonthFor(goal),
  );
  return controller.upsert(DayLogModel(date: DateTime.now(), task: task));
});

class LogController extends StateNotifier<List<DayLogModel>> {
  LogController(this._box) : super(_load(_box));

  final Box _box;

  DayLogModel upsert(DayLogModel log) {
    final next = [...state];
    final index = next.indexWhere((item) => item.key == log.key);
    if (index == -1) {
      next.add(log);
    } else {
      next[index] = log;
    }
    next.sort((a, b) => a.date.compareTo(b.date));
    state = next;
    _box.put(log.key, log.toMap());
    return log;
  }

  int get completedTasks => state.where((log) => log.taskDone).length;

  int get streak {
    var count = 0;
    var cursor = DateTime.now();
    while (true) {
      final key = DayLogModel.keyForDate(cursor);
      final match = state.where((log) => log.key == key).firstOrNull;
      if (match == null || !match.taskDone) break;
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  static List<DayLogModel> _load(Box box) {
    return box.values.whereType<Map>().map(DayLogModel.fromMap).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
