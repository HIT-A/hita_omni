import 'package:academic_api/academic_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/i18n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../application/account_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _providerId;
  bool _obscurePassword = true;

  String _selectedProviderId(AcademicProviderCatalog catalog) {
    final selected = _providerId;
    if (selected != null && catalog.byId(selected) != null) {
      return selected;
    }
    return catalog.providers.first.id;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final catalog = context.read<AcademicProviderCatalog>();
    final provider = catalog.require(_selectedProviderId(catalog));
    if (!provider.info.supportsPasswordLogin) {
      return;
    }
    final account = context.read<AccountController>();
    final success = await account.signIn(
      providerId: provider.id,
      username: _usernameController.text,
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountController>();
    final catalog = context.read<AcademicProviderCatalog>();
    final providers = catalog.providers;
    final selected = catalog.require(_selectedProviderId(catalog));
    final busy = account.busy;
    final supported = selected.info.supportsPasswordLogin;
    final webUnsupported = kIsWeb;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const AppLogo(size: 46),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.loginBrandTitle,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.loginBrandSubtitle),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SectionLabel(l10n.loginCampus),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final provider in providers)
                            ChoiceChip(
                              label: Text(provider.info.displayName),
                              selected: selected.id == provider.id,
                              onSelected: busy
                                  ? null
                                  : (_) {
                                      setState(() => _providerId = provider.id);
                                    },
                            ),
                        ],
                      ),
                      if (!supported) ...<Widget>[
                        const SizedBox(height: 12),
                        _LoginNotice(
                          message: selected.info.note,
                          color: context.colors.secondaryContainer,
                          foreground: context.colors.onSecondaryContainer,
                          icon: Icons.info_outline_rounded,
                        ),
                      ],
                      if (webUnsupported) ...<Widget>[
                        const SizedBox(height: 12),
                        _LoginNotice(
                          message: l10n.loginWebUnsupported,
                          color: context.colors.errorContainer,
                          foreground: context.colors.onErrorContainer,
                          icon: Icons.public_off_rounded,
                        ),
                      ],
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _usernameController,
                        enabled: !busy,
                        autofillHints: const <String>[AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: l10n.loginAccount,
                          hintText: l10n.loginAccountHint,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.loginAccountRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !busy,
                        autofillHints: const <String>[AutofillHints.password],
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: l10n.loginPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? l10n.loginShowPassword
                                : l10n.loginHidePassword,
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.loginPasswordRequired;
                          }
                          return null;
                        },
                      ),
                      if (account.error != null) ...<Widget>[
                        const SizedBox(height: 14),
                        SurfaceCard(
                          color: context.colors.errorContainer,
                          border: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.error_outline_rounded,
                                size: 19,
                                color: context.colors.onErrorContainer,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  account.error!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: context.colors.onErrorContainer,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: busy || !supported || webUnsupported
                            ? null
                            : _submit,
                        child: busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                webUnsupported
                                    ? l10n.loginWebUnsupportedButton
                                    : supported
                                    ? l10n.loginSubmit
                                    : l10n.loginUnsupportedCampusButton,
                              ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.loginPrivacy,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginNotice extends StatelessWidget {
  const _LoginNotice({
    required this.message,
    required this.color,
    required this.foreground,
    required this.icon,
  });

  final String message;
  final Color color;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: color,
      border: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 19, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: foreground, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
