import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/profile_remote_datasource.dart';

final _profileDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  ),
);

final memberProfileProvider = FutureProvider<BackendMember?>((ref) {
  return ref.watch(_profileDatasourceProvider).fetchMemberProfile();
});
