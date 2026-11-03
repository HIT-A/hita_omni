import 'package:academic_api/academic_api.dart';
import 'package:flutter_test/flutter_test.dart';

Term _term(String yearCode, String termCode) {
  return Term(
    yearCode: yearCode,
    termCode: termCode,
    name: '$yearCode 学期 $termCode',
  );
}

void main() {
  final now = DateTime(2026, 10, 25);

  test('enrollment year keeps current and future terms, newest first', () {
    final filtered = TermFilter.forTimetableAndAssessment(
      <Term>[
        _term('2022-2023', '2'),
        _term('2023-2024', '1'),
        _term('2024-2025', '2'),
        _term('2025-2026', '1'),
        _term('2026-2027', '1'),
        _term('2027-2028', '1'),
      ],
      grade: '2023级',
      now: now,
    );

    expect(filtered.map((term) => term.id), <String>[
      '2027-2028-1',
      '2026-2027-1',
      '2025-2026-1',
      '2024-2025-2',
      '2023-2024-1',
    ]);
  });

  test('student ID supplies the enrollment year when grade is absent', () {
    final filtered = TermFilter.forTimetableAndAssessment(
      <Term>[
        _term('2023-2024', '1'),
        _term('2024-2025', '2'),
        _term('2025-2026', '1'),
      ],
      studentId: '2024123456',
      now: now,
    );

    expect(filtered.map((term) => term.id), <String>[
      '2025-2026-1',
      '2024-2025-2',
    ]);
  });

  test('no enrollment info falls back to the recent four years', () {
    final filtered = TermFilter.forTimetableAndAssessment(<Term>[
      _term('2022-2023', '1'),
      _term('2023-2024', '1'),
      _term('2025-2026', '1'),
    ], now: now);

    expect(filtered.map((term) => term.id), <String>[
      '2025-2026-1',
      '2023-2024-1',
    ]);
  });

  test('an empty filtered result falls back to the raw list', () {
    final filtered = TermFilter.forTimetableAndAssessment(<Term>[
      _term('2010-2011', '1'),
      _term('2011-2012', '1'),
    ], now: now);

    expect(filtered.map((term) => term.id), <String>[
      '2011-2012-1',
      '2010-2011-1',
    ]);
  });

  test('deduplicates by term ID and sorts term codes newest first', () {
    final filtered = TermFilter.forTimetableAndAssessment(
      <Term>[
        _term('2025-2026', '1'),
        _term('2025-2026', '2'),
        _term('2025-2026', '1'),
      ],
      grade: '2023级',
      now: now,
    );

    expect(filtered.map((term) => term.id), <String>[
      '2025-2026-2',
      '2025-2026-1',
    ]);
  });
}
