import 'package:dio/dio.dart';
import '../models/association_content_model.dart';
import '../models/association_deal_model.dart';

class AssociationContentDatasource {
  AssociationContentDatasource(this._dio);
  final Dio _dio;

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ── Deals ─────────────────────────────────────────────────────────────────

  Future<List<AssociationDealModel>> fetchOffers({
    required String associationId,
    required String category,
    required String token,
  }) async {
    // Old API embeds assocId in the path; response is [{<key>:[...]}]
    final res = await _dio.get(
      _offersEndpoint(category, associationId),
      options: _auth(token),
    );
    return _parseDealEnvelope(res.data, _envelopeKey(category));
  }

  Future<List<AssociationDemandModel>> fetchDemands({
    required String associationId,
    required String category,
    required String token,
  }) async {
    final res = await _dio.get(
      _demandsEndpoint(category, associationId),
      options: _auth(token),
    );
    return _parseDemandEnvelope(res.data, _envelopeKey(category));
  }

  Future<List<AssociationLastMinModel>> fetchLastMin({
    required String associationId,
    required String token,
  }) async {
    final res = await _dio.get(
      '/api/package/lastmin',
      queryParameters: {'associationId': associationId},
      options: _auth(token),
    );
    return _parseList(res.data, AssociationLastMinModel.fromJson);
  }

