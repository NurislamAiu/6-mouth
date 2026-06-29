import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/purchase_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/paywall_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('app');
  await Hive.openBox('logs');
  await NotificationService.instance.init();
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
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();

        final hasOnboarded = ref.watch(hasOnboardedProvider);
        final purchase = ref.watch(purchaseControllerProvider);

        if (!hasOnboarded) return const OnboardingFlow();
        if (!purchase.unlocked) return const PaywallScreen();
        return const MainShell();
      },
    );
  }
}
