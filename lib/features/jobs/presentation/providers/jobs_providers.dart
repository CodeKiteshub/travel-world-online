import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/jobs_remote_datasource.dart';
import '../../data/models/job_post_model.dart';

final jobsDatasourceProvider = Provider<JobsRemoteDatasource>(
  (ref) => JobsRemoteDatasource(ref.watch(dioProvider)),
);

final jobsProvider = FutureProvider<List<JobPost>>((ref) {
  return ref.watch(jobsDatasourceProvider).fetchJobs();
});
