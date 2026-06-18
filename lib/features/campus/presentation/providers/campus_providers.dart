import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/campus_remote_datasource.dart';
import '../../data/models/campus_models.dart';

final _campusDatasourceProvider = Provider<CampusRemoteDatasource>(
  (ref) => CampusRemoteDatasource(
    backendDio: ref.watch(dioProvider),
    twoDio: ref.watch(twoDioProvider),
  ),
);

final advisoryBoardProvider =
    FutureProvider<List<AdvisoryBoardMember>>((ref) {
  return ref.watch(_campusDatasourceProvider).fetchAdvisoryBoard();
});

final skillCoursesProvider = FutureProvider<List<SkillCourse>>((ref) {
  return ref.watch(_campusDatasourceProvider).fetchSkillCourses();
});

final destinationsProvider =
    FutureProvider<List<DestinationCategory>>((ref) {
  return ref.watch(_campusDatasourceProvider).fetchDestinations();
});

final destSubCategoriesProvider =
    FutureProvider.family<List<DestSubCategory>, String>((ref, catId) {
  return ref.watch(_campusDatasourceProvider).fetchDestSubCategories(catId);
});

// Key is (catId, subCatId) encoded as '$catId|$subCatId'
final destSubSubCategoriesProvider =
    FutureProvider.family<List<DestSubSubCategory>, String>((ref, key) {
  final parts = key.split('|');
  return ref.watch(_campusDatasourceProvider)
      .fetchDestSubSubCategories(parts[0], parts.length > 1 ? parts[1] : '');
});

// Key is '$catId|$subCatId|$subSubCatId'
final destVideosProvider =
    FutureProvider.family<List<DestVideo>, String>((ref, key) {
  final parts = key.split('|');
  return ref.watch(_campusDatasourceProvider).fetchDestVideos(
      parts[0],
      parts.length > 1 ? parts[1] : '',
      parts.length > 2 ? parts[2] : '');
});

final campusCourseItemsProvider =
    FutureProvider.family<List<CampusCourseItem>, String>((ref, catId) {
  return ref.watch(_campusDatasourceProvider).fetchCourseItems(catId);
});
