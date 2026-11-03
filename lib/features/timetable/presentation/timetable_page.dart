import 'package:academic_api/academic_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/i18n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../application/timetable_controller.dart';
import 'widgets/course_detail_sheet.dart';
import 'widgets/timetable_manager_sheet.dart';
import 'widgets/week_grid.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  int? _week;
  String? _weekTimetableId;

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableController>();
    final snapshot = timetable.snapshot;
    final catalog = context.read<AcademicProviderCatalog>();
    final now = DateTime.now();
    final displaySnapshot = snapshot ?? _emptySnapshot(timetable, catalog, now);
    final totalWeeks = displaySnapshot.totalWeeks;
    final currentWeek = displaySnapshot.weekNumberFor(now);
    final effectiveCurrent = currentWeek < 1
        ? 1
        : currentWeek > totalWeeks
        ? totalWeeks
        : currentWeek;
    final activeTimetable = timetable.activeTimetable;
    final selectedWeekState = _weekTimetableId == activeTimetable?.id
        ? _week
        : null;
    final selectedWeek = totalWeeks == 0
        ? 1
        : (selectedWeekState ?? effectiveCurrent).clamp(1, totalWeeks).toInt();
    final term = timetable.selectedTerm ?? snapshot?.term;
    final l10n = context.l10n;

    return ColoredBox(
      color: context.surfaces.page,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width >= 1000 ? 32 : 16,
            20,
            MediaQuery.sizeOf(context).width >= 1000 ? 32 : 16,
            MediaQuery.paddingOf(context).bottom + 32,
          ),
          children: <Widget>[
            AppPageHeader(
              title: l10n.timetableTitle,
              subtitle: activeTimetable?.displayName ?? l10n.timetableSubtitle,
              actions: <Widget>[
                IconButton(
                  tooltip: l10n.timetableManageTooltip,
                  onPressed: () => showTimetableManager(context),
                  icon: const Icon(Icons.view_list_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _TimetableControls(
              terms: timetable.localTerms,
              selectedTerm: term,
              totalWeeks: totalWeeks,
              selectedWeek: selectedWeek,
              currentWeek: effectiveCurrent,
              busy: timetable.busy,
              onTermChanged: (term) => _changeTerm(context, term),
              onWeekChanged: (week) {
                setState(() {
                  _week = week;
                  _weekTimetableId = activeTimetable?.id;
                });
              },
              onBackToCurrent: () {
                setState(() {
                  _week = null;
                  _weekTimetableId = activeTimetable?.id;
                });
              },
            ),
            if (timetable.busy) ...<Widget>[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(minHeight: 3),
              ),
            ],
            const SizedBox(height: 18),
            _WeekSummary(
              snapshot: displaySnapshot,
              week: selectedWeek,
              isCurrentWeek:
                  currentWeek >= 1 &&
                  currentWeek <= totalWeeks &&
                  selectedWeek == currentWeek,
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: WeekGrid(
                  snapshot: displaySnapshot,
                  week: selectedWeek,
                  onCourseTap: (course) {
                    showCourseDetail(
                      context,
                      snapshot: displaySnapshot,
                      course: course,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeTerm(BuildContext context, Term term) async {
    final timetable = context.read<TimetableController>();
    setState(() {
      _week = null;
      _weekTimetableId = null;
    });
    await timetable.selectTerm(term);
  }
}

class _TimetableControls extends StatelessWidget {
  const _TimetableControls({
    required this.terms,
    required this.selectedTerm,
    required this.totalWeeks,
    required this.selectedWeek,
    required this.currentWeek,
    required this.busy,
    required this.onTermChanged,
    required this.onWeekChanged,
    required this.onBackToCurrent,
  });

  final List<Term> terms;
  final Term? selectedTerm;
  final int totalWeeks;
  final int selectedWeek;
  final int currentWeek;
  final bool busy;
  final ValueChanged<Term> onTermChanged;
  final ValueChanged<int> onWeekChanged;
  final VoidCallback onBackToCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final availableTerms = terms.isEmpty && selectedTerm != null
        ? <Term>[selectedTerm!]
        : terms;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          _TermPicker(
            terms: availableTerms,
            selected: selectedTerm,
            enabled: !busy && availableTerms.length > 1,
            onSelected: onTermChanged,
          ),
          if (totalWeeks > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.timetablePreviousWeek,
                  onPressed: selectedWeek > 1
                      ? () => onWeekChanged(selectedWeek - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  l10n.weekLabel(selectedWeek),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.timetableNextWeek,
                  onPressed: selectedWeek < totalWeeks
                      ? () => onWeekChanged(selectedWeek + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                if (selectedWeek != currentWeek) ...<Widget>[
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: onBackToCurrent,
                    style: TextButton.styleFrom(
                      backgroundColor: context.surfaces.inset,
                      foregroundColor: context.colors.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 38),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.small),
                      ),
                    ),
                    child: Text(
                      l10n.timetableThisWeek,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TermPicker extends StatelessWidget {
  const _TermPicker({
    required this.terms,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final List<Term> terms;
  final Term? selected;
  final bool enabled;
  final ValueChanged<Term> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = selected?.shortName ?? l10n.timetableTermPlaceholder;
    return PopupMenuButton<Term>(
      enabled: enabled,
      tooltip: l10n.timetableSelectTerm,
      onSelected: onSelected,
      itemBuilder: (context) => <PopupMenuEntry<Term>>[
        for (final term in terms)
          PopupMenuItem<Term>(
            value: term,
            child: Row(
              children: <Widget>[
                Icon(
                  term.id == selected?.id
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 18,
                  color: term.id == selected?.id
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    term.shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: context.surfaces.inset,
          borderRadius: BorderRadius.circular(AppRadii.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.school_outlined,
              size: 17,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({
    required this.snapshot,
    required this.week,
    required this.isCurrentWeek,
  });

  final TimetableSnapshot snapshot;
  final int week;
  final bool isCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final monday = snapshot.dateForWeekday(week, DateTime.monday);
    final sunday = snapshot.dateForWeekday(week, DateTime.sunday);
    final courseCount = snapshot.coursesForWeek(week).length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        StatusChip(
          label: isCurrentWeek ? l10n.timetableThisWeek : l10n.weekLabel(week),
          icon: Icons.date_range_rounded,
          tone: isCurrentWeek ? StatusTone.primary : StatusTone.neutral,
        ),
        StatusChip(
          label: l10n.timetableWeekRange(l10n.date(monday), l10n.date(sunday)),
          icon: Icons.calendar_today_outlined,
        ),
        StatusChip(
          label: l10n.timetableCourseCount(courseCount),
          icon: Icons.menu_book_outlined,
        ),
        if (!snapshot.calendarVerified)
          StatusChip(
            label: l10n.timetableEstimated,
            icon: Icons.info_outline_rounded,
            tone: StatusTone.warning,
          ),
      ],
    );
  }
}

/// A render-only shell for the empty local dataset. It is never persisted and
/// only supplies the current week's dates and a provider's default period grid.
TimetableSnapshot _emptySnapshot(
  TimetableController timetable,
  AcademicProviderCatalog catalog,
  DateTime now,
) {
  final providerId =
      timetable.account.session?.providerId ?? timetable.providerId;
  final provider = providerId == null
      ? (catalog.providers.isEmpty ? null : catalog.providers.first)
      : catalog.byId(providerId) ??
            (catalog.providers.isEmpty ? null : catalog.providers.first);
  return TimetableSnapshot(
    term: const Term(yearCode: '', termCode: '', name: '', isCurrent: true),
    startDate: startOfWeek(now),
    slots: provider?.info.defaultSlots ?? const <TimeSlot>[],
    courses: const <Course>[],
    totalWeeks: 1,
    calendarVerified: true,
    fetchedAt: now,
  );
}
