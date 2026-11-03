import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../timetable/application/timetable_controller.dart';
import '../widgets/panel_card.dart';

class WeekProgressPanel extends StatelessWidget {
  const WeekProgressPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableController>();
    final snapshot = timetable.snapshot;
    final now = DateTime.now();
    final l10n = context.l10n;

    final hasCalendar = snapshot != null;
    final totalWeeks = snapshot?.totalWeeks ?? 0;
    final rawWeek = snapshot?.weekNumberFor(now) ?? 0;
    final beforeTerm = !hasCalendar || rawWeek < 1;
    final afterTerm = hasCalendar && rawWeek > totalWeeks;
    final week = afterTerm
        ? totalWeeks
        : beforeTerm
        ? 0
        : rawWeek;
    final progress = totalWeeks == 0
        ? 0.0
        : (week / totalWeeks).clamp(0.0, 1.0);
    final daysLeftInWeek = 7 - now.weekday;

    return PanelCard(
      title: l10n.panelWeekProgressTitle,
      icon: Icons.timelapse_rounded,
      trailing: hasCalendar
          ? StatusChip(
              label: afterTerm
                  ? l10n.panelWeekProgressEnded
                  : beforeTerm
                  ? l10n.panelWeekProgressNotStarted
                  : l10n.weekLabel(week),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                beforeTerm ? '—' : l10n.weekLabel(week),
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (snapshot != null) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  l10n.panelWeekProgressTotalWeeks(snapshot.totalWeeks),
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: context.surfaces.inset,
            ),
          ),
          if (snapshot != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              snapshot.term.shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              afterTerm
                  ? l10n.panelWeekProgressTermEnded
                  : beforeTerm
                  ? l10n.panelWeekProgressTermNotStarted
                  : l10n.panelWeekProgressDaysLeft(daysLeftInWeek),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!snapshot.calendarVerified) ...<Widget>[
              const SizedBox(height: 10),
              StatusChip(
                label: l10n.panelWeekProgressEstimated,
                icon: Icons.info_outline_rounded,
                tone: StatusTone.warning,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
