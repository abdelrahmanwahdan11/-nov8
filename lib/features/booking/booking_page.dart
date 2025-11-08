import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/booking_notifier.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late BookingNotifier booking;
  late List<String> slots;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scope = AppScope.of(context);
      setState(() {
        booking = scope.bookingNotifier;
        slots = booking.timeSlots ?? _defaultSlots();
      });
    });
  }

  List<String> _defaultSlots() {
    return const [
      '09:00',
      '11:00',
      '13:00',
      '15:00',
      '17:00',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    booking = scope.bookingNotifier;
    slots = booking.timeSlots ?? _defaultSlots();
    final now = DateTime.now();
    final days = List.generate(30, (i) => DateTime(now.year, now.month, now.day + i));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('book_now'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('calendar'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isSelected = _isSameDay(day, booking.selectedDate);
                  return GestureDetector(
                    onTap: () => setState(() => booking.setDate(day)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${day.day}', style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_weekday(day), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.t('time_slots'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: slots
                  .map(
                    (slot) => ChoiceChip(
                      label: Text(slot),
                      selected: booking.selectedSlot == slot,
                      onSelected: (_) => setState(() => booking.setSlot(slot)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: booking.selectedSlot == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('confirm_booking'))));
                      },
                child: Text(l10n.t('confirm_booking')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekday(DateTime date) {
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return names[date.weekday % 7];
  }
}
