import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UUIDJsonHelper extends AbstractJsonHelper {
  @override
  decode(value) {
    return UuidValue.fromList(Uuid.parse((value as String).substring(6)));
  }

  @override
  encode(value) {
    return '\$uuid:${(value as UuidValue).uuid}';
  }

  @override
  bool isDecodable(value) {
    return value is String && value.startsWith('\$uuid:');
  }

  @override
  bool isEncodable(value) {
    return value is UuidValue;
  }
}
