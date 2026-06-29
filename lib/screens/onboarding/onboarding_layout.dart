import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_theme.dart';

class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.step,
    required this.title,
    required this.child,
    required this.action,
    this.subtitle,
  });

  final int step;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(step: step),
            const Spacer(),
            Text(
              title,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 36,
                height: 1.02,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 14),
              Text(subtitle!, style: AppTheme.secondaryStyle),
            ],
            const SizedBox(height: 30),
            child,
            const Spacer(),
            action,
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(step.toString().padLeft(2, '0'), style: AppTheme.labelStyle),
        const SizedBox(width: 14),
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              final active = index < step;
              return Expanded(
                child: AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.curve,
                  height: 2,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.primaryText
                        : AppTheme.primaryText.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          '04',
          style: AppTheme.labelStyle.copyWith(color: AppTheme.secondaryText),
        ),
      ],
    );
  }
}
