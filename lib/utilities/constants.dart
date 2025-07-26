import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

class Constants {
  static final Decimal decimalInfinity =
      Rational.parse('10000000000000000000000000000000000')
          .pow(10000)
          .toDecimal();
  static final Decimal decimalNegativeInfinity = -decimalInfinity;
}
