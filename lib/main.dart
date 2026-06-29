import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/goal_provider.dart';
import 'providers/purchase_provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/paywall_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('app');
  await Hive.openBox('logs');
  runApp(const ProviderScope(child: SixMonthApp()));
}

class SixMonthApp extends ConsumerWidget {
  const SixMonthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '6MONTH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppGate(),
    );
  }
}

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasOnboarded = ref.watch(hasOnboardedProvider);
    final purchase = ref.watch(purchaseControllerProvider);

    if (!hasOnboarded) return const OnboardingFlow();
    if (!purchase.unlocked) return const PaywallScreen();
    return const MainShell();
  }
}
