import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({
    super.key,
    required this.day,
    required this.daysLeft,
    required this.progress,
  });

  final int day;
  final int daysLeft;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _Metric(label: 'DAY', value: '$day'),
              ),
              _Metric(label: 'LEFT', value: '$daysLeft', alignEnd: true),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppTheme.background,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.displayStyle),
      ],
    );
  }
}
