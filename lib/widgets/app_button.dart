import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        opacity: enabled || loading ? 1 : 0.35,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          decoration: BoxDecoration(
            color: filled ? AppTheme.primaryText : AppTheme.background,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppTheme.primaryText),
          ),
          child: TextButton(
            onPressed: enabled ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: filled
                  ? AppTheme.background
                  : AppTheme.primaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.curve,
              switchOutCurve: AppMotion.curve,
              child: loading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: filled
                            ? AppTheme.background
                            : AppTheme.primaryText,
                      ),
                    )
                  : Text(
                      label.toUpperCase(),
                      key: ValueKey(label),
                      style: AppTheme.labelStyle.copyWith(
                        color: filled
                            ? AppTheme.background
                            : AppTheme.primaryText,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
