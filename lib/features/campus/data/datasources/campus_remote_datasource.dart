import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/campus_models.dart';

class CampusRemoteDatasource {
  const CampusRemoteDatasource({
    required this.backendDio,
    required this.twoDio,
  });

  final Dio backendDio;
  final Dio twoDio;

  // travelworldonline.in returns plain text; unwrap [{"tblvideocats": [...]}]
  List<dynamic> _unwrap(dynamic raw) {
    if (raw is String) {
      try {
        raw = jsonDecode(raw.trim());
      } catch (_) {
        return [];
      }
    }
    try {
      if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is Map<String, dynamic> && first['tblvideocats'] is List) {
          return first['tblvideocats'] as List<dynamic>;
        }
        return raw;
      }
      if (raw is Map<String, dynamic>) {
        return raw['tblvideocats'] as List<dynamic>? ??
            raw['data'] as List<dynamic>? ??
            [];
      }
    } catch (_) {}
    return [];
  }

  Future<List<AdvisoryBoardMember>> fetchAdvisoryBoard() async {
    final response =
        await backendDio.get('/api/advisoryBoard/getAdvisoryBoard');
    final raw = response.data;
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map<String, dynamic>) {
      list = raw['data'] as List<dynamic>? ?? [];
    } else {
      list = [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(AdvisoryBoardMember.fromJson)
        .toList();
  }

  Future<List<SkillCourse>> fetchSkillCourses() async {
    final response = await twoDio.get('/travelvideojson/courselist/');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(SkillCourse.fromJson)
        .toList();
  }

  Future<List<DestinationCategory>> fetchDestinations() async {
    final response = await twoDio.get('/travelvideojson/destcat/');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestinationCategory.fromJson)
        .toList();
  }

  Future<List<DestSubCategory>> fetchDestSubCategories(String catId) async {
    final response = await twoDio.get('/travelvideojson/destsubcat/?catid=$catId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestSubCategory.fromJson)
        .toList();
  }

  Future<List<DestSubSubCategory>> fetchDestSubSubCategories(
      String catId, String subCatId) async {
    final response = await twoDio.get(
        '/travelvideojson/destsubsubcat/?catid=$catId&subcatid=$subCatId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestSubSubCategory.fromJson)
        .toList();
  }

  Future<List<DestVideo>> fetchDestVideos(
      String catId, String subCatId, String subSubCatId) async {
    final response = await twoDio.get(
        '/travelvideojson/destinationlist/?catid=$catId&subcatid=$subCatId&subsubcatid=$subSubCatId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(DestVideo.fromJson)
        .toList();
  }

  Future<List<CampusCourseItem>> fetchCourseItems(String catId) async {
    final response =
        await twoDio.get('/travelvideojson/coursevideolist/?catid=$catId');
    return _unwrap(response.data)
        .whereType<Map<String, dynamic>>()
        .map(CampusCourseItem.fromJson)
        .toList();
  }
}
