import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../application/timetable_controller.dart';
import '../../domain/timetable_entry.dart';
import 'timetable_add_sheet.dart';

Future<void> showTimetableManager(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 620),
    builder: (_) => const TimetableManagerSheet(),
  );
}

class TimetableManagerSheet extends StatelessWidget {
  const TimetableManagerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableController>();
    final l10n = context.l10n;
    final maxHeight = (MediaQuery.sizeOf(context).height * 0.72).clamp(
      320.0,
      640.0,
    );

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
                          l10n.timetableManagerTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.timetableManagerSubtitle(
                            timetable.timetables.length,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.timetableAddTooltip,
                    onPressed: () => showTimetableAddSheet(context),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: timetable.timetables.isEmpty
                    ? const SingleChildScrollView(child: _EmptyManager())
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: timetable.timetables.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final entry = timetable.timetables[index];
                          return _TimetableRow(
                            entry: entry,
                            active: entry.id == timetable.activeTimetable?.id,
                            busy: timetable.busy,
                            onTap: () => _select(context, timetable, entry),
                            onRename: () => _rename(context, timetable, entry),
                            onDelete: () => _delete(context, timetable, entry),
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

  Future<void> _select(
    BuildContext context,
    TimetableController timetable,
    TimetableEntry entry,
  ) async {
    if (timetable.busy) {
      return;
    }
    if (entry.id != timetable.activeTimetable?.id) {
      await timetable.selectTimetable(entry.id);
      if (!context.mounted) {
        return;
      }
      final error = timetable.error;
      if (error != null) {
        _showMessage(context, error);
        return;
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _rename(
    BuildContext context,
    TimetableController timetable,
    TimetableEntry entry,
  ) async {
    final l10n = context.l10n;
    final textController = TextEditingController(text: entry.displayName);
    String? validationError;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void submit() {
              final value = textController.text.trim();
              if (value.isEmpty) {
                setState(() => validationError = l10n.timetableRenameEmpty);
                return;
              }
              Navigator.of(dialogContext).pop(value);
            }

            return AlertDialog(
              title: Text(l10n.timetableRenameTitle),
              content: TextField(
                controller: textController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit(),
                decoration: InputDecoration(
                  labelText: l10n.timetableRenameLabel,
                  errorText: validationError,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.timetableRenameCancel),
                ),
                FilledButton(
                  onPressed: submit,
                  child: Text(l10n.timetableRenameSave),
                ),
              ],
            );
          },
        );
      },
    );
    textController.dispose();
    if (name == null || !context.mounted) {
      return;
    }
    final saved = await timetable.renameTimetable(entry.id, name);
    if (!saved && context.mounted) {
      _showMessage(context, l10n.timetableManagerSaveFailed);
    }
  }

  Future<void> _delete(
    BuildContext context,
    TimetableController timetable,
    TimetableEntry entry,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.timetableDeleteTitle),
        content: Text(l10n.timetableDeleteMessage(entry.displayName)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.timetableDeleteCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.timetableDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final deleted = await timetable.deleteTimetable(entry.id);
    if (!deleted && context.mounted) {
      _showMessage(context, l10n.timetableManagerSaveFailed);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptyManager extends StatelessWidget {
  const _EmptyManager();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Icons.calendar_view_week_outlined,
      title: l10n.timetableManagerEmpty,
      message: l10n.timetableManagerEmptyMessage,
    );
  }
}

class _TimetableRow extends StatelessWidget {
  const _TimetableRow({
    required this.entry,
    required this.active,
    required this.busy,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final TimetableEntry entry;
  final bool active;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      onTap: busy ? null : onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: active
                  ? context.colors.primaryContainer
                  : context.surfaces.inset,
              borderRadius: BorderRadius.circular(AppRadii.small),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: active
                  ? context.colors.onPrimaryContainer
                  : context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        entry.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (active) ...<Widget>[
                      const SizedBox(width: 8),
                      StatusChip(
                        label: l10n.timetableManagerCurrent,
                        tone: StatusTone.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.displayName == entry.snapshot.term.shortName
                      ? l10n.timetableCourseCount(entry.courseCount)
                      : '${entry.snapshot.term.shortName} · '
                            '${l10n.timetableCourseCount(entry.courseCount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          PopupMenuButton<_TimetableAction>(
            enabled: !busy,
            tooltip: l10n.timetableManagerActions,
            onSelected: (action) {
              switch (action) {
                case _TimetableAction.rename:
                  onRename();
                case _TimetableAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<_TimetableAction>>[
              PopupMenuItem<_TimetableAction>(
                value: _TimetableAction.rename,
                child: Text(l10n.timetableManagerRename),
              ),
              PopupMenuItem<_TimetableAction>(
                value: _TimetableAction.delete,
                child: Text(l10n.timetableManagerDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _TimetableAction { rename, delete }
