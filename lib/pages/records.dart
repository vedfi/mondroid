import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:mondroid/widgets/recordtile.dart';

class Records extends StatefulWidget {
  final String collectionName;
  const Records({Key? key, required this.collectionName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RecordsState();
}

class RecordsState extends State<Records> {
  bool isLoading = false;
  static const _pageSize = 20;
  final PagingController<int, Selectable<Map<String, dynamic>>>
      _pagingController = PagingController(firstPageKey: 0);

  Future<void> getRecords(int page) async {
    try {
      final newItems = (await MongoService().find(widget.collectionName, page, _pageSize)).map((e) => Selectable(e)).toList();
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
    if(_pagingController.itemList == null || _pagingController.itemList!.isEmpty){
      return;
    }
    if (type == SelectType.Tap) {
      if (_pagingController.itemList!.any((element) => element.isSelected)) {
        setState(() {
          _pagingController.itemList!.elementAt(index).select();
        });
      } else {
        //TODO:navigation.
        // Navigator.of(context)
        //     .pushNamed('/records', arguments: collections[index].item.name);
      }
    } else {
      setState(() {
        _pagingController.itemList!.elementAt(index).select();
      });
    }
  }

  bool hasAnySelected(){
    if(_pagingController.itemList != null){
      return _pagingController.itemList!.any((element) => element.isSelected);
    }
    return false;
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      getRecords(pageKey);
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
          title: Text(widget.collectionName),
        ),
        body: RefreshIndicator(
            onRefresh: () async => {_pagingController.refresh()},
            child: CupertinoScrollbar(
                child: PagedListView<int, Selectable<Map<String, dynamic>>>.separated(
                  pagingController: _pagingController,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding:
                  EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  builderDelegate: PagedChildBuilderDelegate<
                      Selectable<Map<String, dynamic>>>(
                      firstPageProgressIndicatorBuilder: (context) => Text('Loading..'),
                      noItemsFoundIndicatorBuilder: (context) => Text('Empty'),
                      itemBuilder: (context, data, index) => RecordTile(index, data, hasAnySelected(), select)
                  ),
                ))),
        floatingActionButton: LoadableFloatingActionButton(
            hasAnySelected()
                ? FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: null,
                    tooltip: 'Delete selected document(s).',
                    child: const Icon(Icons.delete_forever))
                : FloatingActionButton(
                    onPressed: null,
                    tooltip: 'Insert a new document.',
                    child: const Icon(Icons.add)),
            isLoading));
  }
}
