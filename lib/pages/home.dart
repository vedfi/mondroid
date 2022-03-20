import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mondroid/models/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/selectable.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({Key? key, required this.title}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _uriController = TextEditingController();
  List<Selectable<Connection>> connections = <Selectable<Connection>>[];

  void changeSelectedIndex(int index) {
    setState(() {
      connections[index].select();
    });
  }

  void delete() {
    setState(() {
      connections.removeWhere((element) => element.isSelected);
    });
    saveConnections();
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
                  decoration: InputDecoration(hintText: "Name"),
                ),
                SizedBox(width: 10, height: 10),
                TextField(
                  controller: _uriController,
                  decoration: InputDecoration(hintText: "Uri"),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: (){
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
    if(name.isNotEmpty && uri.isNotEmpty){
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
        //TODO:navigation
      }
    } else {
      setState(() {
        connections[index].select();
      });
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
            : ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: connections.length,
                itemBuilder: (context, index) => DbConnectionTile(
                    index,
                    connections[index],
                    connections.any((q) => q.isSelected),
                    (i, t) => select(i, t))),
        floatingActionButton: connections.any((element) => element.isSelected)
            ? FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: delete,
                tooltip: 'Delete selected connection(s).',
                child: const Icon(Icons.delete_forever))
            : FloatingActionButton(
                onPressed: addDialog,
                tooltip: 'Add new connection.',
                child: const Icon(Icons.add)));
  }
}

class DbConnectionTile extends StatelessWidget {
  final onClick;
  final int index;
  final bool has_any_selected;
  final Selectable<Connection> selectable;
  DbConnectionTile(
      this.index, this.selectable, this.has_any_selected, this.onClick);

  void _clickHandler() {
    onClick(index, SelectType.Tap);
  }

  void _longPressHandler() {
    onClick(index, SelectType.LongPress);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      selected: this.selectable.isSelected,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      tileColor: Colors.white,
      selectedTileColor: Colors.red.shade50,
      selectedColor: Colors.red,
      onTap: () => _clickHandler(),
      onLongPress: () => _longPressHandler(),
      title: Text(this.selectable.item.name),
      subtitle: Text(this.selectable.item.uri),
      trailing: this.selectable.isSelected
          ? Icon(Icons.check_box)
          : (has_any_selected
              ? Icon(Icons.check_box_outline_blank)
              : Icon(Icons.keyboard_arrow_right)),
    );
  }
}
