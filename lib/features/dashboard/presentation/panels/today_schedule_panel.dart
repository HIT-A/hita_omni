import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../timetable/application/timetable_controller.dart';
import '../../../timetable/domain/timetable_snapshot.dart';
import '../../../timetable/presentation/course_colors.dart';
import '../../../timetable/presentation/widgets/course_detail_sheet.dart';
import '../widgets/panel_card.dart';

class TodaySchedulePanel extends StatelessWidget {
  const TodaySchedulePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableController>();
    final snapshot = timetable.snapshot;
    final now = DateTime.now();
    final occurrences =
        snapshot?.occurrencesOn(now) ?? const <CourseOccurrence>[];
    final l10n = context.l10n;

    return PanelCard(
      title: l10n.panelTodayScheduleTitle,
      icon: Icons.view_day_outlined,
      trailing: occurrences.isEmpty
          ? null
          : StatusChip(label: l10n.panelTodayScheduleCount(occurrences.length)),
      child: _buildContent(
        context,
        timetable: timetable,
        snapshot: snapshot,
        occurrences: occurrences,
        now: now,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required TimetableController timetable,
    required TimetableSnapshot? snapshot,
    required List<CourseOccurrence> occurrences,
    required DateTime now,
  }) {
    final l10n = context.l10n;
    if (occurrences.isEmpty) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: EmptyState(
              icon: Icons.free_breakfast_outlined,
              title: l10n.panelTodayScheduleNoCoursesTitle,
              message: l10n.panelTodayScheduleNoCoursesMessage,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              context.read<NavigationController>().go(CorePageIds.timetable);
            },
            icon: const Icon(Icons.calendar_view_week_rounded, size: 18),
            label: Text(l10n.panelTodayScheduleViewFull),
          ),
        ],
      );
    }

    final activeSnapshot = snapshot!;
    return Column(
      children: <Widget>[
        for (var index = 0; index < occurrences.length; index++) ...<Widget>[
          if (index > 0) Divider(height: 1, color: context.surfaces.outline),
          _ScheduleRow(
            occurrence: occurrences[index],
            snapshot: activeSnapshot,
            now: now,
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              context.read<NavigationController>().go(CorePageIds.timetable);
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(l10n.panelTodayScheduleViewFull),
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.occurrence,
    required this.snapshot,
    required this.now,
  });

  final CourseOccurrence occurrence;
  final TimetableSnapshot snapshot;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final course = occurrence.course;
    final color = courseColorFor(course);
    final ongoing = occurrence.isOngoingAt(now);
    final finished = occurrence.isFinishedAt(now);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () =>
          showCourseDetail(context, snapshot: snapshot, course: course),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: ongoing
              ? color.withValues(alpha: context.isDark ? 0.18 : 0.08)
              : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 46,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatClock(
                      occurrence.start.hour * 60 + occurrence.start.minute,
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: finished
                          ? context.colors.onSurfaceVariant
                          : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatClock(
                      occurrence.end.hour * 60 + occurrence.end.minute,
                    ),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              width: 3,
              height: 48,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          course.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: finished
                                    ? context.colors.onSurfaceVariant
                                    : context.colors.onSurface,
                              ),
                        ),
                      ),
                      if (ongoing) ...<Widget>[
                        const SizedBox(width: 8),
                        StatusChip(
                          label: context.l10n.panelTodayScheduleOngoing,
                          tone: StatusTone.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    <String>[
                      if (course.displayClassroom.isNotEmpty)
                        course.displayClassroom,
                      if (course.displayTeacher.isNotEmpty)
                        course.displayTeacher,
                      context.l10n.panelTodaySchedulePeriods(
                        course.startPeriod,
                        course.endPeriod,
                      ),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
