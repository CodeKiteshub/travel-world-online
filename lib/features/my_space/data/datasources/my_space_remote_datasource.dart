import 'package:dio/dio.dart';
import '../../../../core/storage/secure_storage.dart';

class MySpaceStats {
  const MySpaceStats({
    this.bookings = 0,
    this.pending = 0,
    this.saved = 0,
    this.enquiriesBadge = 0,
    this.chatBadge = 0,
  });

  final int bookings;
  final int pending;
  final int saved;
  final int enquiriesBadge;
  final int chatBadge;
}

class MySpaceRemoteDatasource {
  const MySpaceRemoteDatasource(this._dio, this._storage);

  final Dio _dio;
  final SecureStorageService _storage;

  Future<MySpaceStats> fetchStats() async {
    final memberId = await _storage.memberId;
    if (memberId == null || memberId.isEmpty) return const MySpaceStats();

    // Fetch all counts concurrently; individual failures return 0.
    final results = await Future.wait([
      _fetchBookingsCount(),
      _fetchPendingCount(memberId),
      _fetchSavedCount(memberId),
      _fetchChatCount(memberId),
    ]);

    final bookings = results[0];
    final pending = results[1];
    final saved = results[2];
    final chats = results[3];

    return MySpaceStats(
      bookings: bookings,
      pending: pending,
      saved: saved,
      enquiriesBadge: pending,
      chatBadge: chats,
    );
  }

  Future<int> _fetchBookingsCount() async {
    try {
      final response = await _dio.get('/api/PackageBuyer/mypackages');
      final data = (response.data as Map<String, dynamic>?)?['data'] as List?;
      return data?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchPendingCount(String memberId) async {
    try {
      final response =
          await _dio.get('/api/tailer-made/getByMemberId/$memberId');
      final data = (response.data as Map<String, dynamic>?)?['data'] as List?;
      return data?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchSavedCount(String memberId) async {
    try {
      final response =
          await _dio.get('/api/members/getById/$memberId');
      final member =
          (response.data as Map<String, dynamic>?)?['data'] as Map<String, dynamic>?;
      if (member == null) return 0;
      final h = (member['favoritesHotel'] as List?)?.length ?? 0;
      final t = (member['favoritesTransport'] as List?)?.length ?? 0;
      final p = (member['favoritesPackage'] as List?)?.length ?? 0;
      return h + t + p;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchChatCount(String memberId) async {
    try {
      final response = await _dio.get('/api/chat/$memberId');
      final data = response.data as List?;
      return data?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
