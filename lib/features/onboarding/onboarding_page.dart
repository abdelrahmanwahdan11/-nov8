import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      titleKey: 'onboard_title_1',
      messageKey: 'onboard_body_1',
      image: 'https://picsum.photos/seed/onboard_modern/800/1200',
    ),
    _OnboardData(
      titleKey: 'onboard_title_2',
      messageKey: 'onboard_body_2',
      image: 'https://picsum.photos/seed/onboard_ivory/800/1200',
    ),
    _OnboardData(
      titleKey: 'onboard_title_3',
      messageKey: 'onboard_body_3',
      image: 'https://picsum.photos/seed/onboard_fusion/800/1200',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _pages.length;
        _controller.animateToPage(
          _index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    final scope = AppScope.of(context);
    scope.preferencesService.setFirstRunDone();
    Navigator.of(context).pushReplacementNamed('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final data = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(data.image, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          l10n.t(data.titleKey),
                          style: GoogleFonts.urbanist(
                            textStyle: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.t(data.messageKey),
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              height: 6,
                              width: _index == i ? 24 : 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(_index == i ? 1 : 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _finish,
                              child: Text(l10n.t('skip'), style: const TextStyle(color: Colors.white)),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _finish,
                              child: Text(_index == _pages.length - 1 ? l10n.t('get_started') : l10n.t('next')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 48,
            right: 24,
            child: TextButton(
              onPressed: _finish,
              child: Text(l10n.t('login'), style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardData {
  const _OnboardData({required this.titleKey, required this.messageKey, required this.image});

  final String titleKey;
  final String messageKey;
  final String image;
}
