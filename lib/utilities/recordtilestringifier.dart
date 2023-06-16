import 'package:decimal/decimal.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RecordTileStringifier{

  static String stringify(dynamic value) {
    if(value is Decimal){
      if(value == infinityValue){
        return double.infinity.toString();
      }
      else if(value == -infinityValue){
        return double.negativeInfinity.toString();
      }
    }
    return value.toString();
  }

}