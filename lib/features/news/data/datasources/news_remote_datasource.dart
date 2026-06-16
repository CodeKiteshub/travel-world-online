import 'package:dio/dio.dart';

import '../models/news_item.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsItem>> getAllNews();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  NewsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NewsItem>> getAllNews() async {
    // Using the endpoint from AppConstants.getAllNewsUrl
    final response = await dio.get('/api/news/getAllNews');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch news: ${response.statusCode}');
    }
  }
}
