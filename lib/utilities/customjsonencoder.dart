import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:rational/rational.dart';

dynamic helper(dynamic item) {
  if (item is DateTime) {
    return '\$date:'+item.toIso8601String();
  }
  else if(item is ObjectId){
    return '\$oid:'+item.$oid;
  }
  else if(item is UuidValue){
    return '\$uuid:'+item.uuid;
  }
  else if(item is Rational){
    return '\$decimal:'+item.toDecimalString();
  }
  return item;
}

class CustomJsonEncoder{

  static String Encode(dynamic object){
    return JsonEncoder.withIndent('   ', helper).convert(object).toString();
  }

}