import 'package:dio/dio.dart';
import '../models/association_model.dart';

class AssociationsRemoteDatasource {
  const AssociationsRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<AssociationModel>> fetchAssociations() async {
    final response =
        await _dio.get('/api/associations/getAllAssociations');

    final raw = response.data;
    List<dynamic> list;
    if (raw is List) {
      final first = raw.first as Map<String, dynamic>;
      list = first['association'] as List<dynamic>? ?? raw;
    } else if (raw is Map<String, dynamic>) {
      list = raw['association'] as List<dynamic>? ??
          raw['data'] as List<dynamic>? ??
          [];
    } else {
      list = [];
    }

    return list
        .cast<Map<String, dynamic>>()
        .map(AssociationModel.fromJson)
        .toList();
  }
}
