import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/widgets/collectiontile.dart';
import 'package:mondroid/widgets/confirmdialog.dart';

import '../widgets/loadable.dart';

class Collections extends StatefulWidget {
  final String title;
  const Collections({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CollectionsState();
}

class CollectionsState extends State<Collections> {
  TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  List<Selectable<Collection>> collections = <Selectable<Collection>>[];

  Future<void> getCollections() async {
    setState(() {
      isLoading = true;
    });
    var names = await MongoService().getCollectionNames();
    setState(() {
      collections = names.map((e) => Selectable(Collection(e))).toList();
      isLoading = false;
    });
    getRecordCounts();
  }

  Future<void> getRecordCounts() async {
    Iterable<Future<int>> futures =
        collections.map((q) => MongoService().getRecordCount(q.item.name));
    List<int> counts = await Future.wait(futures);
    setState(() {
      for (int i = 0; i < counts.length; i++) {
        collections[i].item.count = counts[i];
      }
    });
  }

  void select(int index, SelectType type) {
    if (type == SelectType.Tap) {
      if (collections.any((element) => element.isSelected)) {
        setState(() {
          collections[index].select();
        });
      } else {
        Navigator.of(context)
            .pushNamed('/records', arguments: collections[index].item.name);
      }
    } else {
      setState(() {
        collections[index].select();
      });
    }
  }

  Future<void> addDialog() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Create Collection'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Name"),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    create(_nameController.value.text);
                    Navigator.pop(context);
                  },
                  child: Text('Create')),
            ],
          );
        });
    _nameController.clear();
  }

  Future<void> create(String collectionName) async {
    setState(() {
      isLoading = true;
    });
    await MongoService().createCollection(collectionName);
    setState(() {
      isLoading = false;
    });
    getCollections();
  }

  Future<void> deleteDialog() async {
    bool? delete = await showDialog(
        context: context,
        builder: (ctx) {
          return ConfirmDialog().Build(context, 'Delete Collection(s)', 'This action cannot be undone. Are you sure you want to continue?', 'Cancel', 'Delete');
        });
    if (delete == true) {
      setState(() {
        isLoading = true;
      });
      Iterable<Future<bool>> futures =  collections.where((element) => element.isSelected).map((q) => MongoService().deleteCollection(q.item.name));
      await Future.wait(futures);
      setState(() {
        isLoading = false;
      });
      getCollections();
    }
    else{
      setState(() {
        for (var element in collections) {
          element.isSelected = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCollections();
  }

  @override
  Widget build(BuildContext context) {
    double height =
        MediaQuery.of(context).size.height; // Full screen width and height
    EdgeInsets padding =
        MediaQuery.of(context).padding; // Height (without SafeArea)
    double netHeight = height -
        padding.top -
        kToolbarHeight; // Height (without status and toolbar)
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: RefreshIndicator(
          onRefresh: getCollections,
          child: collections.isEmpty
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: netHeight,
                    child: Center(
                      child: Text('No collections.'),
                    ),
                  ),
                )
              : CupertinoScrollbar(
                  child: ListView.separated(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10),
                      itemCount: collections.length,
                      itemBuilder: (context, index) => CollectionTile(
                          index: index,
                          selectable: collections[index],
                          has_any_selected:
                              collections.any((element) => element.isSelected),
                          onClick: select))),
        ),
        floatingActionButton: LoadableFloatingActionButton(
            collections.any((element) => element.isSelected)
                ? FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: deleteDialog,
                    tooltip: 'Delete selected collection(s).',
                    child: const Icon(Icons.delete_forever))
                : FloatingActionButton(
                    onPressed: addDialog,
                    tooltip: 'Create new collection.',
                    child: const Icon(Icons.add)),
            isLoading));
  }
}
