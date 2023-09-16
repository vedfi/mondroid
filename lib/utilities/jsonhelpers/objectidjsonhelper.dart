import 'package:mondroid/utilities/jsonhelpers/abstractjsonhelper.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ObjectIdJsonHelper extends AbstractJsonHelper {
  @override
  decode(value) {
    return ObjectId.fromHexString((value as String).substring(5));
  }

  @override
  encode(value) {
    return '\$oid:${(value as ObjectId).$oid}';
  }

  @override
  bool isDecodable(value) {
    return value is String && value.startsWith('\$oid:');
  }

  @override
  bool isEncodable(value) {
    return value is ObjectId;
  }
}
