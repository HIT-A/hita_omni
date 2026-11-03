import 'package:academic_api/academic_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../account/application/account_controller.dart';
import '../../../timetable/application/timetable_controller.dart';
import '../widgets/panel_card.dart';

class AccountPanel extends StatelessWidget {
  const AccountPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountController>();
    final timetable = context.watch<TimetableController>();
    final session = account.session;
    final l10n = context.l10n;

    return PanelCard(
      title: l10n.panelAccountTitle,
      icon: Icons.person_outline_rounded,
      trailing: IconButton(
        tooltip: session == null
            ? l10n.panelAccountLoginTooltip
            : l10n.panelAccountSyncTooltip,
        onPressed: session == null
            ? () {
                context.read<NavigationController>().go(CorePageIds.account);
              }
            : timetable.busy
            ? null
            : timetable.refresh,
        icon: timetable.busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                session == null ? Icons.login_rounded : Icons.sync_rounded,
                size: 20,
              ),
      ),
      child: session == null
          ? _SignedOut(
              onLogin: () {
                context.read<NavigationController>().go(CorePageIds.account);
              },
            )
          : _SignedIn(
              account: account,
              timetable: timetable,
              onOpen: () {
                context.read<NavigationController>().go(CorePageIds.account);
              },
            ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: context.surfaces.inset,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.panelAccountNotLoggedIn,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.panelAccountConnectHint,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: onLogin,
          child: Text(l10n.panelAccountLogin),
        ),
      ],
    );
  }
}

class _SignedIn extends StatelessWidget {
  const _SignedIn({
    required this.account,
    required this.timetable,
    required this.onOpen,
  });

  final AccountController account;
  final TimetableController timetable;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final session = account.session!;
    final snapshot = timetable.snapshot;
    final l10n = context.l10n;
    final provider = context.read<AcademicProviderCatalog>().byId(
      session.providerId,
    );
    final providerLabel = provider?.info.displayName ?? session.providerId;
    final status = timetable.busy
        ? l10n.panelAccountSyncing
        : timetable.error ??
              (snapshot == null
                  ? l10n.panelAccountNotSynced
                  : l10n.panelAccountSyncedAt(
                      l10n.relativeTime(snapshot.fetchedAt, DateTime.now()),
                    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 23,
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              child: Text(
                session.initial,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    session.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    <String>[
                      if (session.studentId?.isNotEmpty == true)
                        session.studentId!,
                      providerLabel,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (session.studentTypeLabel != null)
              StatusChip(label: session.studentTypeLabel!),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.surfaces.inset,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                timetable.error == null
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 16,
                color: timetable.error == null
                    ? context.colors.onSurfaceVariant
                    : context.colors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: timetable.error == null
                        ? context.colors.onSurfaceVariant
                        : context.colors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: Text(l10n.panelAccountSettings),
          ),
        ),
      ],
    );
  }
}
