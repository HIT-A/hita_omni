import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/course.dart';
import '../../domain/timetable_snapshot.dart';
import '../course_colors.dart';

Future<void> showCourseDetail(
  BuildContext context, {
  required TimetableSnapshot snapshot,
  required Course course,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final l10n = context.l10n;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 52,
                    decoration: BoxDecoration(
                      color: courseColorFor(course),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (course.code != null &&
                            course.code!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          StatusChip(
                            label: course.code!,
                            icon: Icons.tag_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SurfaceCard(
                color: context.surfaces.inset,
                border: false,
                child: Column(
                  children: <Widget>[
                    InfoRow(
                      icon: Icons.schedule_rounded,
                      label: l10n.timetableDetailTime,
                      value:
                          '${l10n.weekday(course.weekday)} '
                          '${snapshot.timeLabelForCourse(course)}',
                    ),
                    Divider(color: context.surfaces.outline),
                    InfoRow(
                      icon: Icons.date_range_rounded,
                      label: l10n.timetableDetailWeeks,
                      value: l10n.weeks(course.weeks),
                    ),
                    Divider(color: context.surfaces.outline),
                    InfoRow(
                      icon: Icons.location_on_outlined,
                      label: l10n.timetableDetailLocation,
                      value: course.displayClassroom.isEmpty
                          ? l10n.timetableDetailNotFilled
                          : course.displayClassroom,
                    ),
                    Divider(color: context.surfaces.outline),
                    InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: l10n.timetableDetailTeacher,
                      value: course.displayTeacher.isEmpty
                          ? l10n.timetableDetailNotFilled
                          : course.displayTeacher,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.timetableDetailClose),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
