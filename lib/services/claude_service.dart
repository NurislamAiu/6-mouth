import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/goal_model.dart';

class ClaudeService {
  ClaudeService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
  static const _model = 'claude-sonnet-4-6';
  static final _endpoint = Uri.parse('https://api.anthropic.com/v1/messages');

  final http.Client _client;

  Future<String> rephraseGoal(String input) async {
    if (input.trim().isEmpty) return input;
    return _ask(
      'Rewrite this as one clear, powerful personal 6-month goal. '
      'Use first person, keep it under 22 words, and return only the goal.\n\n'
      'Goal: $input',
      fallback: input.trim(),
    );
  }

  Future<String> generateDailyTask({
    required String goal,
    required GoalCategory category,
    required int monthNumber,
  }) async {
    final topics = _loadTopics();
    final topicsLine = topics.isNotEmpty
        ? 'User motivation topics: ${topics.join(', ')}\n'
        : '';
    final fallback = _fallbackTask(category, monthNumber);
    return _ask(
      'Create one specific task for today for a 6-month transformation plan.\n'
      'Category: ${category.label}\n'
      'Current month: $monthNumber of 6\n'
      'Goal: $goal\n'
      '${topicsLine}'
      '\nReturn only one actionable sentence under 18 words.',
      fallback: fallback,
    );
  }

  List<String> _loadTopics() {
    final raw = Hive.box('app').get('motivationTopics');
    if (raw is List) return raw.cast<String>();
    return [];
  }

  Future<String> generateMonthlySummary({
    required String goal,
    required int monthNumber,
    required int completedTasks,
    required int streak,
    required List<String> reflections,
  }) async {
    return _ask(
      'Write a three-sentence monthly reflection insight for this user.\n'
      'Goal: $goal\n'
      'Month: $monthNumber\n'
      'Completed tasks: $completedTasks\n'
      'Current streak: $streak\n'
      'Reflections: ${reflections.join(' | ')}\n\n'
      'Be direct, calm, and motivating. Return exactly three sentences.',
      fallback:
          'Ты строишь доказательства через повторяющиеся действия. Этот месяц показал, где уже формируется постоянство и где ещё есть трение. Держи следующий шаг достаточно маленьким, чтобы завершить его сегодня.',
    );
  }

  Future<String> _ask(String prompt, {required String fallback}) async {
    if (_apiKey.isEmpty) return fallback;

    final response = await _client.post(
      _endpoint,
      headers: {
        'content-type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 220,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return fallback;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>? ?? const [];
    if (content.isEmpty) return fallback;
    final first = content.first as Map<String, dynamic>;
    final text = first['text'] as String? ?? fallback;
    return text.trim().isEmpty ? fallback : text.trim();
  }

  String _fallbackTask(GoalCategory category, int monthNumber) {
    return switch (category) {
      GoalCategory.body =>
        monthNumber <= 2
            ? 'Выполни одну сфокусированную тренировку 30 минут.'
            : 'Улучши один показатель тренировки сверх прошлой недели.',
      GoalCategory.money =>
        monthNumber <= 2
            ? 'Проверь расходы и убери одну ненужную трату.'
            : 'Сделай одно конкретное действие для роста дохода или сбережений.',
      GoalCategory.skill =>
        monthNumber <= 2
            ? 'Практикуй свой навык 45 минут без перерывов.'
            : 'Создай одно маленькое доказательство улучшения навыка.',
      GoalCategory.mindset =>
        monthNumber <= 2
            ? 'Запиши одно ограничивающее убеждение и замени его на более точное.'
            : 'Сделай одно некомфортное действие, которое откладывал.',
    };
  }
}