  Future<void> createOffer({
    required String associationId,
    required String token,
    required String category,
    required String destination,
    required int nights,
    required int days,
    required double price,
    required String hotelCategory,
    String? imagePath,
  }) async {
    final endpoint = _createEndpoint(category);
    final formData = FormData.fromMap({
      'associationId': associationId,
      'destination': destination,
      'nights': nights,
      'days': days,
      'price': price,
      'hotelCategory': hotelCategory,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(imagePath),
    });
    await _dio.post(
      endpoint,
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      }),
    );
  }

  Future<void> createDemand({
    required String associationId,
    required String token,
    required String category,
    required String destination,
    required double budgetMin,
    required double budgetMax,
    required int pax,
    required int nights,
    required String details,
  }) async {
    final endpoint = _demandsCreateEndpoint(category);
    await _dio.post(
      endpoint,
      data: {
        'associationId': associationId,
        'category': category,
        'destination': destination,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'pax': pax,
        'nights': nights,
        'details': details,
      },
      options: _auth(token),
    );
  }

  Future<void> deleteDeal({
    required String id,
    required String category,
    required String token,
  }) async {
    final endpoint = _deleteEndpoint(category, id);
    await _dio.delete(endpoint, options: _auth(token));
  }

  Future<void> toggleFavourite({
    required String id,
    required String category,
    required String token,
  }) async {
    final endpoint = _favEndpoint(category);
    await _dio.put(
      endpoint,
      data: {'packageId': id},
      options: _auth(token),
    );
  }

  // ── Circulars & Updates ───────────────────────────────────────────────────

  Future<List<AssociationCircularModel>> fetchCirculars({
    required String associationId,
    required String token,
  }) async {
    final res = await _dio.get('/api/circulars/$associationId', options: _auth(token));
    final raw = res.data;
    if (raw is List && raw.isNotEmpty) {
      final block = raw.first as Map<String, dynamic>;
      // Backend key is 'circular' (singular, lowercase)
      final list = block['circular'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(AssociationCircularModel.fromJson)
          .toList();
    }
    return [];
  }

  Future<List<AssociationUpdateModel>> fetchUpdates({
    required String associationId,
    required String token,
  }) async {
    final res = await _dio.get('/api/updates/$associationId', options: _auth(token));
    final raw = res.data;
    if (raw is List && raw.isNotEmpty) {
      final block = raw.first as Map<String, dynamic>;
      // Backend key is 'Update' (capital U, singular)
      final list = block['Update'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(AssociationUpdateModel.fromJson)
          .toList();
    }
    return [];
  }

  // ── Directory ─────────────────────────────────────────────────────────────

  Future<List<AssociationMemberModel>> searchMembers({
    required String associationId,
    required String query,
    required String token,
  }) async {
    final res = await _dio.get(
      '/api/members/search',
      queryParameters: {'associationId': associationId, 'query': query},
      options: _auth(token),
    );
    return _parseList(res.data, AssociationMemberModel.fromJson);
  }

  // ── Jobs ──────────────────────────────────────────────────────────────────

  /// Jobs posted by the signed-in member (matches old app's association
  /// Job Section — endpoint spelling 'ByMembrId' is the backend's).
  Future<List<AssociationJobModel>> fetchJobs({
    required String memberId,
    required String token,
  }) async {
    final res =
        await _dio.get('/api/jobposts/ByMembrId/$memberId', options: _auth(token));
    return _parseList(res.data, AssociationJobModel.fromJson);
  }

  Future<void> postJob({
    required String associationId,
    required String memberId,
    required String token,
    required String jobTitle,
    required String companyName,
    required String jobDescription,
    required String location,
    String companyWebsite = '',
  }) async {
    await _dio.post(
      '/api/jobposts',
      data: {
        'associationId': associationId,
        'memberId': memberId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'jobDescription': jobDescription,
        'location': location,
        'companyWebsite': companyWebsite,
      },
      options: _auth(token),
    );
  }

  Future<List<AssociationJobApplicantModel>> fetchJobApplicants({
    required String jobPostId,
    required String token,
  }) async {
    final res = await _dio.get(
      '/api/jobapply/getApplyJobtByJobPostId/$jobPostId',
      options: _auth(token),
    );
    return _parseList(res.data, AssociationJobApplicantModel.fromJson);
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  Future<List<AssociationChatModel>> fetchChats({
    required String memberId,
    required String token,
  }) async {
    final res = await _dio.get('/api/chat/$memberId', options: _auth(token));
    if (res.data is! List) return [];
    return (res.data as List).whereType<Map<String, dynamic>>().map((j) {
      final members = (j['members'] as List?)?.map((e) => e.toString()).toList() ?? [];
      // Show the other person's name (not ours)
      final name = members.isNotEmpty && members.first == memberId
          ? (j['receiverName'] as String? ?? '')
          : (j['senderName'] as String? ?? '');
      return AssociationChatModel(
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        name: name,
        lastMessage: '',
        time: j['updatedAt'] as String? ?? '',
      );
    }).toList();
  }

  // ── Cabs ──────────────────────────────────────────────────────────────────

  // Cab Network — all registered drivers, no auth required
  Future<List<AssociationCabModel>> fetchCabNetwork() async {
    final res = await _dio.get('/api/CabBooking/cab');
    return _parseList(res.data, AssociationCabModel.fromJson);
  }

  // ── Admin Cab (vehicles) — endpoints match old app's RemoteApi ────────────

  /// Vehicles uploaded by the signed-in member (old "Admin Cab" tab).
  Future<List<AssociationVehicleModel>> fetchMyVehicles({
    required String token,
  }) async {
    final res = await _dio.get('/api/vehicles/myVehicles', options: _auth(token));
    return _parseList(res.data, AssociationVehicleModel.fromJson);
  }

  /// All vehicles in the association (old "All Cab" tab).
  Future<List<AssociationVehicleModel>> fetchAssociationVehicles({
    required String associationId,
    required String token,
  }) async {
    final res = await _dio.get(
      '/api/vehicles/getVehicles/$associationId',
      options: _auth(token),
    );
    return _parseList(res.data, AssociationVehicleModel.fromJson);
  }

  Future<List<AssociationVehicleModel>> searchVehicles({
    required String associationId,
    required String query,
    required String token,
  }) async {
    final res = await _dio.get(
      '/api/vehicles/search',
      queryParameters: {'query': query, 'associationId': associationId},
      options: _auth(token),
    );
    return _parseList(res.data, AssociationVehicleModel.fromJson);
  }

  Future<void> addVehicle({
    required String associationId,
    required String token,
    required String name,
    required String type,
    required String year,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'associationId': associationId,
      'name': name,
      'type': type,
      'year': year,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(imagePath,
            filename: 'vehicle_image.png'),
    });
    await _dio.post(
      '/api/vehicles/addVehicle',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      }),
    );
  }

  Future<void> deleteVehicle({
    required String vehicleId,
    required String token,
  }) async {
    await _dio.delete('/api/vehicles/deleteVehicle/$vehicleId',
        options: _auth(token));
  }

  /// Backend toggles regardless of body — old app always sent true.
  Future<void> toggleVehicleAvailability({
    required String vehicleId,
    required String token,
  }) async {
    await _dio.put(
      '/api/vehicles/toggle-availability/$vehicleId',
      data: {'isAvailable': true},
      options: _auth(token),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['data'] as List? ??
          data['result'] as List? ??
          data['items'] as List? ??
          [];
      return list.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }
    return [];
  }

  // Backend returns [{<key>:[...]}] — extract the inner deal list
  List<AssociationDealModel> _parseDealEnvelope(dynamic data, String key) {
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      final list = (data.first as Map<String, dynamic>)[key] as List? ?? [];
      return list.whereType<Map<String, dynamic>>()
          .map(AssociationDealModel.fromJson).toList();
    }
    return [];
  }

  List<AssociationDemandModel> _parseDemandEnvelope(dynamic data, String key) {
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      final list = (data.first as Map<String, dynamic>)[key] as List? ?? [];
      return list.whereType<Map<String, dynamic>>()
          .map(AssociationDemandModel.fromJson).toList();
    }
    return [];
  }

  // Assoc ID goes in the path, not a query param — matches old API
  String _offersEndpoint(String cat, String assocId) => switch (cat) {
        'Hotel' => '/api/hotel/Gethotels/$assocId',
        'Transport' => '/api/transport/GetTransport/$assocId',
        _ => '/api/package/Getpackages/$assocId',
      };

  String _demandsEndpoint(String cat, String assocId) => switch (cat) {
        'Hotel' => '/api/Hotelbuyer/GetAllhotels/$assocId',
        'Transport' => '/api/TransportBuyer/GetAllTransport/$assocId',
        _ => '/api/PackageBuyer/Getpackages/$assocId',
      };

  // Response envelope key per category (case-sensitive, confirmed from old B2BModel)
  String _envelopeKey(String cat) => switch (cat) {
        'Hotel' => 'hotel',       // lowercase h
        'Transport' => 'Transport', // capital T
        _ => 'Packages',           // capital P
      };

  String _createEndpoint(String cat) => switch (cat) {
        'Hotel' => '/api/hotel',
        'Transport' => '/api/transport',
        _ => '/api/package',
      };

  String _demandsCreateEndpoint(String cat) => switch (cat) {
        'Hotel' => '/api/Hotelbuyer',
        'Transport' => '/api/TransportBuyer',
        _ => '/api/PackageBuyer',
      };

  String _deleteEndpoint(String cat, String id) => switch (cat) {
        'Hotel' => '/api/hotel/deleteHotel/$id',
        'Transport' => '/api/transport/deleteTransport/$id',
        _ => '/api/package/deletePackage/$id',
      };

  String _favEndpoint(String cat) => switch (cat) {
        'Hotel' => '/api/hotel/AddorRemovefavorites',
        'Transport' => '/api/transport/AddorRemovefavorites',
        _ => '/api/package/AddorRemovefavorites',
      };
}
