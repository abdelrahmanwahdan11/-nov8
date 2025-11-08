import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/booking_notifier.dart';

enum _BookingFocus { pickup, returnDate }

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  BookingNotifier? _booking;
  _BookingFocus _focus = _BookingFocus.pickup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    final notifier = scope.bookingNotifier;
    if (_booking != notifier) {
      _booking = notifier;
    }
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
    final booking = _booking ??= AppScope.of(context).bookingNotifier;
    final l10n = AppLocalizations.of(context);
    final materialLocalizations = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final slots = booking.timeSlots ?? _defaultSlots();
    final now = DateTime.now();
    final days = List.generate(30, (i) => DateTime(now.year, now.month, now.day + i));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('book_now'))),
      body: AnimatedBuilder(
        animation: booking,
        builder: (context, _) {
          final start = booking.selectedDate;
          final end = booking.returnDate;
          final rangeSummary = l10n
              .t('booking_range_label')
              .replaceFirst('%s', materialLocalizations.formatMediumDate(start))
              .replaceFirst('%s', materialLocalizations.formatMediumDate(end));
          final slotSummary = booking.selectedSlot != null
              ? l10n.t('booking_slot_label').replaceFirst('%s', booking.selectedSlot!)
              : null;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('calendar'), style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(l10n.t('pick_date')),
                      selected: _focus == _BookingFocus.pickup,
                      onSelected: (_) => setState(() => _focus = _BookingFocus.pickup),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(l10n.t('return_date')),
                      selected: _focus == _BookingFocus.returnDate,
                      onSelected: (_) => setState(() => _focus = _BookingFocus.returnDate),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _focus = _BookingFocus.pickup);
                        booking.reset();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.t('reset_selection')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _focus == _BookingFocus.pickup
                        ? l10n.t('select_pick_date')
                        : l10n.t('select_return_date'),
                    key: ValueKey(_focus),
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isStart = _isSameDay(day, start);
                      final isEnd = _isSameDay(day, end);
                      final inRange = day.isAfter(start) && day.isBefore(end);
                      final isActive = isStart || isEnd;
                      final background = isActive
                          ? theme.colorScheme.primary
                          : inRange
                              ? theme.colorScheme.primary.withOpacity(0.12)
                              : theme.colorScheme.surface;
                      final textColor = isActive
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
                      final subColor = isActive ? Colors.white70 : Colors.grey;
                      return GestureDetector(
                        onTap: () {
                          if (_focus == _BookingFocus.pickup) {
                            booking.setDate(day);
                            setState(() => _focus = _BookingFocus.returnDate);
                          } else {
                            booking.setReturnDate(day);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? (isStart
                                      ? theme.colorScheme.onPrimary.withOpacity(0.85)
                                      : theme.colorScheme.onPrimary.withOpacity(0.75))
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _weekday(context, day),
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.t('time_slots'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final slot in slots)
                      ChoiceChip(
                        label: Text(slot),
                        selected: booking.selectedSlot == slot,
                        onSelected: (_) => booking.setSlot(slot),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.t('book_summary'), style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rangeSummary, style: theme.textTheme.bodyLarge),
                      if (slotSummary != null) ...[
                        const SizedBox(height: 6),
                        Text(slotSummary, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (booking.selectedSlot == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(l10n.t('booking_select_slot'))));
                        return;
                      }
                      final slotText = l10n.t('booking_slot_label').replaceFirst('%s', booking.selectedSlot!);
                      final message = '${l10n.t('booking_saved')} · $rangeSummary • $slotText';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                    },
                    child: Text(l10n.t('confirm_booking')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekday(BuildContext context, DateTime date) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.narrowWeekdays[(date.weekday - 1) % 7];
  }
}
