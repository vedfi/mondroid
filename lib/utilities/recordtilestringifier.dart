import 'package:decimal/decimal.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
    if(value is LegacyUuid){
      return value.bsonBinary.toString();
    }
    return value.toString();
  }
}
