import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class MortgagePage extends StatefulWidget {
  const MortgagePage({super.key});

  @override
  State<MortgagePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends State<MortgagePage> {
  final TextEditingController _price = TextEditingController(text: '2400000');
  final TextEditingController _down = TextEditingController(text: '20');
  final TextEditingController _years = TextEditingController(text: '25');
  final TextEditingController _rate = TextEditingController(text: '6');

  double _monthly = 0;
  double _totalInterest = 0;

  @override
  void initState() {
    super.initState();
    _recalculate();
    for (final controller in [_price, _down, _years, _rate]) {
      controller.addListener(_recalculate);
    }
  }

  @override
  void dispose() {
    for (final controller in [_price, _down, _years, _rate]) {
      controller.removeListener(_recalculate);
      controller.dispose();
    }
    super.dispose();
  }

  void _recalculate() {
    final price = double.tryParse(_price.text) ?? 0;
    final down = (double.tryParse(_down.text) ?? 0) / 100;
    final years = double.tryParse(_years.text) ?? 0;
    final rate = (double.tryParse(_rate.text) ?? 0) / 100 / 12;
    final principal = price * (1 - down);
    final payments = years * 12;
    if (rate == 0) {
      _monthly = payments == 0 ? 0 : principal / payments;
    } else {
      final pow = math.pow(1 + rate, payments);
      _monthly = principal * rate * pow / (pow - 1);
    }
    _totalInterest = _monthly * payments - principal;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('mortgage_calculator'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(label: l10n.t('price'), controller: _price),
            const SizedBox(height: 16),
            _Field(label: l10n.t('down_payment'), controller: _down, suffix: '%'),
            const SizedBox(height: 16),
            _Field(label: l10n.t('years'), controller: _years),
            const SizedBox(height: 16),
            _Field(label: l10n.t('rate'), controller: _rate, suffix: '%'),
            const SizedBox(height: 24),
            Text('${l10n.t('monthly_payment')}: USD ${_monthly.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Total interest: USD ${_totalInterest.toStringAsFixed(0)}'),
            const SizedBox(height: 24),
            SizedBox(height: 160, child: _AmortizationChart(monthly: _monthly, totalInterest: _totalInterest)),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.suffix});

  final String label;
  final TextEditingController controller;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    );
  }
}

class _AmortizationChart extends StatelessWidget {
  const _AmortizationChart({required this.monthly, required this.totalInterest});

  final double monthly;
  final double totalInterest;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmortizationPainter(monthly: monthly, totalInterest: totalInterest),
      child: Container(),
    );
  }
}

class _AmortizationPainter extends CustomPainter {
  _AmortizationPainter({required this.monthly, required this.totalInterest});

  final double monthly;
  final double totalInterest;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.orangeAccent;
    final interestPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueGrey.withOpacity(0.7);
    final principalHeight = monthly == 0 ? 0 : size.height * (monthly / (monthly + (totalInterest / 12)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(40, size.height - principalHeight, 40, principalHeight), const Radius.circular(8)),
      paint,
    );
    final interestHeight = monthly <= 0
        ? 0
        : size.height * (totalInterest <= 0 ? 0 : math.min(1, totalInterest / (monthly * 12 * 5)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(140, size.height - interestHeight, 40, interestHeight), const Radius.circular(8)),
      interestPaint,
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(text: 'Monthly', style: TextStyle(color: Colors.white));
    textPainter.layout(maxWidth: 80);
    textPainter.paint(canvas, Offset(32, size.height - principalHeight - 24));
    textPainter.text = const TextSpan(text: 'Interest', style: TextStyle(color: Colors.white));
    textPainter.layout(maxWidth: 80);
    textPainter.paint(canvas, Offset(130, size.height - interestHeight - 24));
  }

  @override
  bool shouldRepaint(covariant _AmortizationPainter oldDelegate) =>
      oldDelegate.monthly != monthly || oldDelegate.totalInterest != totalInterest;
}
