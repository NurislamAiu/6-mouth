import 'dart:convert';

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
    final fallback = _fallbackTask(category, monthNumber);
    return _ask(
      'Create one specific task for today for a 6-month transformation plan.\n'
      'Category: ${category.label}\n'
      'Current month: $monthNumber of 6\n'
      'Goal: $goal\n\n'
      'Return only one actionable sentence under 18 words.',
      fallback: fallback,
    );
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
          'You are building proof through repeated action. This month showed where consistency is already forming and where friction still needs attention. Keep the next step small enough to finish today.',
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
            ? 'Complete one focused 30-minute workout.'
            : 'Push one workout metric slightly beyond last week.',
      GoalCategory.money =>
        monthNumber <= 2
            ? 'Review your spending and remove one unnecessary cost.'
            : 'Take one concrete action that increases income or savings.',
      GoalCategory.skill =>
        monthNumber <= 2
            ? 'Practice your core skill for 45 uninterrupted minutes.'
            : 'Create one small proof of your improving skill.',
      GoalCategory.mindset =>
        monthNumber <= 2
            ? 'Write down one limiting belief and a truer replacement.'
            : 'Do one uncomfortable action you have been avoiding.',
    };
  }
}
