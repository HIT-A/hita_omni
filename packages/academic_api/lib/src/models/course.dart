class Course {
  Course({
    required this.name,
    required this.weekday,
    required this.startPeriod,
    required this.endPeriod,
    required List<int> weeks,
    this.code,
    this.teacher,
    this.classroom,
  }) : weeks = List<int>.unmodifiable(_normalizeWeeks(weeks)),
       assert(weekday >= DateTime.monday && weekday <= DateTime.sunday),
       assert(startPeriod > 0),
       assert(endPeriod >= startPeriod);

  final String? code;
  final String name;
  final String? teacher;
  final String? classroom;

  /// 1 = Monday, 7 = Sunday.
  final int weekday;

  /// 1-based period indexes into the timetable slot list.
  final int startPeriod;
  final int endPeriod;
  final List<int> weeks;

  int get span => endPeriod - startPeriod + 1;

  String get displayTeacher =>
      teacher?.trim().isNotEmpty == true ? teacher! : '';

  String get displayClassroom =>
      classroom?.trim().isNotEmpty == true ? classroom! : '';

  bool occursInWeek(int week) => weeks.contains(week);

  Course copyWith({
    String? code,
    String? name,
    String? teacher,
    String? classroom,
    int? weekday,
    int? startPeriod,
    int? endPeriod,
    List<int>? weeks,
  }) {
    return Course(
      code: code ?? this.code,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      weekday: weekday ?? this.weekday,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      weeks: weeks ?? this.weeks,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'name': name,
    'teacher': teacher,
    'classroom': classroom,
    'weekday': weekday,
    'startPeriod': startPeriod,
    'endPeriod': endPeriod,
    'weeks': weeks,
  };

  factory Course.fromJson(Map<String, dynamic> json) {
    final rawWeeks = json['weeks'];
    return Course(
      code: json['code'] as String?,
      name: json['name'] as String? ?? '未命名课程',
      teacher: json['teacher'] as String?,
      classroom: json['classroom'] as String?,
      weekday: (json['weekday'] as num?)?.toInt() ?? DateTime.monday,
      startPeriod: (json['startPeriod'] as num?)?.toInt() ?? 1,
      endPeriod: (json['endPeriod'] as num?)?.toInt() ?? 1,
      weeks: rawWeeks is List
          ? <int>[
              for (final week in rawWeeks)
                if (week is num) week.toInt(),
            ]
          : const <int>[],
    );
  }
}

List<int> _normalizeWeeks(Iterable<int> weeks) {
  return weeks.where((week) => week > 0).toSet().toList()..sort();
}

/// Merges blocks that describe the same weekly lesson and joins adjacent
/// blocks that share the exact same week set.
List<Course> mergeCourses(Iterable<Course> courses) {
  final grouped = <String, Course>{};
  for (final course in courses) {
    final key = _blockIdentity(course);
    final existing = grouped[key];
    if (existing == null) {
      grouped[key] = course;
      continue;
    }
    final existingCode = existing.code?.trim();
    final incomingCode = course.code?.trim();
    grouped[key] = existing.copyWith(
      code: existingCode == null || existingCode.isEmpty
          ? incomingCode
          : existing.code,
      weeks: _normalizeWeeks(<int>{...existing.weeks, ...course.weeks}),
    );
  }

  final sorted = grouped.values.toList()
    ..sort((a, b) {
      final weekday = a.weekday.compareTo(b.weekday);
      if (weekday != 0) {
        return weekday;
      }
      final start = a.startPeriod.compareTo(b.startPeriod);
      if (start != 0) {
        return start;
      }
      return a.name.compareTo(b.name);
    });

  final merged = <Course>[];
  for (final course in sorted) {
    if (merged.isNotEmpty) {
      final previous = merged.last;
      final sameWeeks =
          previous.weeks.length == course.weeks.length &&
          previous.weeks.every(course.weeks.contains);
      if (previous.weekday == course.weekday &&
          previous.endPeriod + 1 == course.startPeriod &&
          sameWeeks &&
          _sameLesson(previous, course)) {
        merged[merged.length - 1] = previous.copyWith(
          endPeriod: course.endPeriod,
        );
        continue;
      }
    }
    merged.add(course);
  }
  return merged;
}

String _blockIdentity(Course course) {
  return <String>[
    course.name.trim(),
    course.weekday.toString(),
    course.startPeriod.toString(),
    course.endPeriod.toString(),
    course.teacher?.trim() ?? '',
    course.classroom?.trim() ?? '',
  ].join('|');
}

bool _sameLesson(Course left, Course right) {
  return left.name.trim() == right.name.trim() &&
      (left.teacher?.trim() ?? '') == (right.teacher?.trim() ?? '') &&
      (left.classroom?.trim() ?? '') == (right.classroom?.trim() ?? '');
}
