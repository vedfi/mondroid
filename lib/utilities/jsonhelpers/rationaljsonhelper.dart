import 'package:decimal/decimal.dart';
import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';
import 'package:rational/rational.dart';

class RationalJsonHelper extends AbstractJsonHelper{

  @override
  decode(value) {
    return Rational.parse((value as String).substring(10));
  }

  @override
  encode(value) {
    return '\$rational:${value as Rational}';
  }

  @override
  bool isDecodable(value) {
    return value is String && value.startsWith('\$rational:');
  }

  @override
  bool isEncodable(value) {
    return value is! Decimal && value is Rational;
  }

}