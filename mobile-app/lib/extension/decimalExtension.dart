import 'package:decimal/decimal.dart';

extension DecimalExtension on Decimal {
  double toDoubleAsFixed(int fractionDigits) {
    return double.parse(toStringAsFixed(fractionDigits));
  }
}
