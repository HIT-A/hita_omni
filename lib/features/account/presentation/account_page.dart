import 'package:academic_api/academic_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_info.dart';
import '../../../core/i18n/i18n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/plugin/omni_plugin.dart';
import '../../../core/plugin/plugin_registry.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../timetable/application/timetable_controller.dart';
import '../application/account_controller.dart';
import 'login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountController>();
    final timetable = context.watch<TimetableController>();
    final theme = context.watch<ThemeController>();
    final plugins = context.read<PluginRegistry>().plugins;
    final session = account.session;
    final l10n = context.l10n;
    final horizontal = MediaQuery.sizeOf(context).width >= 1000 ? 32.0 : 16.0;

    return ColoredBox(
      color: context.surfaces.page,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                20,
                horizontal,
                MediaQuery.paddingOf(context).bottom + 32,
              ),
              children: <Widget>[
                AppPageHeader(
                  title: l10n.accountTitle,
                  subtitle: l10n.accountSubtitle,
                ),
                const SizedBox(height: 22),
                if (account.error != null) ...<Widget>[
                  _ErrorCard(
                    message: account.error!,
                    onDismiss: account.clearError,
                  ),
                  const SizedBox(height: 14),
                ],
                if (session == null)
                  _SignedOutCard(onLogin: () => _openLogin(context))
                else
                  _ProfileCard(
                    account: account,
                    timetable: timetable,
                    onRelogin: () => _openLogin(context),
                  ),
                const SizedBox(height: 24),
                SectionLabel(l10n.accountSectionAccount),
                const SizedBox(height: 10),
                if (session == null)
                  SurfaceCard(
                    child: EmptyState(
                      icon: Icons.login_rounded,
                      title: l10n.accountNotLoggedIn,
                      message: l10n.accountNotLoggedInMessage,
                      action: FilledButton.icon(
                        onPressed: () => _openLogin(context),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: Text(l10n.accountLoginAccount),
                      ),
                    ),
                  )
                else
                  _AccountSettingsCard(
                    account: account,
                    timetable: timetable,
                    onRelogin: () => _openLogin(context),
                    onSignOut: () => _signOut(context, account),
                  ),
                const SizedBox(height: 24),
                SectionLabel(l10n.accountAppearance),
                const SizedBox(height: 10),
                SurfaceCard(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final mode in ThemeMode.values)
                        ChoiceChip(
                          label: Text(l10n.themeModeLabel(mode)),
                          selected: theme.mode == mode,
                          onSelected: (_) => theme.setMode(mode),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionLabel(l10n.accountPlugins),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: <Widget>[
                      for (var index = 0; index < plugins.length; index++) ...[
                        if (index > 0)
                          Divider(height: 1, color: context.surfaces.outline),
                        _PluginRow(
                          plugin: plugins[index],
                          panelCount: plugins[index].panels.length,
                          pageCount: plugins[index].pages.length,
                        ),
                      ],
                      if (plugins.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(l10n.accountNoPlugins),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionLabel(l10n.accountAbout),
                const SizedBox(height: 10),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const AppLogo(size: 38),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  appName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  appVersionLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.accountAboutText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openLogin(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
  }

  Future<void> _signOut(BuildContext context, AccountController account) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountLogoutTitle),
        content: Text(l10n.accountLogoutMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountLogoutAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await account.signOut();
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(l10n.accountLoggedOut)));
    }
  }
}

