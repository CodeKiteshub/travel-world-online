import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/ppp_remote_datasource.dart';
import '../../data/models/ppp_model.dart';

final _pppDatasourceProvider = Provider<PppRemoteDatasource>(
  (ref) => PppRemoteDatasource(ref.watch(dioProvider)),
);

final pppAllProvider = FutureProvider<List<PppItem>>((ref) {
  return ref.watch(_pppDatasourceProvider).fetchAll();
});

final pppPoliciesProvider = FutureProvider.family<List<PppPolicyFull>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchPolicies(id);
});

final pppInvestmentsProvider = FutureProvider.family<List<PppInvestFull>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchInvestments(id);
});

final pppVideosProvider = FutureProvider.family<List<PppVideo>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchVideos(id);
});

final pppImagesProvider = FutureProvider.family<List<PppImage>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchImages(id);
});

final pppPdfsProvider = FutureProvider.family<List<PppPdf>, String>((ref, id) {
  return ref.watch(_pppDatasourceProvider).fetchPdfs(id);
});
