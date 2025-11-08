import 'package:flutter/material.dart';

class BookingNotifier extends ChangeNotifier {
  BookingNotifier({DateTime? selectedDate, this.timeSlots})
      : _selectedDate = selectedDate ?? DateTime.now();

  DateTime _selectedDate;
  String? _selectedSlot;
  final List<String>? timeSlots;

  DateTime get selectedDate => _selectedDate;
  String? get selectedSlot => _selectedSlot;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSlot(String slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void reset() {
    _selectedDate = DateTime.now();
    _selectedSlot = null;
    notifyListeners();
  }
}
