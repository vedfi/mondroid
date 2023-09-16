abstract class AbstractJsonHelper {
  bool isEncodable(dynamic value);

  bool isDecodable(dynamic value);

  dynamic encode(dynamic value);

  dynamic decode(dynamic value);
}
