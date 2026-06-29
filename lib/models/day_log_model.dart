class DayLogModel {
  const DayLogModel({
    required this.date,
    required this.task,
    this.taskDone = false,
    this.checkInAnswer,
    this.reflection,
  });

  final DateTime date;
  final String task;
  final bool taskDone;
  final bool? checkInAnswer;
  final String? reflection;

  String get key => keyForDate(date);

  DayLogModel copyWith({
    DateTime? date,
    String? task,
    bool? taskDone,
    bool? checkInAnswer,
    String? reflection,
  }) {
    return DayLogModel(
      date: date ?? this.date,
      task: task ?? this.task,
      taskDone: taskDone ?? this.taskDone,
      checkInAnswer: checkInAnswer ?? this.checkInAnswer,
      reflection: reflection ?? this.reflection,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'task': task,
      'taskDone': taskDone,
      'checkInAnswer': checkInAnswer,
      'reflection': reflection,
    };
  }

  factory DayLogModel.fromMap(Map<dynamic, dynamic> map) {
    return DayLogModel(
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      task: map['task'] as String? ?? '',
      taskDone: map['taskDone'] as bool? ?? false,
      checkInAnswer: map['checkInAnswer'] as bool?,
      reflection: map['reflection'] as String?,
    );
  }

  static String keyForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String();
  }
}
