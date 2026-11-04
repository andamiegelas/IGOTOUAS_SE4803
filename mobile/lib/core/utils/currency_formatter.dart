import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(num value) {
    return _currencyFormat.format(value);
  }

  static String formatPercent(num value) {
    return '${value.toStringAsFixed(2)}%';
  }
}

