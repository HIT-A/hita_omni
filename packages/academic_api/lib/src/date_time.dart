DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime startOfWeek(DateTime value) {
  final day = dateOnly(value);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

int daysBetween(DateTime from, DateTime to) {
  return dateOnly(to).difference(dateOnly(from)).inDays;
}

String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatClock(int minutesSinceMidnight) {
  final normalized = minutesSinceMidnight % (24 * 60);
  return '${twoDigits(normalized ~/ 60)}:${twoDigits(normalized % 60)}';
}

/// Compacts week numbers: `[1,2,3,5,8,9]` becomes `1-3, 5, 8-9`.
/// Returns an empty string when the list has no positive week.
String formatWeekRanges(Iterable<int> weeks) {
  final sorted = weeks.where((week) => week > 0).toSet().toList()..sort();
  if (sorted.isEmpty) {
    return '';
  }
  final parts = <String>[];
  var start = sorted.first;
  var previous = sorted.first;
  for (final week in sorted.skip(1)) {
    if (week == previous + 1) {
      previous = week;
      continue;
    }
    parts.add(_weekPart(start, previous));
    start = week;
    previous = week;
  }
  parts.add(_weekPart(start, previous));
  return parts.join(', ');
}

String _weekPart(int start, int end) {
  return start == end ? '$start' : '$start-$end';
}
