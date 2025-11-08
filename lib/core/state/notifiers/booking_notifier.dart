import 'dart:async';

import 'package:flutter/material.dart';

import 'package:neoestate_fusion_v2/data/services_local/preferences_service.dart';

class BookingNotifier extends ChangeNotifier {
  BookingNotifier({
    required this.preferences,
    DateTime? selectedDate,
    DateTime? returnDate,
    String? selectedSlot,
    this.timeSlots,
  })  : _selectedDate = selectedDate ?? DateTime.now(),
        _returnDate = returnDate ?? selectedDate ?? DateTime.now(),
        _selectedSlot = selectedSlot;

  final PreferencesService preferences;

  DateTime _selectedDate;
  DateTime _returnDate;
  String? _selectedSlot;
  final List<String>? timeSlots;

  DateTime get selectedDate => _selectedDate;
  DateTime get returnDate => _returnDate;
  String? get selectedSlot => _selectedSlot;

  void setDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    _selectedDate = normalized;
    if (_returnDate.isBefore(normalized)) {
      _returnDate = normalized;
    }
    _persist();
  }

  void setReturnDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized.isBefore(_selectedDate)) {
      _selectedDate = normalized;
    }
    _returnDate = normalized.isBefore(_selectedDate) ? _selectedDate : normalized;
    _persist();
  }

  void setSlot(String slot) {
    _selectedSlot = slot;
    _persist();
  }

  void reset() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _returnDate = _selectedDate;
    _selectedSlot = null;
    _persist();
  }

  void _persist() {
    unawaited(
      preferences.saveLastBookingSelection(
        start: _selectedDate,
        end: _returnDate,
        slot: _selectedSlot,
      ),
    );
    notifyListeners();
  }
}
