import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/log_provider.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class ReflectCard extends ConsumerStatefulWidget {
  const ReflectCard({super.key});

  @override
  ConsumerState<ReflectCard> createState() => _ReflectCardState();
}

class _ReflectCardState extends ConsumerState<ReflectCard> {
  late final TextEditingController _controller;
  String? _lastSavedReflection;

  @override
  void initState() {
    super.initState();
    final log = ref.read(todayLogSyncProvider);
    _controller = TextEditingController(text: log?.reflection);
    _lastSavedReflection = log?.reflection;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(todayLogSyncProvider);
    if (log == null) return const SizedBox.shrink();
    // Sync text field only when an external change arrives (e.g. app restart).
    if (log.reflection != _lastSavedReflection &&
        log.reflection != _controller.text) {
      _controller.text = log.reflection ?? '';
      _lastSavedReflection = log.reflection;
    }
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
                  'РЕФЛЕКСИЯ',
                  style: AppTheme.labelStyle.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
              Text(
                'СОХРАНЕНО',
                style: AppTheme.labelStyle.copyWith(
                  color: AppTheme.secondaryText,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Что сегодня открыло в тебе?',
            style: AppTheme.bodyStyle.copyWith(fontSize: 19, height: 1.25),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            style: AppTheme.bodyStyle,
            onChanged: (value) {
              _lastSavedReflection = value;
              ref
                  .read(logControllerProvider.notifier)
                  .upsert(log.copyWith(reflection: value));
            },
            decoration: const InputDecoration(
              hintText: 'НАПИШИ ОДНУ ЧЕСТНУЮ СТРОКУ',
            ),
          ),
        ],
      ),
    );
  }
}
