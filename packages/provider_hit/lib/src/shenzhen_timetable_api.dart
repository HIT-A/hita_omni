import 'dart:math';

import 'package:academic_api/academic_api.dart';

import 'hit_campus.dart';
import 'hit_campus_schedule.dart';

const _baseUrl = 'https://mjw.hitsz.edu.cn/incoSpringBoot';
const _userAgent =
    'Mozilla/5.0 (Linux; Android 15; V2182A Build/AP3A.240905.015.A2; wv) '
    'AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 '
    'Chrome/144.0.7559.132 Mobile Safari/537.36 uni-app Html5Plus/1.0';
const _weekCount = 25;

const _teacherKeys = <String>[
  'SKJS',
  'JSXM',
  'RKJS',
  'JS',
  'JSMC',
  'JSMC1',
  'JSMC2',
  'DGJSMC',
  'dgjsmc',
  'SKJSXM',
  'SKJSMC',
  'SKJSXX',
  'skjs',
  'skjsxm',
  'skjsmc',
  'skjsxx',
  'jsxm',
  'jsmc',
  'rkjs',
  'js',
  'teacher',
  'Teacher',
];

const _selectedTeacherKeys = <String>[
  'DGJSMC',
  'dgjsmc',
  'SKJS',
  'SKJSXM',
  'SKJSMC',
  'SKJSXX',
  'JSXM',
  'JSMC',
  'RKJS',
  'JS',
  'skjs',
  'skjsxm',
  'skjsmc',
  'skjsxx',
  'jsxm',
  'jsmc',
  'rkjs',
  'js',
  'teacher',
  'Teacher',
];

