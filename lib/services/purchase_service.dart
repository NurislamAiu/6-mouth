import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static const productId = 'sixmonth_lifetime_unlock';

  PurchaseService({InAppPurchase? purchases})
    : _purchases = purchases ?? InAppPurchase.instance;

  final InAppPurchase _purchases;

  Stream<List<PurchaseDetails>> get purchaseStream => _purchases.purchaseStream;

  Future<bool> get isAvailable => _purchases.isAvailable();

  Future<ProductDetails?> loadProduct() async {
    if (!await isAvailable) return null;
    final response = await _purchases.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _purchases.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() {
    return _purchases.restorePurchases();
  }

  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _purchases.completePurchase(purchase);
    }
  }
}
