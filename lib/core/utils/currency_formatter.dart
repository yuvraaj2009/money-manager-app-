import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 2,
  );

  static final _indianFormatNoDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  /// Format as ₹1,49,400.00
  static String format(double amount) {
    return _indianFormat.format(amount);
  }

  /// Format as ₹1,49,400
  static String formatCompact(double amount) {
    return _indianFormatNoDecimal.format(amount);
  }

  /// Format with + or - prefix
  static String formatSigned(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_indianFormat.format(amount)}';
  }
}
