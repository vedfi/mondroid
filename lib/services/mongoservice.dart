import 'dart:async';
import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MongoService{
  static final MongoService _mongoService = MongoService._internal();
  Db? _database = null;
  String _lastConnectedUri = '';
  factory MongoService() {
    return _mongoService;
  }
  MongoService._internal();

  Future<bool> connect(String uri) async{
    try{
      if(_database != null && _database!.isConnected){
        if(_lastConnectedUri == uri){
          return true;
        }
        await _database!.close();
      }
      _database = await Db.create(uri);
      await _database!.open();
      _lastConnectedUri = uri;
      return true;
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
    return false;
  }

  Future<List<String>> getCollectionNames() async{
    try{
      if(_database!.isConnected){
        var list = (await _database!.getCollectionNames()).where((element) => element != null).map((e) => e as String).toList();
        list.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
        return list;
      }
      else{
        return Future<List<String>>.value(<String>[]);
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return Future<List<String>>.value(<String>[]);
    }
  }

  Future<int> getRecordCount(String collection) async{
    try{
      if(_database!.isConnected){
        return await _database!.collection(collection).count();
      }
      return 0;
    }
    catch(e){
      return -1;
    }
  }

  Future<void> createCollection(String name) async{
    try{
      if(_database!.isConnected){
        var result = await _database!.createCollection(name);
        if(result.keys.any((element) => element == 'errmsg')){
          throw result['errmsg'].toString();
        }
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<bool> deleteCollection(String name) async{
    try{
      if(_database!.isConnected){
        return await _database!.dropCollection(name);
      }
      return false;
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> find(String collection, int page, int page_size) async{
    try{
      if(page < 0){
        page = 0;
      }
      if(page_size <= 0){
        page_size = 1;
      }
      if(_database!.isConnected){
        return await _database!.collection(collection).find().skip(page).take(page_size).toList();
      }
      return Future<List<Map<String,dynamic>>>.value(<Map<String,dynamic>>[]);
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return Future<List<Map<String,dynamic>>>.value(<Map<String,dynamic>>[]);
    }
  }
}
