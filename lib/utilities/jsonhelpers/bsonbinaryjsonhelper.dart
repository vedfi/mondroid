import 'package:mongo_dart/mongo_dart.dart';

import 'abstractjsonhelper.dart';

class BsonBinaryJsonHelper extends AbstractJsonHelper {
  @override
  decode(value) {
    List<String> parts = (value as String).substring(8).split('_');
    int type = int.parse(parts.elementAt(0));
    return BsonBinary.fromHexString(parts.elementAt(1), subType: type);
  }

  @override
  encode(value) {
    BsonBinary bin = value is LegacyUuid ? (value.bsonBinary) : value as BsonBinary;
    return '\$binary:${bin.subType}_${bin.hexString}';
  }

  @override
  bool isDecodable(value) {
    return value is String && value.startsWith('\$binary:');
  }

  @override
  bool isEncodable(value) {
    return value is LegacyUuid || value is BsonBinary;
  }
}
