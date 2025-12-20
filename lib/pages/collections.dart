import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/utilities/formsheet.dart';
import 'package:mondroid/widgets/collectiontile.dart';
import 'package:mondroid/widgets/confirmdialog.dart';

import '../services/settingsservice.dart';
import '../widgets/collectionform.dart';
import '../widgets/loadable.dart';

class Collections extends StatefulWidget {
  final String title;

  const Collections({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => CollectionsState();
}

class CollectionsState extends State<Collections> {
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  List<Selectable<Collection>> collections = <Selectable<Collection>>[];

  Future<void> getCollections() async {
    setState(() {
      isLoading = true;
    });
    var collectionInfos = await MongoService().getCollectionInfos();
    setState(() {
      collections = (SettingsService().systemCollections
              ? collectionInfos
              : collectionInfos.where((x) => !x.name.startsWith('system.')))
          .map((e) => Selectable(Collection.fromMongoCollection(e)))
          .toList();
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
    if (type == SelectType.tap) {
      if (collections.any((element) => element.isSelected)) {
        setState(() {
          collections[index].select();
        });
      } else {
        Navigator.of(context)
            .pushNamed('/records', arguments: collections[index].item);
      }
    } else {
      setState(() {
        collections[index].select();
      });
    }
  }

  Future<void> addDialog() async {
    final form = CollectionForm(
      controller: _nameController,
      onSubmit: () {
        create(_nameController.text);
        Navigator.pop(context);
      },
    );
    await showFormSheet(context: context, child: form);
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
          return ConfirmDialog.create(
              context,
              'Delete Collection(s)',
              'This action cannot be undone. Are you sure you want to continue?',
              'Cancel',
              'Delete',
              true);
        });
    if (delete == true) {
      setState(() {
        isLoading = true;
      });
      Iterable<Future<bool>> futures = collections
          .where((element) => element.isSelected)
          .map((q) => MongoService().deleteCollection(q.item.name));
      await Future.wait(futures);
      setState(() {
        isLoading = false;
      });
      getCollections();
    } else {
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
        body: RefreshIndicator(
          onRefresh: getCollections,
          child: collections.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: netHeight,
                    child: const Center(
                      child: Text('No collections.'),
                    ),
                  ),
                )
              : CupertinoScrollbar(
                  child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: collections.length,
                      itemBuilder: (context, index) => CollectionTile(
                          index: index,
                          selectable: collections[index],
                          hasAnySelected:
                              collections.any((element) => element.isSelected),
                          onClick: select))),
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: LoadableFloatingActionButton(
            collections.any((element) => element.isSelected)
                ? FloatingActionButton(
                    backgroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    onPressed: deleteDialog,
                    tooltip: 'Delete selected collection(s).',
                    child: const Icon(Icons.delete_forever))
                : FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: addDialog,
                    tooltip: 'Create new collection.',
                    child: const Icon(Icons.add)),
            isLoading));
  }
}
