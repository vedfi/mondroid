import 'dart:async';

import 'package:mondroid/services/popupservice.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoCollection {
  String name;
  String type;

  MongoCollection(this.name, this.type);
}

class MongoService {
  static final MongoService _mongoService = MongoService._internal();
  Db? _database;
  String _lastConnectedUri = '';

  factory MongoService() {
    return _mongoService;
  }

  MongoService._internal();

  Future<bool> connect(String uri) async {
    try {
      if (_database != null && _database!.isConnected) {
        if (_lastConnectedUri == uri) {
          return true;
        }
        await _database!.close();
      }
      _database = await Db.create(uri);
      await _database!.open();
      _lastConnectedUri = uri;
      return true;
    } catch (e) {
      PopupService.show(e.toString());
      _lastConnectedUri = '';
      return false;
    }
  }

  Future<void> reconnect() async {
    try {
      if ((_database == null || !(_database!.isConnected)) &&
          _lastConnectedUri.isNotEmpty) {
        await connect(_lastConnectedUri);
      }
    } catch (e) {
      PopupService.show("Reconnect Failed: $e");
    }
  }

  Future<List<MongoCollection>> getCollectionInfos() async {
    try {
      await reconnect();
      var collections = await _database!.getCollectionInfos();
      var list = collections
          .where((element) => element['name'] != null)
          .where((element) => element['type'] != null)
          .toList();
      list.sort((a, b) {
        var aType = a['type'];
        var bType = b['type'];
        if (aType != bType) {
          if (aType == 'view') {
            return -1;
          }
          if (bType == 'view') {
            return 1;
          }
        }
        return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      });
      return list.map((e) => MongoCollection(e['name'], e['type'])).toList();
    } catch (e) {
      PopupService.show(e.toString());
      return Future<List<MongoCollection>>.value(<MongoCollection>[]);
    }
  }

  Future<int> getRecordCount(String collection) async {
    try {
      await reconnect();
      return await _database!.collection(collection).count();
    } catch (e) {
      return -1;
    }
  }

  Future<void> createCollection(String name) async {
    try {
      await reconnect();
      var result = await _database!.createCollection(name);
      if (result.keys.any((element) => element == 'errmsg')) {
        throw result['errmsg'].toString();
      }
    } catch (e) {
      PopupService.show(e.toString());
    }
  }

  Future<bool> deleteCollection(String name) async {
    try {
      await reconnect();
      return await _database!.dropCollection(name);
    } catch (e) {
      PopupService.show(e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> find(
      String collection,
      int page,
      int pageSize,
      Map<String, dynamic>? filter,
      Map<String, Object>? sort) async {
    try {
      if (page < 0) {
        page = 0;
      }
      if (pageSize <= 0) {
        pageSize = 1;
      }
      await reconnect();
      return await _database!
          .collection(collection)
          .modernFind(filter: filter, sort: sort)
          .skip(page)
          .take(pageSize)
          .toList();
    } catch (e) {
      PopupService.show(e.toString());
      return Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[]);
    }
  }

  Future<bool> deleteRecord(String collection, dynamic id) async {
    try {
      await reconnect();
      var result =
          await _database!.collection(collection).deleteOne({'_id': id});
      return result.isSuccess;
    } catch (e) {
      PopupService.show(e.toString());
      return false;
    }
  }

  Future<bool> insertRecord(String collection, dynamic data) async {
    try {
      await reconnect();
      await _database!.collection(collection).insert(data);
      return true;
    } catch (e) {
      PopupService.show(e.toString());
      return false;
    }
  }

  Future<bool> updateRecord(String collection, dynamic id, dynamic data) async {
    try {
      await reconnect();
      var result =
          await _database!.collection(collection).replaceOne({'_id': id}, data);
      if (result.hasWriteErrors) {
        throw result.writeError!.errmsg!.toString();
      }
      return true;
    } catch (e) {
      PopupService.show(e.toString());
      return false;
    }
  }
}
