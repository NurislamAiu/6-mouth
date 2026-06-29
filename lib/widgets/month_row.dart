import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

class MonthRow extends StatefulWidget {
  const MonthRow({
    super.key,
    required this.number,
    required this.name,
    required this.completed,
    required this.current,
    required this.summary,
  });

  final int number;
  final String name;
  final bool completed;
  final bool current;
  final String? summary;

  @override
  State<MonthRow> createState() => _MonthRowState();
}

class _MonthRowState extends State<MonthRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final opacity = widget.completed || widget.current ? 1.0 : 0.25;
    return AnimatedOpacity(
      duration: AppMotion.normal,
      curve: AppMotion.curve,
      opacity: opacity,
      child: InkWell(
        onTap: widget.completed
            ? () => setState(() => _expanded = !_expanded)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      widget.number.toString().padLeft(2, '0'),
                      style: AppTheme.labelStyle,
                    ),
                  ),
                  Expanded(child: Text(widget.name, style: AppTheme.bodyStyle)),
                  if (widget.completed)
                    const Icon(Icons.check, color: AppTheme.primaryText)
                  else if (widget.current)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryText,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'NOW',
                        style: AppTheme.labelStyle.copyWith(
                          color: AppTheme.background,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                  else
                    Text('LOCKED', style: AppTheme.labelStyle),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14, left: 44),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.summary ?? 'Reflection summary is building.',
                      style: AppTheme.secondaryStyle,
                    ),
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: AppMotion.normal,
                firstCurve: AppMotion.curve,
                secondCurve: AppMotion.curve,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
