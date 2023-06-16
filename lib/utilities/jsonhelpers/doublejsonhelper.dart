import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';

class DoubleJsonHelper extends AbstractJsonHelper {

  @override
  decode(value) {
    String str = value as String;
    if (str.startsWith('\$doubleInfinity')) {
      return double.infinity;
    } else if (str.startsWith('\$doubleNegativeInfinity')) {
      return double.negativeInfinity;
    } else if (str.startsWith('\$doubleNaN')) {
      return double.nan;
    }
  }

  @override
  encode(value) {
    if (value == double.infinity) {
      return '\$doubleInfinity';
    } else if (value == double.negativeInfinity) {
      return '\$doubleNegativeInfinity';
    } else if (identical(value, double.nan)) {
      return '\$doubleNaN';
    }
  }

  @override
  bool isDecodable(value) {
    return value is String &&
        (value.startsWith('\$doubleInfinity') ||
            value.startsWith('\$doubleNegativeInfinity') ||
            value.startsWith('\$doubleNaN'));
  }

  @override
  bool isEncodable(value) {
    return value == double.infinity ||
        value == double.negativeInfinity ||
        identical(value, double.nan);
  }
}
