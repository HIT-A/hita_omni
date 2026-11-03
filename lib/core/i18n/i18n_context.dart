import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../utils/date_time.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsHelpers on AppLocalizations {
  String weekday(int weekday, {bool short = false}) {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      return '';
    }
    if (short) {
      return switch (weekday) {
        DateTime.monday => dateWeekdayShort1,
        DateTime.tuesday => dateWeekdayShort2,
        DateTime.wednesday => dateWeekdayShort3,
        DateTime.thursday => dateWeekdayShort4,
        DateTime.friday => dateWeekdayShort5,
        DateTime.saturday => dateWeekdayShort6,
        _ => dateWeekdayShort7,
      };
    }
    return switch (weekday) {
      DateTime.monday => dateWeekdayLong1,
      DateTime.tuesday => dateWeekdayLong2,
      DateTime.wednesday => dateWeekdayLong3,
      DateTime.thursday => dateWeekdayLong4,
      DateTime.friday => dateWeekdayLong5,
      DateTime.saturday => dateWeekdayLong6,
      _ => dateWeekdayLong7,
    };
  }

  String date(DateTime value) => datePatternMonthDay(value);

  String dateFull(DateTime value) => datePatternFull(value);

  String dateWithWeekday(DateTime value) => datePatternWithWeekday(value);

  String dateTime(DateTime value) => datePatternDateTime(value, value);

  String relativeTime(DateTime value, DateTime now) {
    final difference = now.difference(value);
    if (difference.isNegative || difference.inMinutes < 1) {
      return timeJustNow;
    }
    if (difference.inMinutes < 60) {
      return timeMinutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 6 && dateOnly(value) == dateOnly(now)) {
      return timeHoursAgo(difference.inHours);
    }
    if (dateOnly(value) == dateOnly(now)) {
      return timeTodayAt(value);
    }
    final yesterday = dateOnly(now).subtract(const Duration(days: 1));
    if (dateOnly(value) == yesterday) {
      return timeYesterdayAt(value);
    }
    return dateTime(value);
  }

  String greeting(int hour) {
    if (hour < 6) {
      return greetingNight;
    }
    if (hour < 12) {
      return greetingMorning;
    }
    if (hour < 18) {
      return greetingAfternoon;
    }
    return greetingEvening;
  }

  String duration(Duration value) {
    if (value.inDays > 0) {
      return durationDays(value.inDays);
    }
    if (value.inHours > 0) {
      return durationHours(value.inHours);
    }
    if (value.inMinutes > 0) {
      return durationMinutes(value.inMinutes);
    }
    return durationLessThanMinute;
  }

  String weeks(Iterable<int> values) {
    final ranges = formatWeekRanges(values);
    return ranges.isEmpty ? commonNotSet : ranges;
  }

  String weekLabel(int week) => commonWeek(week);

  String themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => themeSystem,
      ThemeMode.light => themeLight,
      ThemeMode.dark => themeDark,
    };
  }
}
