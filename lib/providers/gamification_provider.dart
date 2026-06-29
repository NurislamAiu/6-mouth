import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gamification_model.dart';
import 'log_provider.dart';

final gamificationProvider = Provider<GamificationModel>((ref) {
  final logs = ref.watch(logControllerProvider);
  return buildGamification(logs);
});
