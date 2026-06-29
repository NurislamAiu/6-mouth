import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('6MONTH', style: AppTheme.labelStyle),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 156,
                    height: 156,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '6',
                      style: AppTheme.displayStyle.copyWith(fontSize: 112),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'months to transform',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 260,
                    child: Text(
                      'One goal. One task a day. One clean 180-day line.',
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryStyle,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            AppButton(label: 'Begin', onPressed: onNext, filled: true),
          ],
        ),
      ),
    );
  }
}
