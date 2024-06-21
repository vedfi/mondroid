import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/services/popupservice.dart';
import 'package:mondroid/services/storageservice.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/connectiontile.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/selectable.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({Key? key, required this.title}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uriController = TextEditingController();
  List<Selectable<Connection>> connections = <Selectable<Connection>>[];
  final Uri _url = Uri.parse('https://vedfi.com.tr/mondroid/troubleshoot');

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
          return ConfirmDialog().build(
              context,
              'Delete Connection(s)',
              'This action cannot be undone. Are you sure you want to continue?',
              'Cancel',
              'Delete');
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
    if (!isAddDialog) {
      for (int i = 0; i < connections.length; i++) {
        if (connections[i].isSelected) {
          index = i;
          _nameController.text = connections[i].item.name;
          _uriController.text = connections[i].item.uri;
          break;
        }
      }
    }
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isAddDialog
                    ? const Text('Add Connection')
                    : const Text('Edit Connection'),
                IconButton(
                    onPressed: openUrl,
                    tooltip: 'Help',
                    icon: const Icon(
                      Icons.help_outline,
                      size: 24,
                    ))
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 0,
                  child: TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: "Name",
                      helperText: 'Will be used as title.',
                    ),
                  ),
                ),
                const SizedBox(width: 10, height: 10),
                SizedBox(
                  width: 0,
                  child: TextField(
                    controller: _uriController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                        hintText: "Uri", helperText: 'Uri with database name.'),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (isAddDialog) {
                      add(_nameController.value.text,
                          _uriController.value.text);
                    } else {
                      update(index, _nameController.value.text,
                          _uriController.value.text);
                    }
                    Navigator.pop(context);
                    _uriController.clear();
                    _nameController.clear();
                  },
                  child: isAddDialog ? const Text('Add') : const Text('Edit')),
            ],
          );
        });
    if (index >= 0) {
      setState(() {
        connections[index].isSelected = false;
      });
    }
  }

  void add(String name, String uri) {
    if (name.isNotEmpty && uri.isNotEmpty) {
      setState(() {
        connections.add(Selectable(Connection(name, uri)));
      });
      saveConnections();
    }
  }

  void update(int index, String name, String uri) {
    if (index >= 0 &&
        connections.length > index &&
        name.isNotEmpty &&
        uri.isNotEmpty) {
      setState(() {
        connections[index] = Selectable(Connection(name, uri));
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
        .connect(connections[index].item.getConnectionString());
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

  @override
  void initState() {
    super.initState();
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
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: connections.isEmpty
            ? const Center(child: Text('Add a new connection string.'))
            : CupertinoScrollbar(
                child: ReorderableListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    onReorder: reorder,
                    itemCount: connections.length,
                    itemBuilder: (context, index) => ConnectionTile(
                          index,
                          connections[index],
                          connections.any((q) => q.isSelected),
                          (i, t) => select(i, t),
                          key: UniqueKey(),
                        )),
              ),
        floatingActionButton: getActionButtons(context));
  }
}
