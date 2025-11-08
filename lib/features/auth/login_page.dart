import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final scope = AppScope.of(context);
      scope.authNotifier.login(_email.text);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _guest() {
    final scope = AppScope.of(context);
    scope.authNotifier.guest();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('login')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/auth/signup'),
            child: Text(l10n.t('signup')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.t('welcome_back'), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: l10n.t('email')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.t('try_again');
                  }
                  final isPhone = int.tryParse(value) != null && value.length >= 7;
                  final isEmail = value.contains('@') && value.contains('.');
                  if (!isPhone && !isEmail) {
                    return l10n.t('try_again');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: l10n.t('password'),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return l10n.t('password_strength');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(value: _remember, onChanged: (value) => setState(() => _remember = value ?? false)),
                  Text(l10n.t('remember_me')),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/auth/forgot'),
                    child: Text(l10n.t('forgot_password')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(l10n.t('login')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _guest,
                  child: Text(l10n.t('guest')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
