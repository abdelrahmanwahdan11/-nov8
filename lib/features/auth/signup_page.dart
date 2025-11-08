import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  double _strength = 0;

  @override
  void initState() {
    super.initState();
    _password.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.removeListener(_updateStrength);
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final value = _password.text;
    double score = 0;
    if (value.length >= 8) score += 0.4;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score += 0.2;
    setState(() => _strength = score.clamp(0, 1));
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final scope = AppScope.of(context);
      scope.authNotifier.login(_email.text);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('signup'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.t('name')),
                validator: (value) => value == null || value.isEmpty ? l10n.t('try_again') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: l10n.t('email')),
                validator: (value) {
                  if (value == null || !value.contains('@')) return l10n.t('try_again');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.t('phone')),
                validator: (value) => value == null || value.length < 7 ? l10n.t('try_again') : null,
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
                validator: (value) => value == null || value.length < 8 ? l10n.t('password_strength') : null,
              ),
              const SizedBox(height: 8),
              _PasswordStrengthBar(strength: _strength),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: l10n.t('confirm_password'),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) => value != _password.text ? l10n.t('try_again') : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(l10n.t('signup')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final double strength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label;
    Color color;
    if (strength < 0.4) {
      label = l10n.t('strength_weak');
      color = Colors.redAccent;
    } else if (strength < 0.8) {
      label = l10n.t('strength_medium');
      color = Colors.amber;
    } else {
      label = l10n.t('strength_strong');
      color = Colors.green;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: strength, minHeight: 8, color: color, backgroundColor: color.withOpacity(0.2)),
        const SizedBox(height: 8),
        Text('${l10n.t('password_strength')}: $label'),
      ],
    );
  }
}
