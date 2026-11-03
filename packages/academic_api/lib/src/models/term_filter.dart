import 'term.dart';

/// Selects the terms shown for the timetable and future score/exam views.
///
/// This mirrors HITA Android's `filterTermsForTimetableImport`:
/// - a known enrollment year keeps every term from that academic year onward,
///   including future terms exposed by the academic system;
/// - without an enrollment year, only the most recent four calendar years are
///   considered;
/// - if filtering removes everything, the raw list is shown instead;
/// - the result is newest-first and deduplicated by [Term.id].
abstract final class TermFilter {
  static List<Term> forTimetableAndAssessment(
    Iterable<Term> terms, {
    String? grade,
    String? studentId,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final enrollmentYear =
        enrollmentYearFromGrade(grade) ??
        enrollmentYearFromStudentId(studentId, now: current);
    final cutoffYear = enrollmentYear ?? current.year - 3;
    final filtered = <Term>[
      for (final term in terms)
        if (startYear(term.yearCode) case final year? when year >= cutoffYear)
          term,
    ];
    return _sortAndDedupe(filtered.isEmpty ? terms : filtered);
  }

  static int? enrollmentYearFromGrade(String? grade) {
    final match = RegExp(r'(20\d{2})').firstMatch(grade ?? '');
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static int? enrollmentYearFromStudentId(String? studentId, {DateTime? now}) {
    final prefix = studentId?.trim().take(4);
    final year = int.tryParse(prefix ?? '');
    if (year == null) {
      return null;
    }
    final currentYear = (now ?? DateTime.now()).year;
    if (year < 2000 || year > currentYear + 1) {
      return null;
    }
    return year;
  }

  static int? startYear(String value) {
    final match = RegExp(r'(20\d{2})').firstMatch(value.trim());
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static List<Term> _sortAndDedupe(Iterable<Term> terms) {
    final byId = <String, Term>{};
    for (final term in terms) {
      byId.putIfAbsent(term.id, () => term);
    }
    final result = byId.values.toList()
      ..sort((left, right) {
        final leftYear = startYear(left.yearCode) ?? -1;
        final rightYear = startYear(right.yearCode) ?? -1;
        final yearComparison = rightYear.compareTo(leftYear);
        if (yearComparison != 0) {
          return yearComparison;
        }
        final leftTerm = int.tryParse(left.termCode) ?? -1;
        final rightTerm = int.tryParse(right.termCode) ?? -1;
        return rightTerm.compareTo(leftTerm);
      });
    return List<Term>.unmodifiable(result);
  }
}

extension on String {
  String take(int count) => length <= count ? this : substring(0, count);
}
