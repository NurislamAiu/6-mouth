import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gamification_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/log_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(goalControllerProvider);
    final day = goal == null ? 1 : currentDayFor(goal).clamp(1, 180);
    final asyncLog = ref.watch(todayLogProvider);
    final log = ref.watch(todayLogSyncProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          _TopBar(day: day, log: log),
          const SizedBox(height: 28),
          _Subtitle(goal: goal, day: day),
          const SizedBox(height: 36),
          if (log != null) ...[
            _TaskSection(log: log),
            const SizedBox(height: 36),
            _Divider(),
            const SizedBox(height: 36),
            _CheckinSection(log: log),
            const SizedBox(height: 36),
            _Divider(),
            const SizedBox(height: 36),
            const _ReflectSection(),
            const SizedBox(height: 36),
            _XpFooter(log: log),
          ] else if (asyncLog.isLoading)
            const _LoadingState()
          else
            Text('Не удалось загрузить данные.', style: AppTheme.secondaryStyle),
        ],
      ),
    );
  }
}

// ─── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.day, required this.log});

  final int day;
  final dynamic log;

  @override
  Widget build(BuildContext context) {
    final done = log?.taskDone == true;
    final checkin = log?.checkInAnswer != null;
    final reflected =
        (log?.reflection as String?)?.trim().isNotEmpty == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.primaryText,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'ДЕНЬ $day',
            style: AppTheme.labelStyle.copyWith(
              color: AppTheme.background,
              letterSpacing: 2,
            ),
          ),
        ),
        const Spacer(),
        _StepDots(done: done, checkin: checkin, reflected: reflected),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.done,
    required this.checkin,
    required this.reflected,
  });

  final bool done;
  final bool checkin;
  final bool reflected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(filled: done),
        const SizedBox(width: 6),
        _Dot(filled: checkin),
        const SizedBox(width: 6),
        _Dot(filled: reflected),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.curve,
      width: filled ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: filled ? AppTheme.primaryText : AppTheme.secondaryText.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

// ─── Subtitle ───────────────────────────────────────────────────────────────

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.goal, required this.day});

  final dynamic goal;
  final int day;

  @override
  Widget build(BuildContext context) {
    final text = goal == null
        ? 'Сегодня всё начинается.'
        : _line(day);
    return Text(
      text,
      style: AppTheme.secondaryStyle.copyWith(fontSize: 15, height: 1.4),
    );
  }

  String _line(int day) {
    if (day <= 30) return 'Одно чистое действие. Строй фундамент.';
    if (day <= 90) return 'Держи обещание на виду сегодня.';
    if (day <= 150) return 'Превращай давление в доказательство.';
    return 'Финишируй как тот, кем ты стал.';
  }
}

// ─── Task section ───────────────────────────────────────────────────────────

class _TaskSection extends ConsumerWidget {
  const _TaskSection({required this.log});

  final dynamic log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = log.taskDone as bool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ЗАДАЧА',
              style: AppTheme.labelStyle.copyWith(
                color: AppTheme.secondaryText,
                letterSpacing: 3,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.curve,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: done ? AppTheme.primaryText : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: done ? AppTheme.primaryText : AppTheme.border,
                ),
              ),
              child: Text(
                done ? 'ГОТОВО' : '+60 XP',
                style: AppTheme.labelStyle.copyWith(
                  color: done ? AppTheme.background : AppTheme.secondaryText,
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          log.task as String,
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.5,
            color: done
                ? AppTheme.secondaryText
                : AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 28),
        _TaskButton(done: done, log: log),
      ],
    );
  }
}

class _TaskButton extends ConsumerWidget {
  const _TaskButton({required this.done, required this.log});

  final bool done;
  final dynamic log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref
            .read(logControllerProvider.notifier)
            .upsert(log.copyWith(taskDone: !done));
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done ? Colors.transparent : AppTheme.primaryText,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done ? AppTheme.border : AppTheme.primaryText,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.fast,
              child: done
                  ? Icon(
                      Icons.check,
                      key: const ValueKey('check'),
                      size: 16,
                      color: AppTheme.secondaryText,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            if (done) const SizedBox(width: 8),
            Text(
              done ? 'Выполнено' : 'Выполнить задачу',
              style: AppTheme.labelStyle.copyWith(
                color: done ? AppTheme.secondaryText : AppTheme.background,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Check-in section ───────────────────────────────────────────────────────

class _CheckinSection extends ConsumerWidget {
  const _CheckinSection({required this.log});

  final dynamic log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ПРОВЕРКА',
          style: AppTheme.labelStyle.copyWith(
            color: AppTheme.secondaryText,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Твои действия совпадают с тем, кем ты становишься?',
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _ChoiceBtn(log: log, value: true, label: 'ДА')),
            const SizedBox(width: 12),
            Expanded(child: _ChoiceBtn(log: log, value: false, label: 'НЕТ')),
          ],
        ),
      ],
    );
  }
}

class _ChoiceBtn extends ConsumerWidget {
  const _ChoiceBtn({
    required this.log,
    required this.value,
    required this.label,
  });

  final dynamic log;
  final bool value;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = log.checkInAnswer == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref
            .read(logControllerProvider.notifier)
            .upsert(log.copyWith(checkInAnswer: value));
      },
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryText : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primaryText : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelStyle.copyWith(
            color: selected ? AppTheme.background : AppTheme.secondaryText,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}

// ─── Reflect section ────────────────────────────────────────────────────────

class _ReflectSection extends ConsumerStatefulWidget {
  const _ReflectSection();

  @override
  ConsumerState<_ReflectSection> createState() => _ReflectSectionState();
}

class _ReflectSectionState extends ConsumerState<_ReflectSection> {
  late final TextEditingController _ctrl;
  String? _lastSaved;

  @override
  void initState() {
    super.initState();
    final log = ref.read(todayLogSyncProvider);
    _ctrl = TextEditingController(text: log?.reflection);
    _lastSaved = log?.reflection;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(todayLogSyncProvider);
    if (log == null) return const SizedBox.shrink();

    if (log.reflection != _lastSaved && log.reflection != _ctrl.text) {
      _ctrl.text = log.reflection ?? '';
      _lastSaved = log.reflection;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'РЕФЛЕКСИЯ',
              style: AppTheme.labelStyle.copyWith(
                color: AppTheme.secondaryText,
                letterSpacing: 3,
              ),
            ),
            const Spacer(),
            Text(
              'СОХРАНЕНО',
              style: AppTheme.labelStyle.copyWith(
                color: AppTheme.border,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Что сегодня открыло в тебе?',
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ctrl,
          minLines: 4,
          maxLines: 10,
          style: AppTheme.bodyStyle.copyWith(height: 1.6),
          onChanged: (val) {
            _lastSaved = val;
            ref
                .read(logControllerProvider.notifier)
                .upsert(log.copyWith(reflection: val));
          },
          decoration: InputDecoration(
            hintText: 'Напиши одну честную строку...',
            hintStyle: AppTheme.secondaryStyle,
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryText),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── XP footer ──────────────────────────────────────────────────────────────

class _XpFooter extends ConsumerWidget {
  const _XpFooter({required this.log});

  final dynamic log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final xp = gamification.todayScore;
    if (xp == 0) return const SizedBox.shrink();
    return Center(
      child: Text(
        '+$xp XP заработано сегодня',
        style: AppTheme.secondaryStyle.copyWith(fontSize: 13),
      ),
    );
  }
}

// ─── Divider ────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppTheme.border);
  }
}

// ─── Loading ────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryText,
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}