class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      color: context.colors.primaryContainer,
      border: false,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.school_rounded,
            size: 42,
            color: context.colors.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.accountConnectTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.accountConnectMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.onPrimaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: onLogin,
            child: Text(l10n.accountLogin),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.account,
    required this.timetable,
    required this.onRelogin,
  });

  final AccountController account;
  final TimetableController timetable;
  final VoidCallback onRelogin;

  @override
  Widget build(BuildContext context) {
    final session = account.session!;
    final l10n = context.l10n;
    final provider = context.read<AcademicProviderCatalog>().byId(
      session.providerId,
    );
    final providerLabel = provider?.info.displayName ?? session.providerId;
    final studentType = session.studentTypeLabel;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 31,
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                child: Text(
                  session.initial,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.displayName,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      <String>[
                        if (session.studentId?.isNotEmpty == true)
                          session.studentId!,
                        providerLabel,
                        ?studentType,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        StatusChip(
                          label: timetable.error == null
                              ? l10n.accountConnected
                              : l10n.accountSyncError,
                          icon: timetable.error == null
                              ? Icons.check_circle_outline_rounded
                              : Icons.error_outline_rounded,
                          tone: timetable.error == null
                              ? StatusTone.success
                              : StatusTone.error,
                        ),
                        if (timetable.snapshot != null)
                          StatusChip(
                            label: l10n.accountLastSynced(
                              l10n.relativeTime(
                                timetable.snapshot!.fetchedAt,
                                DateTime.now(),
                              ),
                            ),
                            icon: Icons.sync_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onRelogin,
                child: Text(l10n.accountRelogin),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountSettingsCard extends StatelessWidget {
  const _AccountSettingsCard({
    required this.account,
    required this.timetable,
    required this.onRelogin,
    required this.onSignOut,
  });

  final AccountController account;
  final TimetableController timetable;
  final VoidCallback onRelogin;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final session = account.session!;
    final l10n = context.l10n;
    final provider = context.read<AcademicProviderCatalog>().byId(
      session.providerId,
    );
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InfoRow(
            icon: Icons.school_outlined,
            label: l10n.accountCampus,
            value: provider?.info.displayName ?? session.providerId,
          ),
          Divider(color: context.surfaces.outline),
          InfoRow(
            icon: Icons.badge_outlined,
            label: l10n.accountStudentId,
            value: session.studentId?.isNotEmpty == true
                ? session.studentId!
                : l10n.commonNotAvailable,
          ),
          Divider(color: context.surfaces.outline),
          InfoRow(
            icon: Icons.account_balance_outlined,
            label: l10n.accountSchool,
            value: session.school?.isNotEmpty == true
                ? session.school!
                : l10n.commonNotAvailable,
          ),
          Divider(color: context.surfaces.outline),
          InfoRow(
            icon: Icons.login_rounded,
            label: l10n.accountLoginTime,
            value: l10n.dateTime(session.signedInAt),
          ),
          Divider(color: context.surfaces.outline),
          InfoRow(
            icon: Icons.sync_rounded,
            label: l10n.accountSyncStatus,
            value: timetable.busy
                ? l10n.accountSyncing
                : timetable.error ??
                      (timetable.snapshot == null
                          ? l10n.accountNotSynced
                          : l10n.accountSynced),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: timetable.busy ? null : () => _sync(context),
                icon: timetable.busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text(
                  timetable.busy ? l10n.accountSyncing : l10n.accountSync,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onRelogin,
                icon: const Icon(Icons.lock_reset_rounded, size: 18),
                label: Text(l10n.accountRelogin),
              ),
              OutlinedButton.icon(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(
                    color: context.colors.error.withValues(alpha: 0.45),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(l10n.accountLogout),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sync(BuildContext context) async {
    final l10n = context.l10n;
    await timetable.refresh();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(timetable.error ?? l10n.dashboardSynced)),
    );
  }
}

class _PluginRow extends StatelessWidget {
  const _PluginRow({
    required this.plugin,
    required this.panelCount,
    required this.pageCount,
  });

  final OmniPlugin plugin;
  final int panelCount;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pluginName = plugin.localizeName(l10n);
    final pluginDescription = plugin.localizeDescription(l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.surfaces.inset,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.extension_outlined,
              size: 19,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$pluginName  ·  ${plugin.version}',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  pluginDescription,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusChip(
            label: <String>[
              if (panelCount > 0) l10n.accountPluginPanels(panelCount),
              if (pageCount > 0) l10n.accountPluginPages(pageCount),
            ].join(' · '),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: context.colors.errorContainer,
      border: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: context.colors.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.onErrorContainer,
                height: 1.5,
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.accountErrorDismiss,
            onPressed: onDismiss,
            icon: Icon(
              Icons.close_rounded,
              color: context.colors.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
