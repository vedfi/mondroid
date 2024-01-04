import 'package:decimal/decimal.dart';
import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';
import '../constants.dart';

class DecimalJsonHelper extends AbstractJsonHelper {
  @override
  decode(value) {
    String str = value as String;
    if (str.startsWith('\$decimalInfinity')) {
      return Constants.decimalInfinity;
    } else if (str.startsWith('\$decimalNegativeInfinity')) {
      return Constants.decimalNegativeInfinity;
    } else {
      return Decimal.fromJson(str.substring(9));
    }
  }

  @override
  encode(value) {
    Decimal num = value as Decimal;
    if (num == Constants.decimalInfinity) {
      return '\$decimalInfinity';
    } else if (num == Constants.decimalNegativeInfinity) {
      return '\$decimalNegativeInfinity';
    }
    return '\$decimal:$num';
  }

  @override
  bool isDecodable(value) {
    return value is String &&
        (value.startsWith('\$decimal:') ||
            value.startsWith('\$decimalInfinity') ||
            value.startsWith('\$decimalNegativeInfinity'));
  }

  @override
  bool isEncodable(value) {
    return value is Decimal;
  }
}
