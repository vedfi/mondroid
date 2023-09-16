import 'dart:convert';

import 'package:mondroid/services/popupservice.dart';
import 'package:mondroid/utilities/jsonhelpers/datetimejsonhelper.dart';
import 'package:mondroid/utilities/jsonhelpers/decimaljsonhelper.dart';
import 'package:mondroid/utilities/jsonhelpers/doublejsonhelper.dart';
import 'package:mondroid/utilities/jsonhelpers/objectidjsonhelper.dart';
import 'package:mondroid/utilities/jsonhelpers/rationaljsonhelper.dart';
import 'package:mondroid/utilities/jsonhelpers/uuidjsonhelper.dart';

import 'jsonhelpers/abstractjsonhelper.dart';

encodeHelper(dynamic value) {
  try {
    for (var helper in JsonConverter.helpers) {
      if (helper.isEncodable(value)) {
        return helper.encode(value);
      }
    }
    return value;
  } catch (e) {
    PopupService.show(e.toString());
    return "undefined";
  }
}

decodeHelper(dynamic key, dynamic value) {
  try {
    value = value is String ? value.trim() : value;
    for (var helper in JsonConverter.helpers) {
      if (helper.isDecodable(value)) {
        return helper.decode(value);
      }
    }
    return value;
  } catch (e) {
    PopupService.show(e.toString());
    return "undefined";
  }
}

class JsonConverter {
  static List<AbstractJsonHelper> helpers = List.unmodifiable([
    ObjectIdJsonHelper(),
    DateTimeJsonHelper(),
    UUIDJsonHelper(),
    DecimalJsonHelper(),
    RationalJsonHelper(),
    DoubleJsonHelper()
  ]);

  static String encode(dynamic object) {
    return const JsonEncoder.withIndent('   ', encodeHelper)
        .convert(object)
        .toString();
  }

  static dynamic decode(String json) {
    return const JsonDecoder(decodeHelper).convert(json);
  }
}
