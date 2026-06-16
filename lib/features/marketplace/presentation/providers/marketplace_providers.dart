import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../discover/data/models/deal_model.dart';
import '../../data/datasources/arosa_remote_datasource.dart';
import '../../data/datasources/marketplace_remote_datasource.dart';
import '../../data/models/arosa_package_model.dart';
import '../../data/models/luxury_hotel_model.dart';
import '../../data/models/villa_city_model.dart';
import '../../data/models/villa_rate_model.dart';
import '../../data/models/villa_rate_plan_model.dart';

// ── Internal datasource providers ────────────────────────────────────────────

final marketplaceDatasourceProvider = Provider<MarketplaceRemoteDatasource>(
  (ref) => MarketplaceRemoteDatasource(ref.watch(dioProvider)),
);

final _arosaDatasourceProvider = Provider<ArosaRemoteDatasource>(
  (ref) => ArosaRemoteDatasource(ref.watch(arosaDioProvider)),
);

// ── Package providers ─────────────────────────────────────────────────────────

final marketplaceDealsProvider = FutureProvider<List<Deal>>((ref) {
  return ref.watch(marketplaceDatasourceProvider).fetchDeals();
});

final myPackagesProvider = FutureProvider<List<Deal>>((ref) {
  return ref.watch(marketplaceDatasourceProvider).fetchMyPackages();
});

// ── Hotel providers ───────────────────────────────────────────────────────────

final luxuryHotelsProvider = FutureProvider<List<LuxuryHotelModel>>((ref) {
  return ref.watch(marketplaceDatasourceProvider).fetchLuxuryHotels();
});

// ── Villa providers ───────────────────────────────────────────────────────────

final villaCitiesProvider = FutureProvider<List<VillaCityModel>>((ref) {
  return ref.watch(marketplaceDatasourceProvider).fetchVillaCities();
});

typedef VillaSearchParams = ({
  String city,
  String checkin,  // '' means no date selected
  String checkout, // '' means no date selected
  int adults,
  int children,
});

final villaRatesProvider =
    FutureProvider.family<List<VillaRateModel>, VillaSearchParams>(
        (ref, params) {
  return ref.watch(marketplaceDatasourceProvider).searchVillaRates(
        city: params.city,
        checkin: params.checkin.isEmpty ? null : params.checkin,
        checkout: params.checkout.isEmpty ? null : params.checkout,
        adults: params.adults,
        children: params.children,
      );
});

typedef VillaRatePlanParams = ({
  String propertyId,
  String city,
  String checkin,
  String checkout,
  int adults,
  int children,
});

final villaRatePlansProvider =
    FutureProvider.family<List<VillaRatePlanModel>, VillaRatePlanParams>(
        (ref, params) {
  return ref.watch(marketplaceDatasourceProvider).fetchVillaRatePlans(
        propertyId: params.propertyId,
        city: params.city,
        checkin: params.checkin,
        checkout: params.checkout,
        adults: params.adults,
        children: params.children,
      );
});

// ── A-ROSA providers ──────────────────────────────────────────────────────────

final arosaTokenProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(_arosaDatasourceProvider).fetchToken();
});

typedef ArosaSearchParams = ({
  String token,
  String date,
  String river,
});

final arosaPackagesProvider =
    FutureProvider.family<List<ArosaPackageModel>, ArosaSearchParams>(
        (ref, params) {
  return ref.watch(_arosaDatasourceProvider).fetchPackages(
        token: params.token,
        date: params.date,
        river: params.river,
      );
});
