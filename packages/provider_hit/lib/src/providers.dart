import 'package:academic_api/academic_api.dart';

import 'hit_campus.dart';
import 'hit_campus_schedule.dart';
import 'shenzhen_auth_api.dart';
import 'shenzhen_timetable_api.dart';

const hitShenzhenProviderId = 'hit.shenzhen';
const hitHarbinProviderId = 'hit.harbin';
const hitWeihaiProviderId = 'hit.weihai';

List<AcademicProvider> createHitProviders({required HttpTransport transport}) {
  return <AcademicProvider>[
    HitShenzhenProvider(transport),
    const HitHarbinProvider(),
    const HitWeihaiProvider(),
  ];
}

class HitShenzhenProvider implements AcademicProvider {
  HitShenzhenProvider(HttpTransport transport)
    : _auth = ShenzhenAuthApi(transport),
      _timetable = ShenzhenTimetableApi(transport);

  final ShenzhenAuthApi _auth;
  final ShenzhenTimetableApi _timetable;

  @override
  String get id => hitShenzhenProviderId;

  @override
  AcademicProviderInfo get info => AcademicProviderInfo(
    displayName: '深圳校区',
    school: '哈尔滨工业大学（深圳）',
    campusLabel: '深圳校区',
    authMode: ProviderAuthMode.password,
    isAvailable: true,
    note: '使用深圳校区新版教务账号登录，会话仅保存在本机。',
    defaultSlots: HitCampusSchedule.forCampus(HitCampus.shenzhen),
  );

  @override
  Future<AuthResult> login(AuthRequest request) async {
    final result = await _auth.login(
      username: request.fields['username'] ?? '',
      password: request.fields['password'] ?? '',
    );
    return AuthResult(
      credentials: <String, String>{
        'accessToken': result.accessToken,
        if (result.refreshToken?.isNotEmpty == true)
          'refreshToken': result.refreshToken!,
      },
      cookies: result.cookies,
      profile: <String, String>{
        if (result.name?.isNotEmpty == true) 'name': result.name!,
        if (result.studentId?.isNotEmpty == true)
          'studentId': result.studentId!,
        if (result.school?.isNotEmpty == true) 'school': result.school!,
        'studentType': result.studentType.name,
        'studentTypeLabel': result.studentType.label,
      },
    );
  }

  @override
  Future<List<Term>> fetchTerms(AccountSession session) {
    return _timetable.fetchTerms(session);
  }

  @override
  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  }) {
    return _timetable.fetchSnapshot(session: session, term: term);
  }
}

class HitHarbinProvider implements AcademicProvider {
  const HitHarbinProvider();

  @override
  String get id => hitHarbinProviderId;

  @override
  AcademicProviderInfo get info => AcademicProviderInfo(
    displayName: '本部校区',
    school: '哈尔滨工业大学',
    campusLabel: '本部校区',
    authMode: ProviderAuthMode.webVpn,
    isAvailable: false,
    note: '本部教务使用 WebVPN 网页认证，当前版本暂未接入。',
    defaultSlots: HitCampusSchedule.forCampus(HitCampus.harbin),
  );

  @override
  Future<AuthResult> login(AuthRequest request) async {
    throw AuthException(info.note);
  }

  @override
  Future<List<Term>> fetchTerms(AccountSession session) async {
    throw ApiException(info.note);
  }

  @override
  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  }) async {
    throw ApiException(info.note);
  }
}

class HitWeihaiProvider implements AcademicProvider {
  const HitWeihaiProvider();

  @override
  String get id => hitWeihaiProviderId;

  @override
  AcademicProviderInfo get info => AcademicProviderInfo(
    displayName: '威海校区',
    school: '哈尔滨工业大学（威海）',
    campusLabel: '威海校区',
    authMode: ProviderAuthMode.webVpn,
    isAvailable: false,
    note: '威海教务使用 WebVPN 网页认证，当前版本暂未接入。',
    defaultSlots: HitCampusSchedule.forCampus(HitCampus.weihai),
  );

  @override
  Future<AuthResult> login(AuthRequest request) async {
    throw AuthException(info.note);
  }

  @override
  Future<List<Term>> fetchTerms(AccountSession session) async {
    throw ApiException(info.note);
  }

  @override
  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  }) async {
    throw ApiException(info.note);
  }
}
