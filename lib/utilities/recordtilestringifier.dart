import 'package:decimal/decimal.dart';

import 'constants.dart';

class RecordTileStringifier {
  static String stringify(dynamic value) {
    if (value is Decimal) {
      if (value == Constants.decimalInfinity) {
        return double.infinity.toString();
      } else if (value == Constants.decimalNegativeInfinity) {
        return double.negativeInfinity.toString();
      }
    }
    return value.toString();
  }
}
