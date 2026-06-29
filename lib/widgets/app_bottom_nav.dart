import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onChanged,
  });

  final int currentIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: _NavButton(
                  item: item,
                  selected: selected,
                  onTap: () {
                    if (!selected) {
                      HapticFeedback.selectionClick();
                      onChanged(index);
                    }
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryText : AppTheme.background,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected ? AppTheme.primaryText : AppTheme.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                switchInCurve: AppMotion.curve,
                switchOutCurve: AppMotion.curve,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}-$selected'),
                  size: 19,
                  color: selected
                      ? AppTheme.background
                      : AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: AppTheme.labelStyle.copyWith(
                    fontSize: 8,
                    letterSpacing: 0.8,
                    color: selected
                        ? AppTheme.background
                        : AppTheme.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
