import 'package:flutter/services.dart';

String formatVnd(num? amount) {
  final value = amount ?? 0;
  final raw = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  final parts = raw.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );

  if (parts.length == 1) {
    return '$whole VNĐ';
  }

  final fraction = parts.last.replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? '$whole VNĐ' : '$whole,$fraction VNĐ';
}

String formatMoneyInput(num? amount) {
  if (amount == null || amount == 0) return '';
  return formatMoneyInputText(amount.round().toString());
}

String formatMoneyInputText(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  return digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatMoneyInputText(newValue.text);
    final digitCountBeforeCursor = newValue.text
        .substring(0, newValue.selection.extentOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    final cursorOffset = _offsetAfterDigitCount(
      formatted,
      digitCountBeforeCursor,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  int _offsetAfterDigitCount(String text, int digitCount) {
    if (digitCount <= 0) return 0;

    var seenDigits = 0;
    for (var index = 0; index < text.length; index++) {
      if (RegExp(r'\d').hasMatch(text[index])) {
        seenDigits++;
        if (seenDigits == digitCount) {
          return index + 1;
        }
      }
    }

    return text.length;
  }
}
