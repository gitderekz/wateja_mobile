import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class SettingsProvider extends ChangeNotifier {
  String currencySymbol = 'TZS';
  String locale = 'en_US';

  String formatCurrency(num? value) {
    final v = value ?? 0;
    final fmt = NumberFormat.currency(locale: locale, symbol: '$currencySymbol ');
    return fmt.format(v);
  }

  void setCurrencySymbol(String symbol) {
    currencySymbol = symbol;
    notifyListeners();
  }

  void setLocale(String loc) {
    locale = loc;
    notifyListeners();
  }
}
