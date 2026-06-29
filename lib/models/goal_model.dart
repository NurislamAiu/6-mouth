enum GoalCategory {
  body,
  money,
  skill,
  mindset;

  String get label => name.toUpperCase();
}

class GoalModel {
  const GoalModel({
    required this.category,
    required this.goal,
    required this.why,
    required this.startDate,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.lastMonthlySummary,
  });

  final GoalCategory category;
  final String goal;
  final String why;
  final DateTime startDate;
  final String? beforePhotoPath;
  final String? afterPhotoPath;
  final String? lastMonthlySummary;

  GoalModel copyWith({
    GoalCategory? category,
    String? goal,
    String? why,
    DateTime? startDate,
    String? beforePhotoPath,
    String? afterPhotoPath,
    String? lastMonthlySummary,
  }) {
    return GoalModel(
      category: category ?? this.category,
      goal: goal ?? this.goal,
      why: why ?? this.why,
      startDate: startDate ?? this.startDate,
      beforePhotoPath: beforePhotoPath ?? this.beforePhotoPath,
      afterPhotoPath: afterPhotoPath ?? this.afterPhotoPath,
      lastMonthlySummary: lastMonthlySummary ?? this.lastMonthlySummary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'goal': goal,
      'why': why,
      'startDate': startDate.toIso8601String(),
      'beforePhotoPath': beforePhotoPath,
      'afterPhotoPath': afterPhotoPath,
      'lastMonthlySummary': lastMonthlySummary,
    };
  }

  factory GoalModel.fromMap(Map<dynamic, dynamic> map) {
    return GoalModel(
      category: GoalCategory.values.firstWhere(
        (item) => item.name == map['category'],
        orElse: () => GoalCategory.body,
      ),
      goal: map['goal'] as String? ?? '',
      why: map['why'] as String? ?? '',
      startDate:
          DateTime.tryParse(map['startDate'] as String? ?? '') ??
          DateTime.now(),
      beforePhotoPath: map['beforePhotoPath'] as String?,
      afterPhotoPath: map['afterPhotoPath'] as String?,
      lastMonthlySummary: map['lastMonthlySummary'] as String?,
    );
  }
}
