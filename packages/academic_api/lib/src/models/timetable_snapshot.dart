import '../date_time.dart';
import 'course.dart';
import 'term.dart';
import 'time_slot.dart';

class CourseOccurrence {
  const CourseOccurrence({
    required this.course,
    required this.date,
    required this.start,
    required this.end,
  });

  final Course course;
  final DateTime date;
  final DateTime start;
  final DateTime end;

  bool isOngoingAt(DateTime now) => !now.isBefore(start) && now.isBefore(end);

  bool isFinishedAt(DateTime now) => !now.isBefore(end);

  String get timeLabel =>
      '${formatClock(start.hour * 60 + start.minute)} - '
      '${formatClock(end.hour * 60 + end.minute)}';
}

class TimetableSnapshot {
  TimetableSnapshot({
    required this.term,
    required DateTime startDate,
    required List<TimeSlot> slots,
    required List<Course> courses,
    required this.totalWeeks,
    required this.calendarVerified,
    required this.fetchedAt,
  }) : startDate = dateOnly(startDate),
       slots = List<TimeSlot>.unmodifiable(slots),
       courses = List<Course>.unmodifiable(mergeCourses(courses));

  final Term term;
  final DateTime startDate;
  final List<TimeSlot> slots;
  final List<Course> courses;
  final int totalWeeks;
  final bool calendarVerified;
  final DateTime fetchedAt;

  int weekNumberFor(DateTime date) {
    final difference = daysBetween(startDate, date);
    if (difference < 0) {
      return 0;
    }
    return difference ~/ 7 + 1;
  }

  DateTime dateForWeekday(int week, int weekday) {
    return startDate.add(
      Duration(days: (week - 1) * 7 + (weekday - DateTime.monday)),
    );
  }

  TimeSlot? slotForPeriod(int period) {
    final index = period - 1;
    if (index < 0 || index >= slots.length) {
      return null;
    }
    return slots[index];
  }

  String timeLabelForCourse(Course course) {
    final first = slotForPeriod(course.startPeriod);
    final last = slotForPeriod(course.endPeriod);
    if (first == null || last == null) {
      return '第 ${course.startPeriod}-${course.endPeriod} 节';
    }
    return '${first.startLabel} - ${last.endLabel}';
  }

  List<Course> coursesForWeek(int week) {
    return <Course>[
      for (final course in courses)
        if (course.occursInWeek(week)) course,
    ];
  }

  List<Course> coursesOnDate(DateTime date) {
    final week = weekNumberFor(date);
    if (week < 1 || week > totalWeeks) {
      return const <Course>[];
    }
    return <Course>[
      for (final course in coursesForWeek(week))
        if (course.weekday == date.weekday) course,
    ];
  }

  List<CourseOccurrence> occurrencesOn(DateTime date) {
    final occurrences = <CourseOccurrence>[];
    for (final course in coursesOnDate(date)) {
      final occurrence = _occurrenceFor(course, date);
      if (occurrence != null) {
        occurrences.add(occurrence);
      }
    }
    occurrences.sort((a, b) => a.start.compareTo(b.start));
    return occurrences;
  }

  /// Returns the lesson that is currently running or the next one within
  /// [lookaheadDays]. Courses that already ended are skipped.
  CourseOccurrence? nextOccurrence(DateTime now, {int lookaheadDays = 14}) {
    final today = dateOnly(now);
    for (var offset = 0; offset <= lookaheadDays; offset++) {
      final date = today.add(Duration(days: offset));
      final week = weekNumberFor(date);
      if (week < 1 || week > totalWeeks) {
        continue;
      }
      for (final occurrence in occurrencesOn(date)) {
        if (occurrence.end.isAfter(now)) {
          return occurrence;
        }
      }
    }
    return null;
  }

  CourseOccurrence? _occurrenceFor(Course course, DateTime date) {
    final first = slotForPeriod(course.startPeriod);
    final last = slotForPeriod(course.endPeriod);
    if (first == null || last == null) {
      return null;
    }
    final day = dateOnly(date);
    final start = day.add(Duration(minutes: first.startMinute));
    final end = day.add(Duration(minutes: last.endMinute));
    if (!end.isAfter(start)) {
      return null;
    }
    return CourseOccurrence(course: course, date: day, start: start, end: end);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'term': term.toJson(),
    'startDate': startDate.toIso8601String(),
    'slots': <Map<String, dynamic>>[for (final slot in slots) slot.toJson()],
    'courses': <Map<String, dynamic>>[
      for (final course in courses) course.toJson(),
    ],
    'totalWeeks': totalWeeks,
    'calendarVerified': calendarVerified,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory TimetableSnapshot.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    final rawCourses = json['courses'];
    final fetchedAt = DateTime.tryParse(json['fetchedAt'] as String? ?? '');
    final startDate = DateTime.tryParse(json['startDate'] as String? ?? '');
    return TimetableSnapshot(
      term: Term.fromJson(
        json['term'] is Map<String, dynamic>
            ? json['term'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      startDate: startDate ?? DateTime(2000),
      slots: rawSlots is List
          ? <TimeSlot>[
              for (final item in rawSlots)
                if (item is Map<String, dynamic>) TimeSlot.fromJson(item),
            ]
          : const <TimeSlot>[],
      courses: rawCourses is List
          ? <Course>[
              for (final item in rawCourses)
                if (item is Map<String, dynamic>) Course.fromJson(item),
            ]
          : const <Course>[],
      totalWeeks: (json['totalWeeks'] as num?)?.toInt() ?? 20,
      calendarVerified: json['calendarVerified'] as bool? ?? false,
      fetchedAt: fetchedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
