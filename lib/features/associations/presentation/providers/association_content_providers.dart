import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/association_content_datasource.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_deal_model.dart';
import 'association_session_provider.dart';

final _contentDatasourceProvider = Provider<AssociationContentDatasource>(
  (ref) => AssociationContentDatasource(ref.watch(dioProvider)),
);

// ── Deals ─────────────────────────────────────────────────────────────────────

typedef _DealsParams = ({String assocId, String segment, String category});

final associationOffersProvider =
    FutureProvider.family<List<AssociationDealModel>, _DealsParams>(
        (ref, p) async {
  final session = ref.watch(associationSessionProvider)[p.assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchOffers(
        associationId: p.assocId,
        category: p.category,
        token: session.token,
      );
});

final associationDemandsProvider =
    FutureProvider.family<List<AssociationDemandModel>, _DealsParams>(
        (ref, p) async {
  final session = ref.watch(associationSessionProvider)[p.assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchDemands(
        associationId: p.assocId,
        category: p.category,
        token: session.token,
      );
});

final associationLastMinProvider =
    FutureProvider.family<List<AssociationLastMinModel>, String>(
        (ref, assocId) async {
  final session = ref.watch(associationSessionProvider)[assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchLastMin(
        associationId: assocId,
        token: session.token,
      );
});

// ── Circulars & Updates ───────────────────────────────────────────────────────

final associationCircularsProvider =
    FutureProvider.family<List<AssociationCircularModel>, String>(
        (ref, assocId) async {
  final session = ref.watch(associationSessionProvider)[assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchCirculars(
        associationId: assocId,
        token: session.token,
      );
});

final associationUpdatesProvider =
    FutureProvider.family<List<AssociationUpdateModel>, String>(
        (ref, assocId) async {
  final session = ref.watch(associationSessionProvider)[assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchUpdates(
        associationId: assocId,
        token: session.token,
      );
});

// ── Directory ─────────────────────────────────────────────────────────────────

typedef _SearchParams = ({String assocId, String query});

final associationMembersProvider =
    FutureProvider.family<List<AssociationMemberModel>, _SearchParams>(
        (ref, p) async {
  final session = ref.watch(associationSessionProvider)[p.assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).searchMembers(
        associationId: p.assocId,
        query: p.query,
        token: session.token,
      );
});

// ── Jobs ──────────────────────────────────────────────────────────────────────

// Jobs posted by the signed-in member of this association
final associationJobsProvider =
    FutureProvider.family<List<AssociationJobModel>, String>(
        (ref, assocId) async {
  final session = ref.watch(associationSessionProvider)[assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchJobs(
        memberId: session.memberId,
        token: session.token,
      );
});

typedef _ApplicantsParams = ({String assocId, String jobId});

final associationJobApplicantsProvider = FutureProvider.family<
    List<AssociationJobApplicantModel>, _ApplicantsParams>((ref, p) async {
  final session = ref.watch(associationSessionProvider)[p.assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchJobApplicants(
        jobPostId: p.jobId,
        token: session.token,
      );
});

// ── Cabs ──────────────────────────────────────────────────────────────────────

// Cab Network — all registered drivers, no session needed
final associationCabNetworkProvider =
    FutureProvider<List<AssociationCabModel>>(
        (ref) => ref.watch(_contentDatasourceProvider).fetchCabNetwork());

// Admin Cab — association's own fleet (requires session)
final associationCabsProvider =
    FutureProvider.family<List<AssociationCabModel>, String>(
        (ref, assocId) async {
  final session = ref.watch(associationSessionProvider)[assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchCabs(
        associationId: assocId,
        token: session.token,
      );
});

// ── Chat ──────────────────────────────────────────────────────────────────────

final associationChatsProvider =
    FutureProvider.family<List<AssociationChatModel>, String>(
        (ref, assocId) async {
  final session = ref.watch(associationSessionProvider)[assocId];
  if (session == null) return [];
  return ref.watch(_contentDatasourceProvider).fetchChats(
        memberId: session.memberId,
        token: session.token,
      );
});
