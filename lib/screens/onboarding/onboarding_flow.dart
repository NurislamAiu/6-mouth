import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../services/claude_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

// ─── Internal State ───────────────────────────────────────────────────────────

class _OState {
  final GoalCategory? category;
  final List<String> topics;
  final String goal;
  final String why;

  const _OState({this.category, this.topics = const [], this.goal = '', this.why = ''});

  _OState copyWith({GoalCategory? category, List<String>? topics, String? goal, String? why}) =>
      _OState(
        category: category ?? this.category,
        topics: topics ?? this.topics,
        goal: goal ?? this.goal,
        why: why ?? this.why,
      );
}

final _oProvider = StateProvider<_OState>((_) => const _OState());

// ─── Flow ─────────────────────────────────────────────────────────────────────

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _ctrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < 3) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _ctrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _page--);
    }
  }

  Future<void> _finish() async {
    final s = ref.read(_oProvider);
    final category = s.category ?? GoalCategory.body;
    final goal = s.goal.trim().isEmpty ? 'Стать лучшей версией себя' : s.goal.trim();
    await Hive.box('app').put('motivationTopics', s.topics);
    await ref.read(goalControllerProvider.notifier).saveGoal(
      GoalModel(category: category, goal: goal, why: s.why.trim(), startDate: DateTime.now()),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(page: _page, onBack: _page > 0 ? _back : null),
            Expanded(
              child: PageView(
                controller: _ctrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepCategory(onNext: _next),
                  _StepTopics(onNext: _next),
                  _StepGoal(onNext: _next),
                  _StepWhy(onNext: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int page;
  final VoidCallback? onBack;
  const _TopBar({required this.page, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: AnimatedOpacity(
              opacity: onBack != null ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white54, size: 20),
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(4, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(left: 6),
              width: i == page ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == page ? Colors.white : Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Button ────────────────────────────────────────────────────────────

class _Btn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: AppTheme.labelStyle.copyWith(color: Colors.black, fontSize: 12)),
        ),
      ),
    );
  }
}

// ─── Step 1 · Категория ───────────────────────────────────────────────────────

const _cats = [
  (GoalCategory.body,    '💪', 'ТЕЛО',     'Физическое здоровье и форма'),
  (GoalCategory.money,   '💰', 'ФИНАНСЫ',  'Доход, сбережения, инвестиции'),
  (GoalCategory.skill,   '🎯', 'НАВЫК',    'Профессия, умение, результат'),
  (GoalCategory.mindset, '🧠', 'МЫШЛЕНИЕ', 'Фокус, дисциплина, привычки'),
];

class _StepCategory extends ConsumerWidget {
  final VoidCallback onNext;
  const _StepCategory({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_oProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ШАГ 1 / 4', style: AppTheme.labelStyle.copyWith(fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 10),
          Text('Что трансформируешь?',
              style: AppTheme.bodyStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Одна область. Шесть месяцев.',
              style: AppTheme.secondaryStyle.copyWith(fontSize: 13)),
          const SizedBox(height: 28),
          Expanded(
            child: Column(
              children: _cats.map((item) {
                final (cat, emoji, title, desc) = item;
                final on = s.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => ref.read(_oProvider.notifier).state = s.copyWith(category: cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: on ? Colors.white : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: on ? Colors.white : Colors.white12),
                      ),
                      child: Row(children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title, style: AppTheme.labelStyle.copyWith(
                              fontSize: 11, color: on ? Colors.black : Colors.white)),
                          const SizedBox(height: 2),
                          Text(desc, style: AppTheme.secondaryStyle.copyWith(
                              fontSize: 12, color: on ? Colors.black54 : Colors.white38)),
                        ]),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _Btn(label: 'ПРОДОЛЖИТЬ', enabled: s.category != null, onTap: onNext),
        ],
      ),
    );
  }
}

// ─── Step 2 · Темы ────────────────────────────────────────────────────────────

const _topicList = [
  '💪  Тело', '🧠  Мышление', '💰  Деньги', '🎯  Дисциплина',
  '📚  Учёба', '🏃  Спорт', '🥗  Питание', '😴  Сон',
  '🧘  Медитация', '💼  Карьера', '❤️  Отношения', '🎨  Творчество',
];

class _StepTopics extends ConsumerWidget {
  final VoidCallback onNext;
  const _StepTopics({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_oProvider);
    final sel = s.topics.toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ШАГ 2 / 4', style: AppTheme.labelStyle.copyWith(fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 10),
          Text('Что тебя мотивирует?',
              style: AppTheme.bodyStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('AI подберёт задачи по выбранным темам.',
              style: AppTheme.secondaryStyle.copyWith(fontSize: 13)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.8,
              ),
              itemCount: _topicList.length,
              itemBuilder: (_, i) {
                final t = _topicList[i];
                final on = sel.contains(t);
                return GestureDetector(
                  onTap: () {
                    final next = Set<String>.from(sel);
                    on ? next.remove(t) : next.add(t);
                    ref.read(_oProvider.notifier).state = s.copyWith(topics: next.toList());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? Colors.white : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: on ? Colors.white : Colors.white12),
                    ),
                    child: Text(t, style: AppTheme.bodyStyle.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: on ? Colors.black : Colors.white)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _Btn(
            label: sel.isEmpty ? 'ПРОПУСТИТЬ' : 'ПРОДОЛЖИТЬ  (${sel.length})',
            enabled: true,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// ─── Step 3 · Цель ────────────────────────────────────────────────────────────

class _StepGoal extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const _StepGoal({required this.onNext});
  @override
  ConsumerState<_StepGoal> createState() => _StepGoalState();
}

class _StepGoalState extends ConsumerState<_StepGoal> {
  late final TextEditingController _c;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: ref.read(_oProvider).goal);
    _c.addListener(() => ref.read(_oProvider.notifier).state =
        ref.read(_oProvider).copyWith(goal: _c.text));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Future<void> _rewrite() async {
    if (_c.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final result = await ClaudeService().rephraseGoal(_c.text.trim());
    _c.text = result;
    ref.read(_oProvider.notifier).state = ref.read(_oProvider).copyWith(goal: result);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(_oProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ШАГ 3 / 4', style: AppTheme.labelStyle.copyWith(fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 10),
          Text('Твоя цель\nчерез 6 месяцев',
              style: AppTheme.bodyStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 6),
          Text('Напиши от первого лица.',
              style: AppTheme.secondaryStyle.copyWith(fontSize: 13)),
          const SizedBox(height: 24),
          AppCard(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _c,
              minLines: 4, maxLines: 7,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: 'ЧЕРЕЗ 6 МЕСЯЦЕВ Я...',
                hintStyle: AppTheme.labelStyle.copyWith(color: Colors.white24, fontSize: 11),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _loading ? null : _rewrite,
            child: Row(children: [
              const Icon(Icons.auto_awesome, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(_loading ? 'Переформулирую...' : 'Помоги написать',
                  style: AppTheme.secondaryStyle.copyWith(fontSize: 13)),
            ]),
          ),
          const Spacer(),
          _Btn(label: 'ПРОДОЛЖИТЬ', enabled: s.goal.trim().isNotEmpty, onTap: widget.onNext),
        ],
      ),
    );
  }
}

// ─── Step 4 · Почему ──────────────────────────────────────────────────────────

class _StepWhy extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const _StepWhy({required this.onNext});
  @override
  ConsumerState<_StepWhy> createState() => _StepWhyState();
}

class _StepWhyState extends ConsumerState<_StepWhy> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: ref.read(_oProvider).why);
    _c.addListener(() => ref.read(_oProvider.notifier).state =
        ref.read(_oProvider).copyWith(why: _c.text));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(_oProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ШАГ 4 / 4', style: AppTheme.labelStyle.copyWith(fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 10),
          Text('Почему это\nважно для тебя?',
              style: AppTheme.bodyStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 6),
          Text('К этому возвращаешься когда мотивации нет.',
              style: AppTheme.secondaryStyle.copyWith(fontSize: 13)),
          const SizedBox(height: 24),
          AppCard(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _c,
              minLines: 4, maxLines: 7,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: 'ПОТОМУ ЧТО...',
                hintStyle: AppTheme.labelStyle.copyWith(color: Colors.white24, fontSize: 11),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ),
          const Spacer(),
          _Btn(label: 'НАЧАТЬ 6 МЕСЯЦЕВ', enabled: s.why.trim().isNotEmpty, onTap: widget.onNext),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: widget.onNext,
              child: Text('Пропустить', style: AppTheme.secondaryStyle.copyWith(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