String _firstString(Map<String, dynamic> json, Iterable<String> keys) {
  for (final key in keys) {
    final value = _scalarString(json[key]).trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

String _scalarString(Object? value) {
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is List) {
    return value
        .map(_scalarString)
        .where((item) => item.trim().isNotEmpty)
        .join(' / ');
  }
  if (value is Map) {
    for (final key in const <String>[
      'xm',
      'XM',
      'name',
      'NAME',
      'jsxm',
      'JSXM',
      'value',
    ]) {
      final text = _scalarString(value[key]).trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
  }
  return '';
}

String _normalizeCode(String raw) {
  final value = raw.trim();
  final match = RegExp(r'([A-Za-z]{4}\d{4})').firstMatch(value);
  return match?.group(1) ?? value;
}

String _nameKey(String value) => value.replaceAll(RegExp(r'\s+'), '').trim();

String _baseCourseName(String name) {
  final bracket = name.indexOf('[');
  return bracket > 0 ? name.substring(0, bracket).trim() : name;
}

class ShenzhenTimetableApi {
  ShenzhenTimetableApi(this._transport, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final HttpTransport _transport;
  final DateTime Function() _now;

  HitStudentType _studentType(AccountSession session) {
    return HitStudentType.fromName(session.profile['studentType']);
  }

  ApiClient _client(AccountSession session) {
    return ApiClient(
      transport: _transport,
      baseUri: Uri.parse(_baseUrl),
      cookies: CookieJar(session.cookies),
      timeout: const Duration(seconds: 25),
    );
  }

  Map<String, String> _headers(
    AccountSession session, {
    String roleCode = '06',
  }) => <String, String>{
    'authorization': 'bearer ${session.credentials['accessToken'] ?? ''}',
    'rolecode': roleCode,
    '_lang': 'cn',
    'Connection': 'keep-alive',
    'User-Agent': _userAgent,
  };

  Future<List<Term>> fetchTerms(AccountSession session) async {
    final client = _client(session);
    final response = await client.postForm(
      '/app/commapp/queryxnxqlist',
      headers: _headers(session),
    );
    _ensureAuthenticated(response);
    final json = decodeJsonObject(response.body);
    if (json == null) {
      throw ApiFormatException('学期列表解析失败');
    }
    final items = jsonObjects(json['content']);
    final terms = <Term>[];
    for (final item in items) {
      final yearCode = jsonString(item, 'XN').trim();
      final termCode = jsonString(item, 'XQ').trim();
      if (yearCode.isEmpty || termCode.isEmpty) {
        continue;
      }
      final rawName = jsonString(item, 'XNXQMC').trim();
      final name = rawName.isEmpty
          ? '$yearCode ${Term.semesterName(termCode)}'
          : rawName;
      terms.add(
        Term(
          yearCode: yearCode,
          termCode: termCode,
          name: name,
          isCurrent: jsonString(item, 'SFDQXQ').trim() == '1',
        ),
      );
    }
    if (terms.isEmpty) {
      throw ApiException('未获取到学期列表');
    }
    return terms;
  }

  Future<TimetableSnapshot> fetchSnapshot({
    required AccountSession session,
    required Term term,
  }) async {
    final client = _client(session);
    final weeks = await _mapConcurrent<int, _WeekData>(
      List<int>.generate(_weekCount, (index) => index + 1),
      6,
      (week) => _fetchWeek(session, term, week, client),
    );

    final rawCourses = <Course>[for (final week in weeks) ...week.courses];
    final needsTeacher = rawCourses.any(
      (course) => course.teacher?.trim().isEmpty ?? true,
    );
    final teacherMap = needsTeacher
        ? await _fetchTeacherMap(session, term)
        : const <String, String>{};
    final courses = <Course>[
      for (final course in rawCourses) _withTeacher(course, teacherMap),
    ];
    final normalizedCourses = mergeCourses(courses);

    DateTime? firstTeachingDate;
    final firstWeek = weeks.isEmpty ? null : weeks.first;
    if (firstWeek != null && firstWeek.dates.isNotEmpty) {
      firstTeachingDate = _parseDate(firstWeek.dates.first);
    }

    final calendarVerified = firstTeachingDate != null;
    final startDate = firstTeachingDate == null
        ? startOfWeek(_now())
        : startOfWeek(firstTeachingDate);

    final maxCourseWeek = normalizedCourses
        .expand((course) => course.weeks)
        .fold<int>(0, max);
    final totalWeeks = max(20, maxCourseWeek).clamp(1, _weekCount).toInt();

    return TimetableSnapshot(
      term: term,
      startDate: startDate,
      slots: HitCampusSchedule.forCampus(
        HitCampus.shenzhen,
        studentType: _studentType(session),
      ),
      courses: normalizedCourses,
      totalWeeks: totalWeeks,
      calendarVerified: calendarVerified,
      fetchedAt: _now(),
    );
  }

  Future<_WeekData> _fetchWeek(
    AccountSession session,
    Term term,
    int week,
    ApiClient client,
  ) async {
    final response = await client.postJson(
      '/app/Kbcx/query',
      body: <String, dynamic>{
        'xn': term.yearCode,
        'xq': term.termCode,
        'zc': '$week',
        'type': 'json',
      },
      headers: _headers(session),
    );
    _ensureAuthenticated(response);
    final json = decodeJsonObject(response.body);
    if (json == null) {
      throw ApiFormatException('第 $week 周课表解析失败');
    }
    final code = jsonInt(json, 'code', 200);
    if (code != 200) {
      final message = jsonString(json, 'msg');
      throw ApiException(
        message.isEmpty ? '第 $week 周课表获取失败' : message,
        statusCode: code,
      );
    }
    final parsed = parseShenzhenWeek(json, week);
    return _WeekData(courses: parsed.courses, dates: parsed.dates);
  }

  void _ensureAuthenticated(HttpResponseData response) {
    if (isAuthFailure(response.statusCode, response.body)) {
      throw AuthExpiredException();
    }
    final body = response.body;
    if (body.trimLeft().startsWith('<') &&
        (body.contains('登录') || body.contains('统一身份认证'))) {
      throw AuthExpiredException();
    }
  }

  Future<Map<String, String>> _fetchTeacherMap(
    AccountSession session,
    Term term,
  ) async {
    try {
      final client = _client(session);
      final studentCode = _studentType(session) == HitStudentType.undergraduate
          ? '1'
          : '2';
      final studentTypes = <String>{studentCode, studentCode.padLeft(2, '0')};
      final termCodes = <String>{
        '${term.yearCode}${term.termCode}',
        '${term.yearCode}-${term.termCode}',
        '${term.yearCode}${term.termCode.padLeft(2, '0')}',
        '${term.yearCode}-${term.termCode.padLeft(2, '0')}',
      };
      final deadline = DateTime.now().add(const Duration(seconds: 12));
      for (final role in const <String>['06', '01']) {
        for (final studentType in studentTypes) {
          for (final termCode in termCodes) {
            for (final mode in const <String>['yixuan', '']) {
              if (DateTime.now().isAfter(deadline)) {
                return const <String, String>{};
              }
              final response = await client.postJson(
                '/app/Xsxk/queryYxkc?_lang=zh_CN',
                headers: _headers(session, roleCode: role),
                body: <String, dynamic>{
                  'RoleCode': role,
                  'p_pylx': studentType,
                  'p_xn': term.yearCode,
                  'p_xq': term.termCode,
                  'p_xnxq': termCode,
                  'p_gjz': '',
                  'p_kc_gjz': '',
                  'p_xkfsdm': mode,
                },
                timeout: const Duration(seconds: 8),
              );
              if (isAuthFailure(response.statusCode, response.body)) {
                return const <String, String>{};
              }
              final json = decodeJsonObject(response.body);
              if (json == null) {
                continue;
              }
              final teachers = parseShenzhenTeacherMap(json);
              if (teachers.isNotEmpty) {
                return teachers;
              }
              // A valid selected-course payload without teachers is not
              // improved by retrying other body variants.
              if (_selectedSubjectItems(json).isNotEmpty) {
                return const <String, String>{};
              }
            }
          }
        }
      }
    } catch (_) {
      // Teacher enrichment is optional; do not fail the timetable sync.
    }
    return const <String, String>{};
  }

  Future<List<R>> _mapConcurrent<T, R>(
    List<T> items,
    int limit,
    Future<R> Function(T item) action,
  ) async {
    final results = List<R?>.filled(items.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex;
        if (index >= items.length) {
          return;
        }
        nextIndex = index + 1;
        results[index] = await action(items[index]);
      }
    }

    await Future.wait<void>(
      List<Future<void>>.generate(min(limit, items.length), (_) => worker()),
    );
    return <R>[for (final result in results) result as R];
  }
}

class ShenzhenWeekData {
  const ShenzhenWeekData({required this.courses, required this.dates});

  final List<Course> courses;
  final List<String> dates;
}

ShenzhenWeekData parseShenzhenWeek(Map<String, dynamic> json, int week) {
  final content = jsonObjects(json['content']);
  final courses = <Course>[];
  final dates = <String>[];

  for (final section in content) {
    final rawDates = section['rqList'];
    if (rawDates is List) {
      for (final rawDate in rawDates) {
        if (rawDate is Map<String, dynamic>) {
          final date = jsonString(rawDate, 'RQ').trim();
          if (date.isNotEmpty) {
            dates.add(date);
          }
        }
      }
    }
    final rawCourses = section['kcxxList'];
    if (rawCourses is! List) {
      continue;
    }
    for (final rawCourse in rawCourses) {
      if (rawCourse is! Map<String, dynamic>) {
        continue;
      }
      final course = _parseCourse(rawCourse, week);
      if (course != null) {
        courses.add(course);
      }
    }
  }

  return ShenzhenWeekData(courses: courses, dates: dates);
}

Course? _parseCourse(Map<String, dynamic> json, int week) {
  final weekday = jsonInt(json, 'XQJ');
  final startPeriod = jsonInt(json, 'KSJC');
  final rawEndPeriod = jsonInt(json, 'JSJC', startPeriod);
  if (weekday < 1 || weekday > 7 || startPeriod <= 0) {
    return null;
  }
  final endPeriod = rawEndPeriod >= startPeriod ? rawEndPeriod : startPeriod;
  final kbxx = jsonString(json, 'KBXX');
  final fallbackName = _fallbackName(kbxx);
  final preferredName = jsonString(json, 'KCMC').trim();
  final englishName = jsonString(json, 'KCMC_EN').trim();
  final baseName = preferredName.isNotEmpty
      ? preferredName
      : englishName.isNotEmpty
      ? englishName
      : fallbackName;
  if (baseName.isEmpty) {
    return null;
  }
  final sessionHint = _sessionHint(kbxx, baseName);
  final name = sessionHint == null || baseName.contains(sessionHint)
      ? baseName
      : '$baseName [$sessionHint]';

  final rawCode = _firstString(json, const <String>['KCDM', 'kcdm']);
  final normalizedCode = _normalizeCode(rawCode);
  final code = normalizedCode.isEmpty ? null : normalizedCode;

  return Course(
    name: name,
    code: code,
    teacher: _teacher(json, kbxx, baseName),
    classroom: _classroom(kbxx),
    weekday: weekday,
    startPeriod: startPeriod,
    endPeriod: endPeriod,
    weeks: <int>[week],
  );
}

String _fallbackName(String kbxx) {
  final firstLine = kbxx
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');
  return firstLine.replaceAll(RegExp(r'\[[^\]]*]'), '').trim();
}

String? _sessionHint(String kbxx, String courseName) {
  final firstLine = kbxx
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');
  for (final match in RegExp(r'\[([^\]]+)]').allMatches(firstLine)) {
    final value = match.group(1)?.trim();
    if (value == null || value.isEmpty) {
      continue;
    }
    final cleaned = value.replaceFirst(RegExp(r'[.．]$'), '').trim();
    if (cleaned.isEmpty ||
        cleaned.contains('周') ||
        cleaned.contains('节') ||
        cleaned.toLowerCase().contains('week') ||
        _looksLikeClassroom(cleaned) ||
        courseName.contains(cleaned)) {
      continue;
    }
    return cleaned;
  }
  return null;
}

String? _classroom(String kbxx) {
  for (final match in RegExp(r'\[([^\]]+)]').allMatches(kbxx)) {
    final value = match.group(1)?.trim();
    if (value != null && _looksLikeClassroom(value)) {
      return value;
    }
  }
  return null;
}

bool _looksLikeClassroom(String value) {
  if (value.contains('楼') ||
      value.contains('馆') ||
      value.contains('场') ||
      value.contains('室') ||
      value.contains('教室') ||
      value.contains('实验室') ||
      value.contains('中心') ||
      value.contains('基地')) {
    return true;
  }
  if (RegExp(r'^[A-Za-z]\d{2,}.*$').hasMatch(value)) {
    return true;
  }
  return RegExp(r'^[TGHKAtghka]?\d{3,}.*$').hasMatch(value);
}

Map<String, String> parseShenzhenTeacherMap(Map<String, dynamic> json) {
  final teachers = <String, String>{};
  for (final item in _selectedSubjectItems(json)) {
    final teacher = _firstString(item, _selectedTeacherKeys);
    if (teacher.isEmpty) {
      continue;
    }
    final rawCode = _firstString(item, const <String>['KCDM', 'kcdm']);
    final normalizedCode = _normalizeCode(rawCode);
    if (normalizedCode.isNotEmpty) {
      teachers[normalizedCode] = teacher;
    }
    if (rawCode.isNotEmpty) {
      teachers[rawCode] = teacher;
    }
    final nameKey = _nameKey(
      _firstString(item, const <String>['KCMC', 'kcmc']),
    );
    if (nameKey.isNotEmpty) {
      teachers[nameKey] = teacher;
    }
  }
  return teachers;
}

List<Map<String, dynamic>> _selectedSubjectItems(Map<String, dynamic> json) {
  for (final key in const <String>[
    'yxkcList',
    'content',
    'data',
    'rows',
    'list',
  ]) {
    final items = _itemsFromValue(json[key]);
    if (items.isNotEmpty) {
      return items;
    }
  }
  return const <Map<String, dynamic>>[];
}

List<Map<String, dynamic>> _itemsFromValue(Object? value, [int depth = 0]) {
  if (depth > 3) {
    return const <Map<String, dynamic>>[];
  }
  if (value is List) {
    final items = <Map<String, dynamic>>[
      for (final item in value)
        if (item is Map<String, dynamic>) item,
    ];
    return _looksLikeSubjects(items) ? items : const <Map<String, dynamic>>[];
  }
  if (value is Map<String, dynamic>) {
    for (final key in const <String>[
      'yxkcList',
      'content',
      'data',
      'rows',
      'list',
    ]) {
      final items = _itemsFromValue(value[key], depth + 1);
      if (items.isNotEmpty) {
        return items;
      }
    }
  }
  return const <Map<String, dynamic>>[];
}

bool _looksLikeSubjects(List<Map<String, dynamic>> items) {
  const keys = <String>{
    'kcmc',
    'KCMC',
    'kcdm',
    'KCDM',
    'dgjsmc',
    'DGJSMC',
    'skjs',
    'SKJS',
    'jsxm',
    'JSXM',
  };
  for (final item in items) {
    if (item.keys.any(keys.contains)) {
      return true;
    }
  }
  return false;
}

Course _withTeacher(Course course, Map<String, String> teachers) {
  if (teachers.isEmpty || (course.teacher?.trim().isNotEmpty ?? false)) {
    return course;
  }
  final normalizedCode = course.code == null
      ? ''
      : _normalizeCode(course.code!);
  final keys = <String>{
    if (normalizedCode.isNotEmpty) normalizedCode,
    if (course.code?.trim().isNotEmpty ?? false) course.code!.trim(),
    _nameKey(course.name),
    _nameKey(_baseCourseName(course.name)),
  };
  for (final key in keys) {
    final teacher = teachers[key]?.trim();
    if (teacher != null && teacher.isNotEmpty) {
      return course.copyWith(teacher: teacher);
    }
  }
  return course;
}

String? _teacher(Map<String, dynamic> json, String kbxx, String courseName) {
  final structured = _firstString(json, _teacherKeys);
  if (structured.isNotEmpty) {
    return structured;
  }
  final normalizedCourseName = _nameKey(courseName);
  final lines = kbxx
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .where((line) => !(line.contains('[') && line.contains(']')))
      .where((line) => _nameKey(line) != normalizedCourseName)
      .toList();
  if (lines.isEmpty) {
    return null;
  }
  final teacher = lines
      .join(' / ')
      .replaceFirst(RegExp(r'^(教师|老师|Teacher)[:： ]*'), '')
      .trim();
  return teacher.isEmpty ? null : teacher;
}

DateTime? _parseDate(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return null;
  }
  return dateOnly(parsed);
}

final class _WeekData {
  const _WeekData({required this.courses, required this.dates});

  final List<Course> courses;
  final List<String> dates;
}
