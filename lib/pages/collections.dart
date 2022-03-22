import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/widgets/collectiontile.dart';

import '../widgets/loadable.dart';

class Collections extends StatefulWidget{
  final String title;
  const Collections({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CollectionsState();
}

class CollectionsState extends State<Collections>{

  bool isLoading = false;
  List<Selectable<Collection>> collections = <Selectable<Collection>>[];

  Future<void> getCollections() async{
    var names = await MongoService().getCollectionNames();
    setState(() {
      collections = names.map((e) => Selectable(Collection(e))).toList();
    });
    getRecordCounts();
  }

  Future<void> getRecordCounts() async{
    Iterable<Future<int>> futures = collections.map((q) => MongoService().getRecordCount(q.item.name));
    List<int> counts = await Future.wait(futures);
    setState(() {
      for(int i = 0; i<counts.length; i++){
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
        //TODO: navigation
      }
    } else {
      setState(() {
        collections[index].select();
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
    double height = MediaQuery.of(context).size.height; // Full screen width and height
    EdgeInsets padding = MediaQuery.of(context).padding; // Height (without SafeArea)
    double netHeight = height - padding.top - kToolbarHeight; // Height (without status and toolbar)
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
            child:  Container(
              height: netHeight,
              child: Center(
                child: Text('No collections.'),
              ),
            ),
          )
              : CupertinoScrollbar(child: ListView.separated(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: collections.length,
              itemBuilder: (context, index) => CollectionTile(index: index, selectable: collections[index], has_any_selected: collections.any((element) => element.isSelected), onClick: select)
          )),
        ),
        floatingActionButton: LoadableFloatingActionButton(collections.any((element) => element.isSelected)
            ? FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: null,
            tooltip: 'Delete selected connection(s).',
            child: const Icon(Icons.delete_forever))
            : FloatingActionButton(
            onPressed: null,
            tooltip: 'Add new connection.',
            child: const Icon(Icons.add)), isLoading)
    );
  }
}