import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../associations/data/models/association_session_model.dart';
import '../../../associations/presentation/providers/association_session_provider.dart';
import '../../../discover/data/models/deal_model.dart';
import '../../data/datasources/arosa_remote_datasource.dart';
import '../../data/datasources/marketplace_remote_datasource.dart';
import '../../data/models/arosa_package_model.dart';
import '../../data/models/luxury_hotel_model.dart';
import '../../data/models/tailor_made_request_model.dart';
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

/// First active association session, or null when signed out of all of them.
/// My Packages and Tailor Made are association-member features and use this
/// session's token/memberId instead of the app-level login.
// ponytail: uses the first session; per-association picker if multi-login matters
final marketplaceSessionProvider = Provider<AssociationSessionModel?>((ref) {
  final sessions = ref.watch(associationSessionProvider);
  return sessions.values.isEmpty ? null : sessions.values.first;
});

final myPackagesProvider = FutureProvider<List<Deal>>((ref) {
  final session = ref.watch(marketplaceSessionProvider);
  if (session == null) return [];
  return ref
      .watch(marketplaceDatasourceProvider)
      .fetchMyPackages(token: session.token);
});

// ── Tailor Made providers ─────────────────────────────────────────────────────

final tailorMadeDestinationsProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(marketplaceDatasourceProvider).fetchTailorMadeDestinations();
});

final tailorMadeRequestsProvider =
    FutureProvider<List<TailorMadeRequest>>((ref) {
  final session = ref.watch(marketplaceSessionProvider);
  if (session == null || session.memberId.isEmpty) return Future.value([]);
  return ref
      .watch(marketplaceDatasourceProvider)
      .fetchTailorMadeRequests(session.memberId, token: session.token);
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
