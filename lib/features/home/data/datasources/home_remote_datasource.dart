import 'package:dio/dio.dart';
import '../models/article_model.dart';

class HomeRemoteDatasource {
  const HomeRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Article>> fetchNews({int page = 1, int limit = 10}) async {
    final response = await _dio.get('/api/news/getAllNews/$page/$limit');
    final data = (response.data as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(Article.fromJson)
        .toList();
  }
}
