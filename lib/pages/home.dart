import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/widgets/connectiontile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/selectable.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({Key? key, required this.title}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isLoading = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _uriController = TextEditingController();
  List<Selectable<Connection>> connections = <Selectable<Connection>>[];

  void reorder(int old_index, int new_index){
    setState(() {
      new_index -= old_index < new_index ? 1 : 0;
      final Selectable<Connection> item = connections.removeAt(old_index);
      connections.insert(new_index, item);
    });
    saveConnections();
  }

  Future<void> deleteDialog() async {
    bool? delete = await showDialog(context: context, builder: (ctx){
      return ConfirmDialog().Build(context, 'Delete Connection(s)', 'This action cannot be undone. Are you sure you want to continue?', 'Cancel', 'Delete');
    });
    if(delete == true){
      setState(() {
        connections.removeWhere((element) => element.isSelected);
      });
      saveConnections();
    }
    else{
      setState(() {
        for (var element in connections) {element.isSelected = false;}
      });
    }
  }

  Future<void> addDialog() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Add Connection'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Name", helperText: 'Will be used as title.'),
                ),
                SizedBox(width: 10, height: 10),
                TextField(
                  controller: _uriController,
                  decoration: InputDecoration(hintText: "Uri", helperText: 'Uri with database name.'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    add(_nameController.value.text, _uriController.value.text);
                    Navigator.pop(context);
                    _uriController.clear();
                    _nameController.clear();
                  },
                  child: Text('Add')),
            ],
          );
        });
  }

  void add(String name, String uri) {
    if (name.isNotEmpty && uri.isNotEmpty) {
      setState(() {
        connections.add(new Selectable(new Connection(name, uri)));
      });
      saveConnections();
    }
  }

  void select(int index, SelectType type) {
    if (type == SelectType.Tap) {
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
    if(isLoading){
      //already connecting..
      return;
    }
    setState(() {
      isLoading = true;
    });
    bool connected = await MongoService().connect(connections[index].item.getConnectionString());
    setState(() {
      isLoading = false;
    });
    if (connected) {
      Navigator.of(context)
          .pushNamed('/collections', arguments: connections[index].item.name);
    }
    else{
     // Fluttertoast.showToast(msg: 'Connection Error');
    }
  }

  Future<void> getSavedConnections() async {
    var pref = await SharedPreferences.getInstance();
    List<String> saved_connections =
        pref.getStringList('connections') ?? <String>[];
    setState(() {
      connections = saved_connections
          .map((e) => Selectable(Connection.fromJson(jsonDecode(e))))
          .toList();
    });
  }

  Future<void> saveConnections() async {
    var pref = await SharedPreferences.getInstance();
    pref.setStringList('connections',
        connections.map((e) => jsonEncode(e.item.toJson())).toList());
  }

  @override
  void initState() {
    super.initState();
    getSavedConnections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: connections.isEmpty
            ? Center(child: Text('Add a new connection string.'))
            : ReorderableListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                onReorder: reorder,
                itemCount: connections.length,
                itemBuilder: (context, index) => ConnectionTile(
                    index,
                    connections[index],
                    connections.any((q) => q.isSelected),
                    (i, t) => select(i, t), key: UniqueKey(),)
            ),
        floatingActionButton: LoadableFloatingActionButton(connections.any((element) => element.isSelected)
            ? FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: deleteDialog,
            tooltip: 'Delete selected connection(s).',
            child: const Icon(Icons.delete_forever))
            : FloatingActionButton(
            onPressed: addDialog,
            tooltip: 'Add new connection.',
            child: const Icon(Icons.add)), isLoading)
    );
  }
}
