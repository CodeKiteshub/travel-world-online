import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../models/campus_models.dart';

class CampusRemoteDatasource {
  const CampusRemoteDatasource({required this.backendDio});

  final Dio backendDio;

  Future<List<AdvisoryBoardMember>> fetchAdvisoryBoard() async {
    // Endpoint lives on backend.twoapp.in (same backend as the app, requires auth)
    final response =
        await backendDio.get('/api/advisoryBoard/getAdvisoryBoard');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw.trim());
      } catch (_) {
        return [];
      }
    }
    // Response shape: [{advisoryBoard: [{_id, name, post, about, images}]}]
    List<dynamic> items = [];
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map<String, dynamic>) {
        items = first['advisoryBoard'] as List<dynamic>? ?? [];
      }
    } else if (raw is Map<String, dynamic>) {
      items = raw['advisoryBoard'] as List<dynamic>? ??
          raw['data'] as List<dynamic>? ??
          [];
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdvisoryBoardMember.fromJson)
        .toList();
  }

  FirebaseFirestore get _fs => FirebaseFirestore.instance;

  Future<List<SkillCourse>> fetchSkillCourses() async {
    final snap = await _fs.collection('courseCategory').orderBy('order').get();
    return snap.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return SkillCourse.fromJson(data);
    }).toList();
  }

  Future<List<DestinationCategory>> fetchDestinations() async {
    final snap = await _fs.collection('country').orderBy('order').get();
    return snap.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return DestinationCategory.fromJson(data);
    }).toList();
  }

  Future<List<DestSubCategory>> fetchDestSubCategories(String catId) async {
    final snap = await _fs
        .collection('country')
        .doc(catId)
        .collection('countryCategory')
        .orderBy('order')
        .get();
    return snap.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return DestSubCategory.fromJson(data);
    }).toList();
  }

  // Firebase has no sub-sub-category level — returning empty triggers the
  // existing skip-to-video redirect in DestSubSubCategoryScreen.
  Future<List<DestSubSubCategory>> fetchDestSubSubCategories(
      String catId, String subCatId) async {
    return [];
  }

  // subSubCatId is '_' (skip sentinel from redirect) — ignored for Firebase.
  Future<List<DestVideo>> fetchDestVideos(
      String catId, String subCatId, String subSubCatId) async {
    final snap = await _fs
        .collection('country')
        .doc(catId)
        .collection('countryCategory')
        .doc(subCatId)
        .collection('countryData')
        .orderBy('uploadedTime', descending: true)
        .get();
    return snap.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return DestVideo.fromJson(data);
    }).toList();
  }

  Future<List<CampusCourseItem>> fetchCourseItems(String catId) async {
    final snap = await _fs
        .collection('courseCategory')
        .doc(catId)
        .collection('data')
        .orderBy('uploadedTime', descending: true)
        .get();
    return snap.docs.map((doc) {
      final data = <String, dynamic>{'id': doc.id, ...doc.data()};
      return CampusCourseItem.fromJson(data);
    }).toList();
  }
}
