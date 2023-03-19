import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:rational/rational.dart';

dynamic decodeDate(String val){
  try{
    return DateTime.parse(val.substring(6));
  }
  catch(e){
    return val;
  }
}

dynamic decodeOid(String val){
  try{
    return ObjectId.fromHexString(val.substring(5));
  }
  catch(e){
    return val;
  }
}

dynamic decodeUuid(String val){
  try{
    return UuidValue.fromList(Uuid.parse(val.substring(6)));
  }
  catch(e){
    return val;
  }
}

dynamic decodeDecimal(String val){
  try{
    return Decimal.fromJson(val.substring(9));
  }
  catch(e){
    return val;
  }
}

dynamic decodeRational(String val){
  try{
    return Rational.parse(val.substring(10));
  }
  catch(e){
    return val;
  }
}

dynamic helper(dynamic key, dynamic value) {
  if (value is String){
    String str = value.trim();
    if(str.startsWith('\$oid:')){
      return decodeOid(str);
    }
    else if(str.startsWith('\$date:')){
      return decodeDate(str);
    }
    else if(str.startsWith('\$uuid:')){
      return decodeUuid(str);
    }
    else if(str.startsWith('\$decimal:')){
      return decodeDecimal(str);
    }
    else if(str.startsWith('\$rational:')){
      return decodeDecimal(str);
    }
  }
  return value;
}

class CustomJsonDecoder{

  static dynamic Decode(String json){
    return const JsonDecoder(helper).convert(json);
  }

}