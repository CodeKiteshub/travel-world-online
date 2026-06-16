import 'package:dio/dio.dart';
import '../../../../core/storage/secure_storage.dart';

class MembershipInfo {
  const MembershipInfo({required this.associationId, required this.associationName});
  final String associationId;
  final String associationName;
}

class BackendMember {
  const BackendMember({
    required this.id,
    required this.name,
    required this.email,
    required this.memberships,
    required this.savedCount,
  });

  final String id;
  final String name;
  final String email;
  final List<MembershipInfo> memberships;
  final int savedCount;
}

class ProfileRemoteDatasource {
  const ProfileRemoteDatasource(this._dio, this._storage);

  final Dio _dio;
  final SecureStorageService _storage;

  Future<BackendMember?> fetchMemberProfile() async {
    final memberId = await _storage.memberId;
    if (memberId == null || memberId.isEmpty) return null;
    try {
      final memberFuture = _dio.get('/api/members/getById/$memberId');
      final assocFuture = _dio
          .get('/api/associations/getAllAssociations')
          .then<dynamic>((r) => r.data)
          .catchError((_) => null);

      final results = await Future.wait<dynamic>([memberFuture, assocFuture]);

      final memberResp = results[0] as Response;
      final data = (memberResp.data as Map<String, dynamic>?)?['data']
          as Map<String, dynamic>?;
      if (data == null) return null;

      final knownAssocs = _parseAssociations(results[1]);
      return _buildMember(data, knownAssocs);
    } catch (_) {
      return null;
    }
  }

  BackendMember _buildMember(
    Map<String, dynamic> json,
    Map<String, String> assocNameById,
  ) {
    final h = (json['favoritesHotel'] as List?)?.length ?? 0;
    final t = (json['favoritesTransport'] as List?)?.length ?? 0;
    final p = (json['favoritesPackage'] as List?)?.length ?? 0;

    final rawAssocId = json['associationId'] as String? ?? '';
    final memberships = <MembershipInfo>[];
    if (rawAssocId.isNotEmpty) {
      memberships.add(MembershipInfo(
        associationId: rawAssocId,
        associationName: assocNameById[rawAssocId] ?? 'Member',
      ));
    }

    return BackendMember(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      memberships: memberships,
      savedCount: h + t + p,
    );
  }

  Map<String, String> _parseAssociations(dynamic raw) {
    try {
      final list = raw as List?;
      if (list == null || list.isEmpty) return {};
      final first = list[0] as Map<String, dynamic>?;
      final assocs = first?['association'] as List? ?? [];
      final result = <String, String>{};
      for (final a in assocs) {
        final id = a['id'] as String? ?? '';
        final name = a['name'] as String? ?? '';
        if (id.isNotEmpty) result[id] = name;
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}
