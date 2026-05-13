import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/models/article_model.dart';

final _homeDatasourceProvider = Provider<HomeRemoteDatasource>(
  (ref) => HomeRemoteDatasource(ref.watch(dioProvider)),
);

final newsProvider = FutureProvider<List<Article>>((ref) {
  return ref.watch(_homeDatasourceProvider).fetchNews();
});
