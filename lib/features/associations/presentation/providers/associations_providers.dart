import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/associations_remote_datasource.dart';
import '../../data/models/association_model.dart';

final _associationsDatasourceProvider =
    Provider<AssociationsRemoteDatasource>(
  (ref) => AssociationsRemoteDatasource(ref.watch(dioProvider)),
);

final associationsProvider = FutureProvider<List<AssociationModel>>((ref) {
  return ref.watch(_associationsDatasourceProvider).fetchAssociations();
});
