import 'package:dio/dio.dart';
import '../models/job_post_model.dart';

class JobsRemoteDatasource {
  const JobsRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<JobPost>> fetchJobs() async {
    final response = await _dio.get('/api/jobposts');
    final raw = response.data;
    List<dynamic> list;
    if (raw is Map<String, dynamic>) {
      list = raw['data'] as List<dynamic>? ?? [];
    } else if (raw is List) {
      list = raw;
    } else {
      list = [];
    }
    return list
        .cast<Map<String, dynamic>>()
        .map(JobPost.fromJson)
        .toList();
  }

  Future<void> applyToJob({
    required String jobPostId,
    required String fullName,
    required String email,
    required String mobile,
    required String currentCtc,
    required String expectedCtc,
    required String cvFilePath,
    required String cvFileName,
  }) async {
    final form = FormData.fromMap({
      'JobPostId': jobPostId,
      'fullname': fullName,
      'email': email,
      'mobile': mobile,
      'currentCTC': currentCtc,
      'expectedCTC': expectedCtc,
      'file': await MultipartFile.fromFile(cvFilePath, filename: cvFileName),
    });
    await _dio.post('/api/jobapply', data: form);
  }
}
