import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/discover_remote_datasource.dart';
import '../../data/models/deal_model.dart';

final _discoverDatasourceProvider = Provider<DiscoverRemoteDatasource>(
  (ref) => DiscoverRemoteDatasource(ref.watch(dioProvider)),
);

final featuredDealsProvider = FutureProvider<List<Deal>>((ref) {
  return ref.watch(_discoverDatasourceProvider).fetchFeaturedDeals();
});
