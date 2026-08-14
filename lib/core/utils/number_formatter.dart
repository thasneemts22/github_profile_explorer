import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();

  static String formatCompact(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final k = number / 1000.0;
      if (k >= 100) {
        return '${k.toStringAsFixed(0)}k';
      }
      final formatted = k.toStringAsFixed(1);
      return formatted.endsWith('.0') ? '${k.toInt()}k' : '${formatted}k';
    } else {
      final m = number / 1000000.0;
      final formatted = m.toStringAsFixed(1);
      return formatted.endsWith('.0') ? '${m.toInt()}M' : '${formatted}M';
    }
  }

  static String formatStandard(int number) {
    return NumberFormat('#,###').format(number);
  }
}
