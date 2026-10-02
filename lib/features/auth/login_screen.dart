import 'package:flutter/material.dart';

import '../../core/branding/erp_logo.dart';
import '../../core/branding/erp_wordmark.dart';
import '../../core/roles/app_role.dart';
import '../../core/roles/role_labels.dart';
import '../../core/session/session_store.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'login_view_model.dart';

/// Cuentas de la demo (coinciden con `backend/api/users.json`).
const _demoPassword = 'demo1234';
const _demoAccounts = [
  (email: 'superadmin@erpflutter.dev', role: AppRole.superAdmin),
  (email: 'admin@erpflutter.dev', role: AppRole.admin),
  (email: 'usuario@erpflutter.dev', role: AppRole.user),
  (email: 'trabajador@erpflutter.dev', role: AppRole.worker),
  (email: 'cliente@erpflutter.dev', role: AppRole.customer),
  (email: 'proveedor@erpflutter.dev', role: AppRole.supplier),
];

class LoginScreen extends StatefulWidget {
  final LoginViewModel viewModel;
  final AppSettings settings;
  final ValueChanged<SessionUser> onLoggedIn;

  const LoginScreen({
    super.key,
    required this.viewModel,
    required this.settings,
    required this.onLoggedIn,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _url =
      TextEditingController(text: widget.viewModel.initialServerUrl);
  late final TextEditingController _email =
      TextEditingController(text: widget.viewModel.initialEmail);
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _url.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final user = await widget.viewModel.login(
      serverUrl: _url.text,
      email: _email.text,
      password: _password.text,
    );
    if (user != null && mounted) widget.onLoggedIn(user);
  }

  void _fillDemoAccount(String email) {
    _email.text = email;
    _password.text = _demoPassword;
    if (_url.text.trim().isEmpty) _url.text = 'demo';
    widget.viewModel.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        actions: [_LanguageSelector(settings: widget.settings)],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            final enabled = !vm.isLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AutofillGroup(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        const Center(child: ErpLogo(size: 96)),
                        const SizedBox(height: 14),
                        Center(
                          child: ErpWordmark(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _url,
                          enabled: enabled,
                          keyboardType: TextInputType.url,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: l10n.loginServerUrlLabel,
                            helperText: l10n.loginServerUrlHelper,
                            helperMaxLines: 2,
                          ),
                          onChanged: (_) => vm.clearError(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _email,
                          enabled: enabled,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.email],
                          decoration:
                              InputDecoration(labelText: l10n.loginEmailLabel),
                          onChanged: (_) => vm.clearError(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _password,
                          enabled: enabled,
                          obscureText: _obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: l10n.loginPasswordLabel,
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: enabled
                                  ? () => setState(() => _obscure = !_obscure)
                                  : null,
                            ),
                          ),
                          onChanged: (_) => vm.clearError(),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: vm.rememberUrl,
                          onChanged: enabled
                              ? (v) => vm.setRememberUrl(v ?? false)
                              : null,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(l10n.loginRememberUrl),
                        ),
                        CheckboxListTile(
                          value: vm.rememberUser,
                          onChanged: enabled
                              ? (v) => vm.setRememberUser(v ?? false)
                              : null,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(l10n.loginRememberUser),
                        ),
                        if (vm.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorText(l10n, vm.error!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: enabled ? _submit : null,
                          child: vm.isLoading
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.loginSubmit),
                        ),
                        const SizedBox(height: 24),
                        _DemoAccounts(
                          enabled: enabled,
                          onSelected: _fillDemoAccount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _errorText(AppLocalizations l10n, LoginError error) =>
      switch (error) {
        LoginError.emptyServerUrl => l10n.loginErrorEmptyServerUrl,
        LoginError.emptyEmail => l10n.loginErrorEmptyEmail,
        LoginError.emptyPassword => l10n.loginErrorEmptyPassword,
        LoginError.invalidCredentials => l10n.loginErrorInvalidCredentials,
        LoginError.accessDenied => l10n.loginErrorAccessDenied,
        LoginError.invalidUrl => l10n.loginErrorInvalidUrl,
        LoginError.serverNotFound => l10n.loginErrorServerNotFound,
        LoginError.network => l10n.loginErrorNetwork,
        LoginError.timeout => l10n.loginErrorTimeout,
        LoginError.server => l10n.loginErrorServer,
        LoginError.unknown => l10n.loginErrorUnknown,
      };
}

class _LanguageSelector extends StatelessWidget {
  final AppSettings settings;

  const _LanguageSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppLanguage>(
          value: settings.language,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.language),
          ),
          borderRadius: BorderRadius.circular(12),
          onChanged: (language) {
            if (language != null) settings.setLanguage(language);
          },
          items: [
            for (final language in AppLanguage.values)
              DropdownMenuItem(
                value: language,
                child: Text(language.shortLabel),
              ),
          ],
        ),
      ),
    );
  }
}

/// Atajo de la demo: rellena el formulario con una cuenta de cada rol.
class _DemoAccounts extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _DemoAccounts({required this.enabled, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.badge_outlined, color: context.brand),
        title: Text(l10n.loginDemoAccounts),
        shape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.loginDemoAccountsHint(_demoPassword),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final account in _demoAccounts)
                ActionChip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(account.role.label(l10n)),
                  tooltip: account.email,
                  onPressed: enabled ? () => onSelected(account.email) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
