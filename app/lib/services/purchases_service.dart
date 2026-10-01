import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/config.dart';

enum PurchaseState { purchased, pending, cancelled, failed }

/// RevenueCat: one monthly subscription, "shotr Pro" at $19/month, entitlement "pro".
/// The Worker also receives RevenueCat webhooks, so the server knows who is Pro.
class PurchasesService {
  bool _configured = false;
  bool get configured => _configured;

  String get _key => Platform.isIOS ? Env.revenueCatIosKey : Env.revenueCatAndroidKey;

  Future<void> configure(String? appUserId) async {
    if (_key.isEmpty) {
      debugPrint('RevenueCat key missing: purchases disabled in this build.');
      return;
    }
    if (!_configured) {
      await Purchases.configure(PurchasesConfiguration(_key)..appUserID = appUserId);
      _configured = true;
    } else if (appUserId != null) {
      await Purchases.logIn(appUserId);
    }
  }

  Future<bool> isPro() async {
    if (!_configured) return false;
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(Env.proEntitlement);
  }

  /// The monthly package from the current offering, with its localized price.
  Future<Package?> monthly() async {
    if (!_configured) return null;
    final offerings = await Purchases.getOfferings();
    return offerings.current?.monthly ?? offerings.current?.availablePackages.firstOrNull;
  }

  Future<PurchaseState> buy(Package package) async {
    try {
      final r = await Purchases.purchase(PurchaseParams.package(package));
      return r.customerInfo.entitlements.active.containsKey(Env.proEntitlement) ? PurchaseState.purchased : PurchaseState.pending;
    } on PlatformException catch (e) {
      // SPEC edge case: "Purchase pending (UPI, slow cards): show pending, unlock on confirm".
      return switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError => PurchaseState.cancelled,
        PurchasesErrorCode.paymentPendingError => PurchaseState.pending,
        _ => PurchaseState.failed,
      };
    }
  }

  Future<bool> restore() async {
    if (!_configured) return false;
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(Env.proEntitlement);
  }

  void onChange(void Function(bool isPro) listener) {
    if (!_configured) return;
    Purchases.addCustomerInfoUpdateListener((info) => listener(info.entitlements.active.containsKey(Env.proEntitlement)));
  }

  Future<void> logOut() async {
    if (_configured && !(await Purchases.isAnonymous)) await Purchases.logOut();
  }
}
