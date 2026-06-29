import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final String? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(title.toUpperCase(), style: AppTheme.labelStyle),
            ),
            if (trailing != null)
              Text(
                trailing!.toUpperCase(),
                style: AppTheme.labelStyle.copyWith(
                  color: AppTheme.secondaryText,
                  letterSpacing: 2,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Text(
            subtitle!,
            style: AppTheme.bodyStyle.copyWith(fontSize: 28, height: 1.08),
          ),
        ],
      ],
    );
  }
}
