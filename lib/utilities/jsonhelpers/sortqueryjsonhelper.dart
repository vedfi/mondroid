import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';

class SortQueryHelper extends AbstractJsonHelper {
  @override
  decode(value) {
    String str = value as String;
    return str == '\$asc' ? 1 : -1;
  }

  @override
  encode(value) {
    return value;
  }

  @override
  bool isDecodable(value) {
    return value is String && (value == '\$asc' || value == '\$desc');
  }

  @override
  bool isEncodable(value) {
    return false;
  }
}
