import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/utilities/jsonconverter.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:mondroid/widgets/recordtile.dart';

import '../services/popupservice.dart';

class Records extends StatefulWidget {
  final String collectionName;

  const Records({Key? key, required this.collectionName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RecordsState();
}

class RecordsState extends State<Records> {
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = true;
  static const _pageSize = 20;
  final PagingController<int, Selectable<Map<String, dynamic>>>
      _pagingController = PagingController(firstPageKey: 0);
  final ScrollController _scrollController = ScrollController();
  double offset = 0.0;
  bool refreshRequired = false;

  Map<String, dynamic> filter() {
    try {
      if (_nameController.value.text.isEmpty) {
        return {};
      }
      return JsonConverter.decode(_nameController.value.text);
    } catch (e) {
      PopupService.show("Invalid Query: $e");
      return {};
    }
  }

  Future<void> getRecords(int page) async {
    try {
      final newItems = (await MongoService()
              .find(widget.collectionName, page, _pageSize, filter()))
          .map((e) => Selectable(e))
          .toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = page + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void select(int index, SelectType type) {
    if (_pagingController.itemList == null ||
        _pagingController.itemList!.isEmpty) {
      return;
    }
    if (type == SelectType.tap) {
      if (_pagingController.itemList!.any((element) => element.isSelected)) {
        setState(() {
          _pagingController.itemList!.elementAt(index).select();
        });
      }
    } else if (type == SelectType.navigate) {
      navigate(index);
    } else {
      setState(() {
        _pagingController.itemList!.elementAt(index).select();
      });
    }
  }

  bool hasAnySelected() {
    if (_pagingController.itemList != null) {
      return _pagingController.itemList!.any((element) => element.isSelected);
    }
    return false;
  }

  Future<void> searchDialog() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Find Query'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 0,
                  child: TextField(
                    controller: _nameController,
                    maxLines: 7,
                    decoration: const InputDecoration(
                        hintText: 'Basic usage: {"key":"value"}',
                        helperText:
                        'All query operators are supported.\nLeave blank if you want to fetch all records.'),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _pagingController.refresh();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply')),
            ],
          );
        });
  }

  Future<void> deleteDialog() async {
    bool? delete = await showDialog(
        context: context,
        builder: (ctx) {
          return ConfirmDialog().build(
              context,
              'Delete Document(s)',
              'This action cannot be undone. Are you sure you want to continue?',
              'Cancel',
              'Delete');
        });
    if (delete == true) {
      setState(() {
        isLoading = true;
      });
      Iterable<Future<bool>> futures = _pagingController.itemList!
          .where((element) => element.isSelected)
          .map((q) => MongoService()
              .deleteRecord(widget.collectionName, q.item['_id']));
      await Future.wait(futures);
      setState(() {
        isLoading = false;
      });
      _pagingController.refresh();
    } else {
      setState(() {
        for (var element in _pagingController.itemList!) {
          element.isSelected = false;
        }
      });
    }
  }

  Future<void> navigate(int index) async {
    dynamic shouldRefresh =
        await Navigator.of(context).pushNamed('/edit', arguments: [
      widget.collectionName,
      index == -1 ? null : _pagingController.itemList!.elementAt(index).item
    ]);
    refreshRequired = shouldRefresh is bool && shouldRefresh;
    if (refreshRequired) {
      offset = _scrollController.offset;
      _pagingController.refresh();
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      getRecords(pageKey);
    });
    _pagingController.addStatusListener((status) {
      setState(() {
        isLoading = status == PagingStatus.loadingFirstPage;
        if (refreshRequired && status == PagingStatus.completed) {
          _scrollController.jumpTo(offset);
          refreshRequired = false;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(widget.collectionName),
          actions: [
            IconButton(
              onPressed: searchDialog,
              icon: const Icon(Icons.search),
              tooltip: 'Find',
            )
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async => {_pagingController.refresh()},
            child: CupertinoScrollbar(
                controller: _scrollController,
                child: PagedListView<int,
                    Selectable<Map<String, dynamic>>>.separated(
                  pagingController: _pagingController,
                  scrollController: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  builderDelegate: PagedChildBuilderDelegate<
                          Selectable<Map<String, dynamic>>>(
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Center(
                            child: Text('Loading.'),
                          ),
                      noItemsFoundIndicatorBuilder: (context) => const Center(
                            child: Text('No records.'),
                          ),
                      itemBuilder: (context, data, index) =>
                          RecordTile(index, data, hasAnySelected(), select)),
                ))),
        floatingActionButton: LoadableFloatingActionButton(
            hasAnySelected()
                ? FloatingActionButton(
                    backgroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    onPressed: deleteDialog,
                    tooltip: 'Delete selected document(s).',
                    child: const Icon(Icons.delete_forever))
                : FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () => {navigate(-1)},
                    tooltip: 'Insert a new document.',
                    child: const Icon(Icons.add)),
            isLoading));
  }
}
