import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/purchase_service.dart';

final purchaseControllerProvider =
    StateNotifierProvider<PurchaseController, PurchaseState>((ref) {
      final controller = PurchaseController(Hive.box('app'), PurchaseService());
      ref.onDispose(controller.dispose);
      return controller;
    });

class PurchaseState {
  const PurchaseState({
    required this.unlocked,
    this.loading = false,
    this.productLoading = false,
    this.product,
    this.error,
  });

  final bool unlocked;
  final bool loading;
  final bool productLoading;
  final ProductDetails? product;
  final String? error;

  PurchaseState copyWith({
    bool? unlocked,
    bool? loading,
    bool? productLoading,
    ProductDetails? product,
    String? error,
  }) {
    return PurchaseState(
      unlocked: unlocked ?? this.unlocked,
      loading: loading ?? this.loading,
      productLoading: productLoading ?? this.productLoading,
      product: product ?? this.product,
      error: error,
    );
  }
}

class PurchaseController extends StateNotifier<PurchaseState> {
  PurchaseController(this._box, this._service)
    : super(PurchaseState(unlocked: _box.get('unlocked') == true)) {
    _subscription = _service.purchaseStream.listen(_handlePurchases);
    loadProduct();
  }

  final Box _box;
  final PurchaseService _service;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> loadProduct() async {
    state = state.copyWith(productLoading: true, error: null);
    try {
      final product = await _service.loadProduct().timeout(
        const Duration(seconds: 6),
      );
      state = state.copyWith(productLoading: false, product: product);
    } on Object {
      state = state.copyWith(
        productLoading: false,
        error: 'Магазин недоступен в этой версии.',
      );
    }
  }

  Future<void> buy() async {
    final product = state.product;
    if (product == null) {
      state = state.copyWith(
        error: 'Товар в магазине ещё недоступен.',
        loading: false,
      );
      return;
    }
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.buy(product);
    } on Object {
      state = state.copyWith(
        loading: false,
        error: 'Не удалось начать покупку.',
      );
    }
  }

  Future<void> restore() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.restore().timeout(const Duration(seconds: 8));
      state = state.copyWith(loading: false);
    } on Object {
      state = state.copyWith(loading: false, error: 'Нечего восстанавливать.');
    }
  }

  Future<void> unlockForDevelopment() async {
    await _unlock();
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != PurchaseService.productId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _unlock();
      }
      if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          loading: false,
          error: purchase.error?.message ?? 'Покупка не удалась.',
        );
      }
      await _service.complete(purchase);
    }
  }

  Future<void> _unlock() async {
    await _box.put('unlocked', true);
    await _box.put('unlockDate', DateTime.now().toIso8601String());
    state = state.copyWith(unlocked: true, loading: false, error: null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
