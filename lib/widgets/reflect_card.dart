import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/day_log_model.dart';
import '../providers/log_provider.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class ReflectCard extends ConsumerStatefulWidget {
  const ReflectCard({super.key, required this.log});

  final DayLogModel log;

  @override
  ConsumerState<ReflectCard> createState() => _ReflectCardState();
}

class _ReflectCardState extends ConsumerState<ReflectCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.log.reflection);
  }

  @override
  void didUpdateWidget(covariant ReflectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.log.reflection != _controller.text) {
      _controller.text = widget.log.reflection ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('03', style: AppTheme.labelStyle),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'REFLECT',
                  style: AppTheme.labelStyle.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
              Text(
                'SAVED',
                style: AppTheme.labelStyle.copyWith(
                  color: AppTheme.secondaryText,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'What did today reveal about you?',
            style: AppTheme.bodyStyle.copyWith(fontSize: 19, height: 1.25),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            style: AppTheme.bodyStyle,
            onChanged: (value) {
              ref
                  .read(logControllerProvider.notifier)
                  .upsert(widget.log.copyWith(reflection: value));
              ref.invalidate(todayLogProvider);
            },
            decoration: const InputDecoration(
              hintText: 'WRITE ONE HONEST LINE',
            ),
          ),
        ],
      ),
    );
  }
}
