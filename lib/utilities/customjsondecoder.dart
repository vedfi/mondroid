import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

dynamic objectIdHelper(String val){
  String str = val.trim();
  if(str.length == 28 && str.startsWith('_id_')){
    return ObjectId.fromHexString(str.substring(4));
  }
  return val;
}
dynamic dateTimeHelper(String val){
  String str = val.trim();
  if(str.length > 6 && str.startsWith('_date_')){
    return DateTime.parse(str.substring(6));
  }
  return val;
}
bool isDateTime(String val){
  String str = val.trim();//6
  return str.length > 6 && str.startsWith('_date_');
}
bool isObjectId(String val){
  String str = val.trim();
  return str.length == 28 && str.startsWith('_id_');
}
void objectIdDecoder(Map<String, dynamic> data){
  for(var key in data.keys){
    if(data[key] is String){
      data[key] = objectIdHelper(data[key]);
    }
    else if(data[key] is Iterable<String> && data[key].isNotEmpty && data[key].any((element) => isObjectId(element))){
      List<ObjectId> fixed = <ObjectId>[];
      for(var val in data[key]){
        fixed.add(objectIdHelper(val));
      }
      if(fixed.isNotEmpty){
        data[key] = fixed;
      }
    }
    else if(data[key] is Map<String,dynamic>){
      objectIdDecoder(data[key]);
    }
  }
}
void dateTimeDecoder(Map<String, dynamic> data){
  for(var key in data.keys){
    if(data[key] is String){
      data[key] = dateTimeHelper(data[key]);
    }
    else if(data[key] is Iterable<String> && data[key].isNotEmpty && data[key].any((element) => isDateTime(element))){
      List<DateTime> fixed = <DateTime>[];
      for(var val in data[key]){
        fixed.add(dateTimeHelper(val));
      }
      if(fixed.isNotEmpty){
        data[key] = fixed;
      }
    }
    else if(data[key] is Map<String,dynamic>){
      dateTimeDecoder(data[key]);
    }
  }
}

class CustomJsonDecoder{

  static dynamic Decode(String json){
    var obj = JsonDecoder().convert(json);
    objectIdDecoder(obj);
    dateTimeDecoder(obj);
    return obj;
  }

}