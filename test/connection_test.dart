import 'package:flutter_test/flutter_test.dart';
import 'package:mondroid/models/connection.dart';

void main() {
  group('Connection model tests', () {
    test('Connection without SSH defaults', () {
      final conn = Connection('Test Mongo', 'mongodb://localhost:27017/db');

      expect(conn.name, 'Test Mongo');
      expect(conn.uri, 'mongodb://localhost:27017/db');
      expect(conn.sshConfig, null);
    });

    test('Connection with password SSH serialization and deserialization', () {
      final conn = Connection(
        'SSH Mongo Password',
        'mongodb://user:pass@127.0.0.1:27017/mydb',
        sshConfig: SshConfig(
          host: '192.168.1.100',
          port: 2222,
          username: 'sshuser',
          auth: const SshPasswordAuth(password: 'sshpassword'),
        ),
      );

      final json = conn.toJson();
      expect(json['name'], 'SSH Mongo Password');
      expect(json['sshConfig'], isNotNull);
      expect(json['sshConfig']['host'], '192.168.1.100');
      expect(json['sshConfig']['port'], 2222);
      expect(json['sshConfig']['username'], 'sshuser');
      expect(json['sshConfig']['auth']['type'], 'password');
      expect(json['sshConfig']['auth']['password'], 'sshpassword');

      final deserialized = Connection.fromJson(json);
      expect(deserialized.name, 'SSH Mongo Password');
      expect(deserialized.sshConfig, isNotNull);
      expect(deserialized.sshConfig!.host, '192.168.1.100');
      expect(deserialized.sshConfig!.port, 2222);
      expect(deserialized.sshConfig!.username, 'sshuser');
      expect(deserialized.sshConfig!.auth, isA<SshPasswordAuth>());
      expect((deserialized.sshConfig!.auth as SshPasswordAuth).password, 'sshpassword');
    });

    test('Connection with private key SSH serialization and deserialization', () {
      final conn = Connection(
        'SSH Mongo Key',
        'mongodb://127.0.0.1:27017/mydb',
        sshConfig: SshConfig(
          host: 'example.com',
          port: 22,
          username: 'root',
          auth: const SshPrivateKeyAuth(
            privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----',
            passphrase: 'keypassphrase',
          ),
        ),
      );

      final json = conn.toJson();
      expect(json['sshConfig']['auth']['type'], 'privateKey');
      expect(json['sshConfig']['auth']['privateKey'], contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(json['sshConfig']['auth']['passphrase'], 'keypassphrase');

      final deserialized = Connection.fromJson(json);
      expect(deserialized.sshConfig!.auth, isA<SshPrivateKeyAuth>());
      final keyAuth = deserialized.sshConfig!.auth as SshPrivateKeyAuth;
      expect(keyAuth.privateKey, contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(keyAuth.passphrase, 'keypassphrase');
    });

    test('Connection without SSH config deserialization', () {
      final json = {
        'name': 'Old Connection',
        'uri': 'mongodb://localhost:27017/test',
      };
      final conn = Connection.fromJson(json);
      expect(conn.name, 'Old Connection');
      expect(conn.sshConfig, null);
    });

    test('Mask connection string password', () {
      final conn = Connection(
        'Test',
        'mongodb://dbuser:dbpass123@cluster.mongodb.net/test',
      );

      expect(conn.getMaskedConnectionString(),
          'mongodb://dbuser:*****@cluster.mongodb.net/test');
    });

    test('Connection equality comparison using Equatable', () {
      final conn1 = Connection(
        'Test Mongo',
        'mongodb://localhost:27017/db',
        sshConfig: SshConfig(
          host: '1.2.3.4',
          port: 22,
          username: 'user',
          auth: const SshPasswordAuth(password: 'pass'),
        ),
      );

      final conn2 = Connection(
        'Test Mongo',
        'mongodb://localhost:27017/db',
        sshConfig: SshConfig(
          host: '1.2.3.4',
          port: 22,
          username: 'user',
          auth: const SshPasswordAuth(password: 'pass'),
        ),
      );

      final conn3 = Connection(
        'Test Mongo',
        'mongodb://localhost:27017/db',
        sshConfig: SshConfig(
          host: '1.2.3.4',
          port: 22,
          username: 'user',
          auth: const SshPasswordAuth(password: 'different_pass'),
        ),
      );

      expect(conn1, equals(conn2));
      expect(conn1, isNot(equals(conn3)));
    });
  });
}
