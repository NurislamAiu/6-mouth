import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/purchase_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'main_shell.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  static const _showDevelopmentUnlockFlag = bool.fromEnvironment(
    'SHOW_DEV_UNLOCK',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchase = ref.watch(purchaseControllerProvider);
    final showPreviewAccess = kDebugMode || _showDevelopmentUnlockFlag;
    final unlockLabel = purchase.productLoading ? 'Загрузка цены' : 'Открыть';
    ref.listen(purchaseControllerProvider, (_, next) {
      if (next.unlocked) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('6MONTH', style: AppTheme.labelStyle),
              const Spacer(),
              Text('180 ДНЕЙ', style: AppTheme.labelStyle),
              const SizedBox(height: 18),
              Text(
                'Открой своё преображение',
                style: AppTheme.bodyStyle.copyWith(fontSize: 36, height: 1.04),
              ),
              const SizedBox(height: 18),
              Text(
                purchase.product?.price ?? r'$17.99 one time',
                style: AppTheme.displayStyle,
              ),
              const SizedBox(height: 18),
              Text(
                'Полный доступ навсегда. Цель, логи, фото и рефлексии хранятся локально на устройстве.',
                style: AppTheme.secondaryStyle,
              ),
              if (purchase.error != null) ...[
                const SizedBox(height: 18),
                Text(purchase.error!, style: AppTheme.secondaryStyle),
              ],
              const Spacer(),
              AppButton(
                label: unlockLabel,
                onPressed: purchase.product == null
                    ? null
                    : () => ref.read(purchaseControllerProvider.notifier).buy(),
                loading: purchase.loading,
                filled: true,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: purchase.loading
                    ? null
                    : () {
                        ref.read(purchaseControllerProvider.notifier).restore();
                      },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text('ВОССТАНОВИТЬ ПОКУПКУ', style: AppTheme.labelStyle),
                  ),
                ),
              ),
              if (showPreviewAccess) ...[
                const SizedBox(height: 6),
                AppButton(
                  label: 'Просмотр приложения',
                  onPressed: () {
                    ref
                        .read(purchaseControllerProvider.notifier)
                        .unlockForDevelopment();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
