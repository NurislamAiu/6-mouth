import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

class StatBox extends StatelessWidget {
  const StatBox({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.labelStyle),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTheme.displayStyle),
          ),
        ],
      ),
    );
  }
}
