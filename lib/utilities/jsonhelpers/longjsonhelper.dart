import 'package:fixnum/fixnum.dart';

import 'abstractjsonhelper.dart';

class LongJsonHelper extends AbstractJsonHelper {
  @override
  decode(value) {
    return Int64.tryParseInt((value as String).substring(6));
  }

  @override
  encode(value) {
    return '\$long:${(value as Int64).toString()}';
  }

  @override
  bool isDecodable(value) {
    return value is String && value.startsWith('\$long:');
  }

  @override
  bool isEncodable(value) {
    return value is Int64;
  }
}
