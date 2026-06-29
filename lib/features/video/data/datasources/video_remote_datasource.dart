import 'package:dio/dio.dart';
import '../models/video_models.dart';

class VideoRemoteDatasource {
  const VideoRemoteDatasource(this._dio);

  final Dio _dio;

  static const pageSize = 10;

  Future<List<VideoItem>> fetchVideos({
    required String category,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/interview/getAllInterviewByCategory/$category/$page/$pageSize',
    );
    final raw = response.data;
    final Map<String, dynamic> data;
    if (raw is Map<String, dynamic>) {
      data = raw;
    } else {
      return [];
    }
    if (data['success'] != true) return [];
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(VideoItem.fromJson)
        .toList();
  }
}
