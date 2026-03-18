// ─────────────────────────────────────────────────────────────────────────────
// PurchaseService
//
// AKTUELL: Simuliert Premium (für Development & TestFlight/Internal Testing)
//
// FÜR STORE-RELEASE — nur diese Datei anfassen:
//   1. `flutter pub add purchases_flutter`  (RevenueCat SDK)
//   2. RevenueCat Dashboard:
//      - App anlegen (iOS + Android)
//      - Produkt anlegen: "custom_categories" für 1,99€
//      - API-Keys kopieren
//   3. Unten die 3 Methoden mit echtem RevenueCat-Code ersetzen
//      (Beispiel-Implementierung als Kommentar bereits dabei)
//
// SONST NICHTS ÄNDERN — alle Screens nutzen diesen Service bereits korrekt.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseService {
  static const String _productId = 'custom_categories';
  static const double price = 1.99;
  static const String priceLabel = '1,99 €';

  final SupabaseClient _client = Supabase.instance.client;

  // ── Premium Status prüfen ──────────────────────────────────────────────────

  Future<bool> isPremium(String userId) async {
    // TODO (Store-Release): RevenueCat-Entitlement prüfen statt Datenbank
    //
    // RevenueCat Beispiel:
    // final customerInfo = await Purchases.getCustomerInfo();
    // return customerInfo.entitlements.active.containsKey('premium');

    try {
      final result = await _client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .maybeSingle();
      return result?['is_premium'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Kauf starten ───────────────────────────────────────────────────────────

  Future<PurchaseResult> purchasePremium(String userId) async {
    // TODO (Store-Release): Echten In-App Purchase starten
    //
    // RevenueCat Beispiel:
    // try {
    //   final offerings = await Purchases.getOfferings();
    //   final package = offerings.current?.availablePackages.first;
    //   if (package == null) return PurchaseResult.error('Kein Angebot verfügbar');
    //   final info = await Purchases.purchasePackage(package);
    //   if (info.entitlements.active.containsKey('premium')) {
    //     await _setDatabasePremium(userId, true);
    //     return PurchaseResult.success();
    //   }
    //   return PurchaseResult.error('Kauf nicht aktiviert');
    // } on PlatformException catch (e) {
    //   final code = PurchasesErrorHelper.getErrorCode(e);
    //   if (code == PurchasesErrorCode.purchaseCancelledError) {
    //     return PurchaseResult.cancelled();
    //   }
    //   return PurchaseResult.error(e.message ?? 'Unbekannter Fehler');
    // }

    // DEV-Modus: Direkt freischalten
    await _setDatabasePremium(userId, true);
    return PurchaseResult.success();
  }

  // ── Käufe wiederherstellen ─────────────────────────────────────────────────

  Future<PurchaseResult> restorePurchases(String userId) async {
    // TODO (Store-Release): RevenueCat Restore
    //
    // RevenueCat Beispiel:
    // try {
    //   final info = await Purchases.restorePurchases();
    //   final hasPremium = info.entitlements.active.containsKey('premium');
    //   if (hasPremium) await _setDatabasePremium(userId, true);
    //   return hasPremium ? PurchaseResult.success() : PurchaseResult.error('Kein Kauf gefunden');
    // } catch (e) {
    //   return PurchaseResult.error(e.toString());
    // }

    // DEV-Modus: Gibt aktuellen Status zurück
    final premium = await isPremium(userId);
    return premium
        ? PurchaseResult.success()
        : PurchaseResult.error('Kein Kauf gefunden');
  }

  // ── RevenueCat initialisieren (in main.dart aufrufen) ─────────────────────

  Future<void> initialize(String userId) async {
    // TODO (Store-Release):
    // await Purchases.setLogLevel(LogLevel.debug); // nur dev
    // await Purchases.configure(
    //   PurchasesConfiguration('REVENUECAT_API_KEY_IOS') // oder Android-Key
    //     ..appUserID = userId,
    // );
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _setDatabasePremium(String userId, bool value) async {
    await _client
        .from('profiles')
        .update({'is_premium': value}).eq('id', userId);
  }
}

// ── Result-Klasse ─────────────────────────────────────────────────────────────

enum PurchaseStatus { success, cancelled, error }

class PurchaseResult {
  final PurchaseStatus status;
  final String? errorMessage;

  const PurchaseResult._(this.status, this.errorMessage);

  factory PurchaseResult.success() =>
      const PurchaseResult._(PurchaseStatus.success, null);
  factory PurchaseResult.cancelled() =>
      const PurchaseResult._(PurchaseStatus.cancelled, null);
  factory PurchaseResult.error(String msg) =>
      PurchaseResult._(PurchaseStatus.error, msg);

  bool get isSuccess => status == PurchaseStatus.success;
  bool get isCancelled => status == PurchaseStatus.cancelled;
  bool get isError => status == PurchaseStatus.error;
}
