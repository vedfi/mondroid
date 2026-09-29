import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/services/popupservice.dart';
import 'package:mondroid/services/settingsservice.dart';
import 'package:mondroid/services/storageservice.dart';
import 'package:mondroid/utilities/formsheet.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/connectiontile.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/selectable.dart';
import '../widgets/connectionform.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isLoading = false;
  bool maskPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uriController = TextEditingController();
  bool _useSsh = false;
  final TextEditingController _sshHostController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _sshUsernameController = TextEditingController();
  SshAuthMode _sshAuthMode = SshAuthMode.password;
  final TextEditingController _sshPasswordController = TextEditingController();
  final TextEditingController _sshPrivateKeyController = TextEditingController();
  final TextEditingController _sshPassphraseController = TextEditingController();

  List<Selectable<Connection>> connections = <Selectable<Connection>>[];
  final Uri _url =
      Uri.parse('https://vedfi.github.io/mondroid/help/connections');

  void reorder(int oldIndex, int newIndex) {
    setState(() {
      newIndex -= oldIndex < newIndex ? 1 : 0;
      final Selectable<Connection> item = connections.removeAt(oldIndex);
      connections.insert(newIndex, item);
    });
    saveConnections();
  }

  Future<void> openUrl() async {
    if (!await launchUrl(_url)) {
      PopupService.show('Could not launch $_url');
    }
  }

  Future<void> deleteDialog() async {
    bool? delete = await showDialog(
        context: context,
        builder: (ctx) {
          return ConfirmDialog.create(
              context,
              'Delete Connection(s)',
              'This action cannot be undone. Are you sure you want to continue?',
              'Cancel',
              'Delete',
              true);
        });
    if (delete == true) {
      setState(() {
        connections.removeWhere((element) => element.isSelected);
      });
      saveConnections();
    } else {
      setState(() {
        for (var element in connections) {
          element.isSelected = false;
        }
      });
    }
  }

  Future<void> addOrEditDialog(bool isAddDialog) async {
    int index = -1;
    _nameController.clear();
    _uriController.clear();
    _useSsh = false;
    _sshHostController.clear();
    _sshPortController.text = "22";
    _sshUsernameController.clear();
    _sshAuthMode = SshAuthMode.password;
    _sshPasswordController.clear();
    _sshPrivateKeyController.clear();
    _sshPassphraseController.clear();

    if (!isAddDialog) {
      for (int i = 0; i < connections.length; i++) {
        if (connections[i].isSelected) {
          index = i;
          final conn = connections[i].item;
          _nameController.text = conn.name;
          _uriController.text = conn.uri;
          if (conn.sshConfig != null) {
            final cfg = conn.sshConfig!;
            _useSsh = true;
            _sshHostController.text = cfg.host;
            _sshPortController.text = cfg.port.toString();
            _sshUsernameController.text = cfg.username;
            switch (cfg.auth) {
              case SshPasswordAuth passwordAuth:
                _sshAuthMode = SshAuthMode.password;
                _sshPasswordController.text = passwordAuth.password;
              case SshPrivateKeyAuth keyAuth:
                _sshAuthMode = SshAuthMode.privateKey;
                _sshPrivateKeyController.text = keyAuth.privateKey;
                _sshPassphraseController.text = keyAuth.passphrase;
            }
          }
          break;
        }
      }
    }

    Connection buildConnectionToSave() {
      final port = int.tryParse(_sshPortController.text) ?? 22;
      SshConfig? sshCfg;
      if (_useSsh) {
        final SshAuth auth = _sshAuthMode == SshAuthMode.password
            ? SshPasswordAuth(password: _sshPasswordController.text)
            : SshPrivateKeyAuth(
                privateKey: _sshPrivateKeyController.text,
                passphrase: _sshPassphraseController.text,
              );

        sshCfg = SshConfig(
          host: _sshHostController.text,
          port: port,
          username: _sshUsernameController.text,
          auth: auth,
        );
      }
      return Connection(
        _nameController.text,
        _uriController.text,
        sshConfig: sshCfg,
      );
    }

    final form = ConnectionForm(
      isAdd: isAddDialog,
      nameController: _nameController,
      uriController: _uriController,
      useSsh: _useSsh,
      sshHostController: _sshHostController,
      sshPortController: _sshPortController,
      sshUsernameController: _sshUsernameController,
      sshAuthMode: _sshAuthMode,
      sshPasswordController: _sshPasswordController,
      sshPrivateKeyController: _sshPrivateKeyController,
      sshPassphraseController: _sshPassphraseController,
      onUseSshChanged: (val) => _useSsh = val,
      onSshAuthModeChanged: (val) => _sshAuthMode = val,
      onHelp: openUrl,
      onSubmit: () {
        final conn = buildConnectionToSave();
        if (isAddDialog) {
          addConnection(conn);
        } else {
          updateConnection(index, conn);
        }
        Navigator.pop(context);
      },
    );
    await showFormSheet(context: context, child: form);
    if (index >= 0) {
      setState(() {
        connections[index].isSelected = false;
      });
    }
  }

  void addConnection(Connection connection) {
    if (connection.name.isNotEmpty && connection.uri.isNotEmpty) {
      setState(() {
        connections.add(Selectable(connection));
      });
      saveConnections();
    }
  }

  void updateConnection(int index, Connection connection) {
    if (index >= 0 &&
        connections.length > index &&
        connection.name.isNotEmpty &&
        connection.uri.isNotEmpty) {
      setState(() {
        connections[index] = Selectable(connection);
      });
      saveConnections();
    }
  }

  void select(int index, SelectType type) {
    if (isLoading) {
      return;
    }
    if (type == SelectType.tap) {
      if (connections.any((element) => element.isSelected)) {
        setState(() {
          connections[index].select();
        });
      } else {
        connectAndNavigate(index);
      }
    } else {
      setState(() {
        connections[index].select();
      });
    }
  }

  Future<void> connectAndNavigate(int index) async {
    final navigator = Navigator.of(context);
    setState(() {
      isLoading = true;
    });
    bool connected = await MongoService()
        .connect(connections[index].item);
    setState(() {
      isLoading = false;
    });
    if (connected) {
      navigator.pushNamed('/collections',
          arguments: connections[index].item.name);
    }
  }

  Future<void> getSavedConnections() async {
    String? data = await StorageService().read('connections');
    if (data == null) {
      return;
    }
    List<dynamic> savedConnections = jsonDecode(data);
    setState(() {
      connections = savedConnections
          .map((e) => Selectable(Connection.fromJson(e)))
          .toList(growable: true);
    });
  }

  Future<void> saveConnections() async {
    String json = jsonEncode(connections.map((e) => e.item).toList());
    StorageService().write('connections', json);
  }

  Future<void> navigateSettings() async {
    await Navigator.of(context).pushNamed('/settings');
    setState(() {
      maskPassword = SettingsService().maskPassword;
    });
  }

  @override
  void initState() {
    super.initState();
    maskPassword = SettingsService().maskPassword;
    getSavedConnections();
  }

  Widget getActionButtons(BuildContext context) {
    List<Widget> buttons = List.empty(growable: true);
    int selectedCount =
        connections.where((element) => element.isSelected).length;
    if (selectedCount == 0) {
      return LoadableFloatingActionButton(
          FloatingActionButton(
              onPressed: () => addOrEditDialog(true),
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Add new connection.',
              child: const Icon(Icons.add)),
          isLoading);
    }

    if (selectedCount == 1) {
      buttons.add(LoadableFloatingActionButton(
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
              foregroundColor: Theme.of(context).colorScheme.onError,
              onPressed: () => addOrEditDialog(false),
              tooltip: 'Edit selected connection(s).',
              child: const Icon(Icons.edit)),
          isLoading));
      buttons.add(const SizedBox(width: 1, height: 20));
    }

    buttons.add(LoadableFloatingActionButton(
        FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
            foregroundColor: Theme.of(context).colorScheme.onError,
            onPressed: deleteDialog,
            tooltip: 'Delete selected connection(s).',
            child: const Icon(Icons.delete_forever)),
        isLoading));

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          actions: isLoading || connections.any((element) => element.isSelected)
              ? []
              : [
                  IconButton(
                    onPressed: navigateSettings,
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                  )
                ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: connections.isEmpty
            ? const Center(child: Text('Add a new connection string.'))
            : CupertinoScrollbar(
                child: ReorderableListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    padding: EdgeInsets.fromLTRB(15, 20, 15, Platform.isAndroid ? 90 : 140),
                    onReorder: (oldIndex, newIndex) {
                      reorder(oldIndex, newIndex);
                    },
                    itemCount: connections.length,
                    itemBuilder: (context, index) => ConnectionTile(
                          index,
                          connections[index],
                          connections.any((q) => q.isSelected),
                          (i, t) => select(i, t),
                          maskPassword,
                          key: UniqueKey(),
                        )),
              ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: getActionButtons(context));
  }
}
