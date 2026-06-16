import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/my_space_remote_datasource.dart';

final _mySpaceDatasourceProvider = Provider<MySpaceRemoteDatasource>(
  (ref) => MySpaceRemoteDatasource(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  ),
);

final mySpaceStatsProvider = FutureProvider<MySpaceStats>((ref) {
  return ref.watch(_mySpaceDatasourceProvider).fetchStats();
});
