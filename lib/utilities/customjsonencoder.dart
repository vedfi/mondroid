import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

dynamic helper(dynamic item) {
  if (item is DateTime) {
    return '_date_'+item.toIso8601String();
  }
  else if(item is ObjectId){
    return '_id_'+item.$oid;
  }
  return item;
}

class CustomJsonEncoder{

  static JsonEncoder GetEncoder() => JsonEncoder.withIndent('   ', helper);

  static String Encode(dynamic object){
    return GetEncoder().convert(object).toString();
  }

}