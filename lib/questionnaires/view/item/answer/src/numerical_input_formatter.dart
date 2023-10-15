import 'package:faiadashu/logging/logging.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// An input formatter for internationalized input of numbers.
class NumericalTextInputFormatter extends TextInputFormatter {
  static final _logger = Logger(NumericalTextInputFormatter);
  final NumberFormat numberFormat;

  NumericalTextInputFormatter(this.numberFormat);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || newValue.text == oldValue.text) {
      return newValue;
    }

    // Whitespace is otherwise not prevented.
    if (newValue.text.trim() != newValue.text) {
      return oldValue;
    }

    // Group separator is causing lots of trouble. Suppress.
    if (newValue.text.contains(numberFormat.symbols.GROUP_SEP)) {
      return oldValue;
    }

    // NumberFormat.parse is not preventing decimal points on integers.
    if (newValue.text.contains(numberFormat.symbols.DECIMAL_SEP) &&
        numberFormat.maximumFractionDigits == 0) {
      return oldValue;
    }

    try {
      final parsed = numberFormat.parse(newValue.text);

      // Parsed numbers always contain decimals (12 -> 12.0, 12.3 -> 12.3)
      final decimals = parsed.toString().split('.')[1];
      if (decimals != '0' && decimals.length > numberFormat.maximumFractionDigits) return oldValue;

      _logger.trace('parsed: ${newValue.text} -> $parsed');

      return newValue;
    } catch (_) {
      return oldValue;
    }
  }
}
