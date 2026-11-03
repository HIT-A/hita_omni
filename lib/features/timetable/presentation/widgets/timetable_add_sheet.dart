import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../application/timetable_controller.dart';
import '../../domain/term.dart';

enum _AddTimetableAction { importFromEas }

Future<void> showTimetableAddSheet(BuildContext context) async {
  final action = await showModalBottomSheet<_AddTimetableAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => const _AddTimetableSheet(),
  );
  if (action == _AddTimetableAction.importFromEas && context.mounted) {
    await showTimetableImportSheet(context);
  }
}

class _AddTimetableSheet extends StatelessWidget {
  const _AddTimetableSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.timetableAddTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              _AddOption(
                icon: Icons.cloud_download_outlined,
                title: l10n.timetableAddImportTitle,
                subtitle: l10n.timetableAddImportSubtitle,
                onTap: () =>
                    Navigator.of(context)
                        .pop(_AddTimetableAction.importFromEas),
              ),
              const SizedBox(height: 10),
              _AddOption(
                icon: Icons.file_upload_outlined,
                title: l10n.timetableAddIcsTitle,
                subtitle: l10n.timetableAddIcsSubtitle,
                comingSoon: l10n.timetableAddComingSoon,
              ),
              const SizedBox(height: 10),
              _AddOption(
                icon: Icons.note_add_outlined,
                title: l10n.timetableAddBlankTitle,
                subtitle: l10n.timetableAddBlankSubtitle,
                comingSoon: l10n.timetableAddComingSoon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingSoon,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? comingSoon;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled
                  ? context.colors.primaryContainer
                  : context.surfaces.inset,
              borderRadius: BorderRadius.circular(AppRadii.small),
            ),
            child: Icon(
              icon,
              size: 21,
              color: enabled
                  ? context.colors.onPrimaryContainer
                  : context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: enabled
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (comingSoon != null)
            StatusChip(label: comingSoon!)
          else
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
        ],
      ),
    );
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        onTap: enabled ? onTap : null,
        child: content,
      ),
    );
  }
}

Future<void> showTimetableImportSheet(BuildContext context) {
  final timetable = context.read<TimetableController>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => TimetableImportSheet(timetable: timetable),
  );
}

class TimetableImportSheet extends StatefulWidget {
  const TimetableImportSheet({super.key, required this.timetable});

  final TimetableController timetable;

  @override
  State<TimetableImportSheet> createState() => _TimetableImportSheetState();
}

class _TimetableImportSheetState extends State<TimetableImportSheet> {
  late Future<List<Term>> _terms;
  String? _importingTermId;

  @override
  void initState() {
    super.initState();
    _terms = _loadTerms();
  }

  Future<List<Term>> _loadTerms() {
    if (widget.timetable.account.session == null) {
      return Future<List<Term>>.value(const <Term>[]);
    }
    return widget.timetable.loadTermsForImport();
  }

  void _retry() {
    setState(() => _terms = _loadTerms());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timetable = context.watch<TimetableController>();
    final hasSession = timetable.account.session != null;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: (MediaQuery.sizeOf(context).height * 0.7).clamp(
            320.0,
            640.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.timetableAddImportTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.timetableImportSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: !hasSession
                    ? EmptyState(
                        icon: Icons.login_rounded,
                        title: l10n.timetableImportNoSession,
                        message: l10n.timetableImportNoSessionMessage,
                      )
                    : FutureBuilder<List<Term>>(
                        future: _terms,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 180,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            final error = snapshot.error;
                            final message = error is ApiException
                                ? error.message
                                : l10n.timetableImportFailed;
                            return EmptyState(
                              icon: Icons.cloud_off_outlined,
                              title: l10n.timetableImportFailed,
                              message: message,
                              action: OutlinedButton.icon(
                                onPressed: _retry,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: Text(l10n.timetableImportRetry),
                              ),
                            );
                          }
                          final terms = snapshot.data ?? const <Term>[];
                          if (terms.isEmpty) {
                            return EmptyState(
                              icon: Icons.event_busy_outlined,
                              title: l10n.timetableImportEmpty,
                              message: l10n.timetableImportEmptyMessage,
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: terms.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final term = terms[index];
                              final existing = timetable.timetables.any(
                                (entry) => entry.snapshot.term.id == term.id,
                              );
                              final importing = _importingTermId == term.id;
                              return SurfaceCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                onTap: timetable.busy
                                    ? null
                                    : () => _import(term),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      size: 20,
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            term.shortName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          if (existing) ...<Widget>[
                                            const SizedBox(height: 3),
                                            Text(
                                              l10n.timetableImportExisting,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: context
                                                        .colors
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (importing)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _import(Term term) async {
    if (widget.timetable.busy) {
      return;
    }
    setState(() => _importingTermId = term.id);
    await widget.timetable.importTimetable(term);
    if (!mounted) {
      return;
    }
    setState(() => _importingTermId = null);
    final error = widget.timetable.error;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (widget.timetable.activeTimetable?.snapshot.term.id == term.id) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.timetableImportSuccess)),
        );
      Navigator.of(context).pop();
    }
  }
}
