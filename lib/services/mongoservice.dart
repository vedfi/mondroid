import 'dart:async';
import 'dart:convert';
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
      _lastConnectedUri = '';
      return false;
    }
  }

  Future<List<String>> getCollectionNames() async{
    try{
      var list = (await _database!.getCollectionNames()).where((element) => element != null).map((e) => e as String).toList();
      list.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return list;
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return Future<List<String>>.value(<String>[]);
    }
  }

  Future<int> getRecordCount(String collection) async{
    try{
      return await _database!.collection(collection).count();
    }
    catch(e){
      return -1;
    }
  }

  Future<void> createCollection(String name) async{
    try{
      var result = await _database!.createCollection(name);
      if(result.keys.any((element) => element == 'errmsg')){
        throw result['errmsg'].toString();
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<bool> deleteCollection(String name) async{
    try{
      return await _database!.dropCollection(name);
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> find(String collection, int page, int page_size, Map<String, dynamic> filter) async{
    try{
      if(page < 0){
        page = 0;
      }
      if(page_size <= 0){
        page_size = 1;
      }
      return await _database!.collection(collection).find(filter).skip(page).take(page_size).toList();
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return Future<List<Map<String,dynamic>>>.value(<Map<String,dynamic>>[]);
    }
  }
  
  Future<bool> deleteRecord(String collection, dynamic id) async{
    try{
      var result = await _database!.collection(collection).deleteOne({'_id':id});
      return result.isSuccess;
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<bool> insertRecord(String collection, dynamic data) async{
    try{
      await _database!.collection(collection).insert(data);
      return true;
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<bool> updateRecord(String collection, dynamic id, dynamic data) async{
    try{
      var result = await _database!.collection(collection).replaceOne({'_id':id}, data);
      if(result.hasWriteErrors){
        throw result.writeError!.errmsg!.toString();
      }
      return true;
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

}
