import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceController extends TextEditingController {
  bool _isFormatting = false;

  double get rawValue {
    String clean = text.replaceAll('.', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  void formatInput() {
    if (_isFormatting) return;
    _isFormatting = true;

    final oldText = text;
    final oldSelection = selection.baseOffset;

    // Clean số
    String digits = oldText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) digits = "0";

    final number = double.tryParse(digits) ?? 0;

    // Format lại
    final newText = NumberFormat.decimalPattern('vi_VN').format(number);

    // Tính lại vị trí con trỏ
    final diff = newText.length - oldText.length;
    final newCursorPos = (oldSelection + diff).clamp(0, newText.length);

    // Gán lại
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );

    _isFormatting = false;
  }
}
