import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/association_auth_datasource.dart';
import '../../data/models/association_session_model.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final _authDatasourceProvider = Provider<AssociationAuthDatasource>(
  (ref) => AssociationAuthDatasource(ref.watch(dioProvider)),
);

// ── Session state ─────────────────────────────────────────────────────────────

class AssociationSessionNotifier
    extends StateNotifier<Map<String, AssociationSessionModel>> {
  AssociationSessionNotifier(this._datasource) : super({}) {
    _loadFromPrefs();
  }

  final AssociationAuthDatasource _datasource;

  static const _prefPrefix = 'assoc_token_';
  static const _prefMemberId = 'assoc_member_id_';
  static const _prefMemberName = 'assoc_member_name_';
  static const _prefMemberEmail = 'assoc_member_email_';
  static const _prefMemberPhone = 'assoc_member_phone_';
  static const _prefMemberCity = 'assoc_member_city_';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final sessions = <String, AssociationSessionModel>{};
    for (final key in keys) {
      if (key.startsWith(_prefPrefix)) {
        final assocId = key.substring(_prefPrefix.length);
        final token = prefs.getString('$_prefPrefix$assocId');
        final memberId = prefs.getString('$_prefMemberId$assocId');
        if (token != null && token.isNotEmpty && memberId != null) {
          sessions[assocId] = AssociationSessionModel(
            token: token,
            memberId: memberId,
            associationId: assocId,
            memberName: prefs.getString('$_prefMemberName$assocId'),
            memberEmail: prefs.getString('$_prefMemberEmail$assocId'),
            memberPhone: prefs.getString('$_prefMemberPhone$assocId'),
            memberCity: prefs.getString('$_prefMemberCity$assocId'),
          );
        }
      }
    }
    state = sessions;
  }

  bool isSignedInTo(String associationId) =>
      state.containsKey(associationId);

  AssociationSessionModel? sessionFor(String associationId) =>
      state[associationId];

  Future<AssociationSessionModel> login({
    required String associationId,
    required String email,
    required String password,
  }) async {
    final data = await _datasource.login(
      associationId: associationId,
      email: email,
      password: password,
    );
    final token = data['token'] as String? ?? '';
    final memberRaw = data['member'];
    final member =
        memberRaw is Map<String, dynamic> ? memberRaw : <String, dynamic>{};

    final session = AssociationSessionModel.fromLoginResponse(
      token: token,
      associationId: associationId,
      member: member,
    );
    await _persist(session);
    state = {...state, associationId: session};
    return session;
  }

  Future<void> logout(String associationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefPrefix$associationId');
    await prefs.remove('$_prefMemberId$associationId');
    await prefs.remove('$_prefMemberName$associationId');
    await prefs.remove('$_prefMemberEmail$associationId');
    await prefs.remove('$_prefMemberPhone$associationId');
    await prefs.remove('$_prefMemberCity$associationId');
    final next = Map<String, AssociationSessionModel>.from(state);
    next.remove(associationId);
    state = next;
  }

  Future<void> forgotPassword({
    required String email,
    required String associationId,
  }) =>
      _datasource.forgotPassword(email: email, associationId: associationId);

  Future<void> _persist(AssociationSessionModel s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefPrefix${s.associationId}', s.token);
    await prefs.setString('$_prefMemberId${s.associationId}', s.memberId);
    if (s.memberName != null) {
      await prefs.setString('$_prefMemberName${s.associationId}', s.memberName!);
    }
    if (s.memberEmail != null) {
      await prefs.setString(
          '$_prefMemberEmail${s.associationId}', s.memberEmail!);
    }
    if (s.memberPhone != null) {
      await prefs.setString(
          '$_prefMemberPhone${s.associationId}', s.memberPhone!);
    }
    if (s.memberCity != null) {
      await prefs.setString(
          '$_prefMemberCity${s.associationId}', s.memberCity!);
    }
  }
}

final associationSessionProvider = StateNotifierProvider<
    AssociationSessionNotifier, Map<String, AssociationSessionModel>>(
  (ref) => AssociationSessionNotifier(ref.watch(_authDatasourceProvider)),
);
