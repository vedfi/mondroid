import 'dart:convert';
import 'package:decimal/decimal.dart';
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
  else if(item is Decimal){
    return '\$decimal:'+item.toString();
  }
  else if(item is Rational){
    return '\$rational:'+item.toString();
  }

  return item;
}

class CustomJsonEncoder{

  static String Encode(dynamic object){
    return const JsonEncoder.withIndent('   ', helper).convert(object).toString();
  }

}