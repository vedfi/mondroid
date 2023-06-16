import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';

class DateTimeJsonHelper extends AbstractJsonHelper{
  
  @override
  decode(value) {
    return DateTime.parse((value as String).substring(6));
  }

  @override
  encode(value) {
    return '\$date:${(value as DateTime).toIso8601String()}';
  }

  @override
  bool isDecodable(value) {
    return value is String && value.startsWith('\$date:');
  }

  @override
  bool isEncodable(value) {
    return value is DateTime;
  }

}