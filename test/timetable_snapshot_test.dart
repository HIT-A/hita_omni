import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:academic_api/academic_api.dart';

void main() {
  final term = const Term(
    yearCode: '2024-2025',
    termCode: '1',
    name: '2024-2025 秋季学期',
    isCurrent: true,
  );
  final slots = <TimeSlot>[
    const TimeSlot(startMinute: 8 * 60, endMinute: 8 * 60 + 45),
    const TimeSlot(startMinute: 8 * 60 + 50, endMinute: 9 * 60 + 35),
    const TimeSlot(startMinute: 10 * 60, endMinute: 10 * 60 + 45),
    const TimeSlot(startMinute: 10 * 60 + 50, endMinute: 11 * 60 + 35),
  ];

  TimetableSnapshot buildSnapshot() {
    return TimetableSnapshot(
      term: term,
      startDate: DateTime(2024, 9, 2),
      slots: slots,
      courses: <Course>[
        Course(
          name: '高等数学',
          code: 'MATH1001',
          teacher: '张三',
          classroom: 'A101',
          weekday: DateTime.monday,
          startPeriod: 1,
          endPeriod: 2,
          weeks: const <int>[1, 2, 3],
        ),
        Course(
          name: '大学物理',
          weekday: DateTime.tuesday,
          startPeriod: 1,
          endPeriod: 1,
          weeks: const <int>[2],
        ),
        Course(
          name: '大学英语',
          weekday: DateTime.wednesday,
          startPeriod: 3,
          endPeriod: 3,
          weeks: const <int>[1],
        ),
      ],
      totalWeeks: 20,
      calendarVerified: true,
      fetchedAt: DateTime(2024, 9, 1, 12),
    );
  }

  test('computes teaching weeks from the Monday of week one', () {
    final snapshot = buildSnapshot();
    expect(snapshot.weekNumberFor(DateTime(2024, 9, 1)), 0);
    expect(snapshot.weekNumberFor(DateTime(2024, 9, 2)), 1);
    expect(snapshot.weekNumberFor(DateTime(2024, 9, 8)), 1);
    expect(snapshot.weekNumberFor(DateTime(2024, 9, 9)), 2);
    expect(snapshot.dateForWeekday(3, DateTime.friday), DateTime(2024, 9, 20));
  });

  test('filters courses by week and date', () {
    final snapshot = buildSnapshot();
    expect(
      snapshot.coursesOnDate(DateTime(2024, 9, 2)).map((course) => course.name),
      <String>['高等数学'],
    );
    expect(snapshot.coursesOnDate(DateTime(2024, 9, 3)), isEmpty);
    expect(
      snapshot
          .coursesOnDate(DateTime(2024, 9, 10))
          .map((course) => course.name),
      <String>['大学物理'],
    );
  });

  test('finds the ongoing or next lesson', () {
    final snapshot = buildSnapshot();
    final beforeClass = snapshot.nextOccurrence(DateTime(2024, 9, 2, 7));
    expect(beforeClass?.course.name, '高等数学');
    expect(beforeClass?.start, DateTime(2024, 9, 2, 8));

    final ongoing = snapshot.nextOccurrence(DateTime(2024, 9, 2, 8, 10));
    expect(ongoing?.course.name, '高等数学');
    expect(ongoing?.isOngoingAt(DateTime(2024, 9, 2, 8, 10)), isTrue);

    final afterMorning = snapshot.nextOccurrence(DateTime(2024, 9, 2, 9, 40));
    expect(afterMorning?.course.name, '大学英语');
    expect(afterMorning?.date, DateTime(2024, 9, 4));
  });

  test('compresses week ranges', () {
    expect(formatWeekRanges(<int>[1, 2, 3, 5, 8, 9]), '1-3, 5, 8-9');
    expect(formatWeekRanges(<int>[]), '');
  });

  test('merges duplicate and adjacent blocks only when weeks match', () {
    final merged = mergeCourses(<Course>[
      Course(
        name: '线性代数',
        weekday: DateTime.monday,
        startPeriod: 1,
        endPeriod: 1,
        weeks: const <int>[1],
      ),
      Course(
        name: '线性代数',
        weekday: DateTime.monday,
        startPeriod: 2,
        endPeriod: 2,
        weeks: const <int>[1],
      ),
      Course(
        name: '线性代数',
        weekday: DateTime.monday,
        startPeriod: 3,
        endPeriod: 3,
        weeks: const <int>[2],
      ),
    ]);
    expect(merged, hasLength(2));
    expect(merged.first.startPeriod, 1);
    expect(merged.first.endPeriod, 2);
    expect(merged.first.weeks, <int>[1]);
    expect(merged.last.weeks, <int>[2]);
  });

  test('round-trips the snapshot cache', () {
    final snapshot = buildSnapshot();
    final decoded = jsonDecode(jsonEncode(snapshot.toJson()));
    final restored = TimetableSnapshot.fromJson(
      decoded as Map<String, dynamic>,
    );
    expect(restored.term.id, snapshot.term.id);
    expect(restored.startDate, snapshot.startDate);
    expect(restored.courses.length, snapshot.courses.length);
    expect(restored.courses.first.weeks, <int>[1, 2, 3]);
    expect(restored.calendarVerified, isTrue);
  });
}
