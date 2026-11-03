import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time.dart';
import '../../domain/course.dart';
import '../../domain/time_slot.dart';
import '../../domain/timetable_snapshot.dart';
import '../course_colors.dart';

const _gutterWidth = 46.0;
const _minDayWidth = 48.0;
const _slotHeight = 60.0;
const _headerHeight = 56.0;

class WeekGrid extends StatelessWidget {
  const WeekGrid({
    super.key,
    required this.snapshot,
    required this.week,
    required this.onCourseTap,
  });

  final TimetableSnapshot snapshot;
  final int week;
  final ValueChanged<Course> onCourseTap;

  @override
  Widget build(BuildContext context) {
    final slots = snapshot.slots;
    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(context.l10n.timetableMissingSlots),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final gridWidth = max(available, _gutterWidth + _minDayWidth * 7);
        final totalHeight = slots.length * _slotHeight;
        final courses = snapshot.coursesForWeek(week);
        final today = dateOnly(DateTime.now());

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: gridWidth,
            child: Column(
              children: <Widget>[
                _DayHeader(snapshot: snapshot, week: week, today: today),
                SizedBox(
                  height: totalHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        width: _gutterWidth,
                        child: _TimeGutter(slots: slots),
                      ),
                      for (var day = 1; day <= 7; day++)
                        Expanded(
                          child: _DayColumn(
                            day: day,
                            date: snapshot.dateForWeekday(week, day),
                            today: today,
                            slots: slots,
                            courses: <Course>[
                              for (final course in courses)
                                if (course.weekday == day) course,
                            ],
                            onCourseTap: onCourseTap,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.snapshot,
    required this.week,
    required this.today,
  });

  final TimetableSnapshot snapshot;
  final int week;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: _gutterWidth,
            child: Center(
              child: Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          for (var day = 1; day <= 7; day++)
            Expanded(
              child: _DayHeaderCell(
                date: snapshot.dateForWeekday(week, day),
                weekday: day,
                today: today,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({
    required this.date,
    required this.weekday,
    required this.today,
  });

  final DateTime date;
  final int weekday;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final isToday = dateOnly(date) == today;
    final isWeekend = weekday >= DateTime.saturday;
    return Container(
      decoration: BoxDecoration(
        color: isToday ? context.colors.primaryContainer : null,
        border: Border(
          left: BorderSide(color: context.surfaces.outline),
          bottom: BorderSide(color: context.surfaces.outline),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            context.l10n.weekday(weekday, short: true),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isToday
                  ? context.colors.onPrimaryContainer
                  : isWeekend
                  ? context.colors.onSurfaceVariant
                  : context.colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isToday
                  ? context.colors.onPrimaryContainer
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeGutter extends StatelessWidget {
  const _TimeGutter({required this.slots});

  final List<TimeSlot> slots;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: context.surfaces.outline)),
      ),
      child: Column(
        children: <Widget>[
          for (var index = 0; index < slots.length; index++)
            Container(
              height: _slotHeight,
              padding: const EdgeInsets.only(top: 6, right: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.surfaces.outline.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    slots[index].startLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: context.colors.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.date,
    required this.today,
    required this.slots,
    required this.courses,
    required this.onCourseTap,
  });

  final int day;
  final DateTime date;
  final DateTime today;
  final List<TimeSlot> slots;
  final List<Course> courses;
  final ValueChanged<Course> onCourseTap;

  @override
  Widget build(BuildContext context) {
    final isToday = dateOnly(date) == today;
    final isWeekend = day >= DateTime.saturday;
    final now = DateTime.now();
    final currentMinute = now.hour * 60 + now.minute;

    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? context.colors.primary.withValues(alpha: 0.035)
            : isWeekend
            ? context.surfaces.inset.withValues(alpha: 0.35)
            : null,
        border: Border(left: BorderSide(color: context.surfaces.outline)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Column(
            children: <Widget>[
              for (var index = 0; index < slots.length; index++)
                Container(
                  height: _slotHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: context.surfaces.outline.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final course in courses) _positionedCourse(context, course),
          if (isToday) _currentTimeLine(context, currentMinute),
        ],
      ),
    );
  }

  Widget _positionedCourse(BuildContext context, Course course) {
    if (course.startPeriod > slots.length || course.endPeriod < 1) {
      return const SizedBox.shrink();
    }
    final start = course.startPeriod.clamp(1, slots.length).toInt();
    final end = course.endPeriod.clamp(start, slots.length).toInt();
    final top = (start - 1) * _slotHeight + 3;
    final height = (end - start + 1) * _slotHeight - 6;
    if (height < 24) {
      return const SizedBox.shrink();
    }
    final color = courseColorFor(course);
    final foreground = foregroundForCourse(color);
    final maxLines = course.span >= 3
        ? 4
        : course.span == 2
        ? 3
        : 2;
    return Positioned(
      top: top,
      left: 2.5,
      right: 2.5,
      height: height,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onCourseTap(course),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  course.name,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (height >= 48 &&
                    course.displayClassroom.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    course.displayClassroom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.8),
                      fontSize: 9,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _currentTimeLine(BuildContext context, int currentMinute) {
    for (var index = 0; index < slots.length; index++) {
      final slot = slots[index];
      if (currentMinute < slot.startMinute || currentMinute > slot.endMinute) {
        continue;
      }
      final fraction = slot.endMinute == slot.startMinute
          ? 0.0
          : (currentMinute - slot.startMinute) /
                (slot.endMinute - slot.startMinute);
      final top = index * _slotHeight + fraction * _slotHeight;
      return Positioned(
        top: top - 1,
        left: -2,
        right: 0,
        child: Row(
          children: <Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.colors.error,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: Container(height: 2, color: context.colors.error)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
