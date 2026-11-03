import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../timetable/application/timetable_controller.dart';
import '../../../timetable/domain/timetable_snapshot.dart';
import '../../../timetable/presentation/course_colors.dart';
import '../../../timetable/presentation/widgets/course_detail_sheet.dart';
import '../widgets/panel_card.dart';

class NextClassPanel extends StatelessWidget {
  const NextClassPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableController>();
    final snapshot = timetable.snapshot;
    final now = DateTime.now();
    final occurrence = snapshot?.nextOccurrence(now);
    final ongoing = occurrence?.isOngoingAt(now) ?? false;
    final l10n = context.l10n;

    return PanelCard(
      title: ongoing
          ? l10n.panelNextClassOngoingTitle
          : l10n.panelNextClassTitle,
      icon: ongoing
          ? Icons.play_circle_outline_rounded
          : Icons.schedule_rounded,
      accent: true,
      child: _buildContent(
        context,
        timetable: timetable,
        occurrence: occurrence,
        now: now,
        ongoing: ongoing,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required TimetableController timetable,
    required CourseOccurrence? occurrence,
    required DateTime now,
    required bool ongoing,
  }) {
    final l10n = context.l10n;
    if (occurrence == null) {
      return Text(
        l10n.panelNextClassNoCourses,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final course = occurrence.course;
    final date = occurrence.date;
    final start = occurrence.start;
    final end = occurrence.end;
    final countdown = ongoing
        ? l10n.panelNextClassEndsIn(l10n.duration(end.difference(now)))
        : l10n.panelNextClassStartsIn(l10n.duration(start.difference(now)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            StatusChip(
              label: ongoing
                  ? l10n.panelNextClassOngoing
                  : dateOnly(date) == dateOnly(now)
                  ? l10n.panelNextClassUpcoming
                  : l10n.dateWithWeekday(date),
              tone: StatusTone.primary,
              icon: ongoing
                  ? Icons.play_arrow_rounded
                  : Icons.arrow_forward_rounded,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                countdown,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.colors.onPrimaryContainer.withValues(
                    alpha: 0.72,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showCourseDetail(
            context,
            snapshot: timetable.snapshot!,
            course: course,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              course.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: <Widget>[
            _Meta(icon: Icons.schedule_rounded, text: occurrence.timeLabel),
            if (course.displayClassroom.isNotEmpty)
              _Meta(
                icon: Icons.location_on_outlined,
                text: course.displayClassroom,
              ),
            if (course.displayTeacher.isNotEmpty)
              _Meta(
                icon: Icons.person_outline_rounded,
                text: course.displayTeacher,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: courseColorFor(course),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${l10n.panelNextClassPeriods(course.startPeriod, course.endPeriod)} · ${l10n.panelNextClassWeeks(l10n.weeks(course.weeks))}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.colors.onPrimaryContainer.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 16,
          color: context.colors.onPrimaryContainer.withValues(alpha: 0.66),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.onPrimaryContainer.withValues(alpha: 0.82),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
