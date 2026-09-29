import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/services/popupservice.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Connection;

class MongoCollection {
  String name;
  String type;

  MongoCollection(this.name, this.type);
}

class MongoService {
  static final MongoService _mongoService = MongoService._internal();
  Db? _database;
  Connection? _lastConnection;
  SSHClient? _sshClient;
  ServerSocket? _localServer;

  factory MongoService() {
    return _mongoService;
  }

  MongoService._internal();

  Future<void> _closeSshTunnel() async {
    try {
      await _localServer?.close();
    } catch (_) {}
    _localServer = null;

    try {
      _sshClient?.close();
    } catch (_) {}
    _sshClient = null;
  }

  Future<String> _setupSshTunnel(Connection connection) async {
    final sshConfig = connection.sshConfig;
    if (sshConfig == null) {
      return connection.uri;
    }

    final parsedUri = Uri.parse(connection.uri);
    final targetHost = parsedUri.host.isEmpty ? '127.0.0.1' : parsedUri.host;
    final targetPort = parsedUri.hasPort ? parsedUri.port : 27017;

    final socket = await SSHSocket.connect(
      sshConfig.host,
      sshConfig.port,
      timeout: const Duration(seconds: 15),
    );

    switch (sshConfig.auth) {
      case SshPasswordAuth auth:
        _sshClient = SSHClient(
          socket,
          username: sshConfig.username,
          onPasswordRequest: () => auth.password,
        );
      case SshPrivateKeyAuth auth:
        List<SSHKeyPair> keyPairs;
        if (auth.passphrase.isNotEmpty) {
          keyPairs = SSHKeyPair.fromPem(
            auth.privateKey,
            auth.passphrase,
          );
        } else {
          keyPairs = SSHKeyPair.fromPem(auth.privateKey);
        }

        _sshClient = SSHClient(
          socket,
          username: sshConfig.username,
          identities: keyPairs,
        );
    }

    await _sshClient!.authenticated;

    _localServer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final localPort = _localServer!.port;

    _localServer!.listen((clientSocket) async {
      try {
        final forwardChannel =
            await _sshClient!.forwardLocal(targetHost, targetPort);
        clientSocket.listen(
          forwardChannel.sink.add,
          onDone: () => forwardChannel.close(),
          onError: (_) => forwardChannel.close(),
        );
        forwardChannel.stream.listen(
          clientSocket.add,
          onDone: () => clientSocket.close(),
          onError: (_) => clientSocket.close(),
        );
      } catch (e) {
        clientSocket.close();
      }
    });

    final newUri = parsedUri.replace(
      host: '127.0.0.1',
      port: localPort,
    );
    return newUri.toString();
  }

  Future<bool> connect(Connection connection) async {
    try {
      if (_database != null && _database!.isConnected) {
        if (_lastConnection == connection) {
          return true;
        }
        await _database!.close();
        await _closeSshTunnel();
      } else {
        await _closeSshTunnel();
      }

      String targetUri = connection.uri;
      if (connection.sshConfig != null) {
        targetUri = await _setupSshTunnel(connection);
      }

      _database = await Db.create(targetUri);
      await _database!.open();
      _lastConnection = connection;
      return true;
    } catch (e) {
      await _closeSshTunnel();
      PopupService.show(e.toString());
      _lastConnection = null;
      return false;
    }
  }

  Future<void> reconnect() async {
    try {
      if ((_database == null || !(_database!.isConnected)) &&
          _lastConnection != null) {
        await connect(_lastConnection!);
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

  Future<int> count(String collection, Map<String, dynamic>? filter) async {
    try {
      await reconnect();
      return await _database!
          .collection(collection)
          .modernFind(filter: filter)
          .length;
    } catch (e) {
      PopupService.show(e.toString());
      return Future<int>.value(0);
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

  Future<bool> deleteRecords(String collection, List<dynamic> ids) async {
    if (ids.isEmpty) return false;
    try {
      await reconnect();
      var result = await _database!.collection(collection).deleteMany({
        '_id': {'\$in': ids}
      });
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
