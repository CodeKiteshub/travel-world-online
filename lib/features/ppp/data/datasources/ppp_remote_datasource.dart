import 'package:dio/dio.dart';
import '../models/ppp_model.dart';

class PppRemoteDatasource {
  const PppRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<PppItem>> fetchAll() async {
    final response = await _dio.get('/api/ppp');
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
        .map(PppItem.fromJson)
        .toList();
  }

  Future<List<PppPolicyFull>> fetchPolicies(String id) async {
    final response = await _dio.get('/api/ppp/$id/policies');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppPolicyFull.fromJson).toList();
  }

  Future<List<PppInvestFull>> fetchInvestments(String id) async {
    final response = await _dio.get('/api/ppp/$id/investment-opportunities');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppInvestFull.fromJson).toList();
  }

  Future<List<PppVideo>> fetchVideos(String id) async {
    final response = await _dio.get('/api/ppp/$id/getVideo');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppVideo.fromJson).toList();
  }

  Future<List<PppImage>> fetchImages(String id) async {
    final response = await _dio.get('/api/ppp/$id/getImage');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppImage.fromJson).toList();
  }

  Future<List<PppPdf>> fetchPdfs(String id) async {
    final response = await _dio.get('/api/ppp/$id/getPdf');
    final raw = response.data;
    final list = (raw is Map<String, dynamic>)
        ? (raw['data'] as List<dynamic>? ?? [])
        : (raw is List ? raw : []);
    return list.cast<Map<String, dynamic>>().map(PppPdf.fromJson).toList();
  }

  Future<List<PppStakeholder>> fetchDirectory(String pppId) async {
    final response =
        await _dio.get('/api/StackHolder/getStackHolderByPPPId/$pppId');
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
        .whereType<Map<String, dynamic>>()
        .map(PppStakeholder.fromJson)
        .toList();
  }

  Future<bool> submitRegistration(
      Map<String, String> fields, {
      String? imagePath,
    }) async {
    final Map<String, dynamic> formFields = Map.from(fields);
    if (imagePath != null && imagePath.isNotEmpty) {
      formFields['document'] = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }
    final formData = FormData.fromMap(formFields);
    final response = await _dio.post(
      '/api/StackHolder/addStackHolder',
      data: formData,
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }
}
