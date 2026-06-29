import 'package:dio/dio.dart';
import '../../../home/data/models/article_model.dart';

class NewsRemoteDatasource {
  const NewsRemoteDatasource(this._dio);

  final Dio _dio;

  static const pageSize = 10;

  // Category IDs from the backend (matches old app's ArticleController.categoryList)
  static const categoryIds = <String, String>{
    'Hotels': '65bcd951d35fcf41dc0070b0',
    'Associations': '659ffcb10d48362fd8ca60c7',
    'Airlines': '659ffcc40d48362fd8ca60cb',
    'Tourism Boards': '659ffce10d48362fd8ca60cf',
    'Destination': '65d61f667b61b7000817ad53',
  };

  Future<List<Article>> fetchNews({int page = 1}) async {
    final response =
        await _dio.get('/api/news/getAllNews/$page/$pageSize');
    final data =
        (response.data as Map<String, dynamic>?)?['data'] as List<dynamic>? ??
            [];
    return data.cast<Map<String, dynamic>>().map(Article.fromJson).toList();
  }

  Future<List<Article>> fetchNewsByCategory(
    String categoryId, {
    int page = 1,
  }) async {
    final response = await _dio
        .get('/api/news/getByCategory/$categoryId/$page/$pageSize');
    final data =
        (response.data as Map<String, dynamic>?)?['data'] as List<dynamic>? ??
            [];
    return data.cast<Map<String, dynamic>>().map(Article.fromJson).toList();
  }
}
