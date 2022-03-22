import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/widgets/loadable.dart';

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
                child: PagedListView<int, Selectable<Map<String, dynamic>>>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<
                      Selectable<Map<String, dynamic>>>(
                      firstPageProgressIndicatorBuilder: (context) => Text('Loading..'),
                      noItemsFoundIndicatorBuilder: (context) => Text('Empty'),
                      itemBuilder: (context, data, index) => ListTile(
                          title: Text(data.item['_id'].toString()),
                          subtitle: Text('data'))),
                ))),
        floatingActionButton: LoadableFloatingActionButton(
            hasAnySelected()
                ? FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: null,
                    tooltip: 'Delete selected connection(s).',
                    child: const Icon(Icons.delete_forever))
                : FloatingActionButton(
                    onPressed: null,
                    tooltip: 'Add new connection.',
                    child: const Icon(Icons.add)),
            isLoading));
  }
}
