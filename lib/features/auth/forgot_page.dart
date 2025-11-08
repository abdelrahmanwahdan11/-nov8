import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contact = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('forgot_password'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('forgot_password'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _contact,
                decoration: InputDecoration(labelText: '${l10n.t('email')} / ${l10n.t('phone')}'),
                validator: (value) => value == null || value.isEmpty ? l10n.t('try_again') : null,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(l10n.t('apply')),
            ),
            if (_submitted) ...[
              const SizedBox(height: 24),
              Text('✅ ${l10n.t('notifications')} sent!'),
            ],
          ],
        ),
      ),
    );
  }
}
