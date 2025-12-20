import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/services/settingsservice.dart';
import 'package:mondroid/utilities/formsheet.dart';
import 'package:mondroid/utilities/jsonconverter.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/filterqueryform.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:mondroid/widgets/recordtile.dart';
import 'package:mondroid/widgets/sortqueryform.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/popupservice.dart';

class Records extends StatefulWidget {
  final Collection collection;

  const Records({super.key, required this.collection});

  @override
  State<StatefulWidget> createState() => RecordsState();
}

class RecordsState extends State<Records> {
  final TextEditingController _filterQueryController = TextEditingController();
  final TextEditingController _sortQueryController = TextEditingController();
  bool isLoading = true;
  final _pageSize = SettingsService().pageSize;
  final PagingController<int, Selectable<Map<String, dynamic>>>
      _pagingController = PagingController(firstPageKey: 0);
  final ScrollController _scrollController = ScrollController();
  double offset = 0.0;
  bool refreshRequired = false;
  final Uri _filterUrl =
      Uri.parse('https://vedfi.github.io/mondroid/help/queries/filter');
  final Uri _sortUrl =
      Uri.parse('https://vedfi.github.io/mondroid/help/queries/sort');

  Future<void> openUrl(Uri url) async {
    if (!await launchUrl(url)) {
      PopupService.show('Could not launch $url');
    }
  }

  Future<Map<String, dynamic>?> filter() async {
    try {
      if (_filterQueryController.value.text.isEmpty) {
        return null;
      }
      dynamic data = await compute(
          JsonConverter.decode, _filterQueryController.value.text);
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      PopupService.show("Invalid Filter Query: $e");
      return {};
    }
  }

  Future<Map<String, Object>?> sort() async {
    try {
      if (_sortQueryController.value.text.isEmpty) {
        return null;
      }
      dynamic data =
          await compute(JsonConverter.decode, _sortQueryController.value.text);
      return Map<String, Object>.from(data as Map);
    } catch (e) {
      PopupService.show("Invalid Sort Query: $e");
      return {};
    }
  }

  Future<void> getRecords(int page) async {
    try {
      final newItems = (await MongoService().find(widget.collection.name, page,
              _pageSize, await filter(), await sort()))
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

    if (type == SelectType.navigate) {
      navigate(index);
      return;
    }

    if (widget.collection.isReadonly()) {
      return;
    }

    if (type == SelectType.tap) {
      if (_pagingController.itemList!.any((element) => element.isSelected)) {
        setState(() {
          _pagingController.itemList!.elementAt(index).select();
        });
      }
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

  Future<void> sortDialog() async {
    final form = SortQueryForm(
      controller: _sortQueryController,
      onApply: () {
        if (_sortQueryController.value.text.trim().isEmpty) {
          _sortQueryController.clear();
        }
        _pagingController.refresh();
        Navigator.pop(context);
      },
      onHelp: () => openUrl(_sortUrl),
    );
    await showFormSheet(context: context, child: form);
  }

  Future<void> searchDialog() async {
    final form = FilterQueryForm(
      controller: _filterQueryController,
      onApply: () {
        if (_filterQueryController.value.text.trim().isEmpty) {
          _filterQueryController.clear();
        }
        _pagingController.refresh();
        Navigator.pop(context);
      },
      onHelp: () => openUrl(_filterUrl),
    );
    await showFormSheet(context: context, child: form);
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
              .deleteRecord(widget.collection.name, q.item['_id']));
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
      widget.collection,
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
    final hideActions = isLoading || hasAnySelected();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(widget.collection.name),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          actions: [
            Visibility(
              maintainSize: false,
              maintainAnimation: false,
              maintainState: true,
              visible: !hideActions,
              child: IconButton(
                onPressed: sortDialog,
                icon: const Icon(Icons.sort),
                tooltip: 'Sort',
              ),
            ),
            Visibility(
              maintainSize: false,
              maintainAnimation: false,
              maintainState: true,
              visible: !hideActions,
              child: IconButton(
                onPressed: searchDialog,
                icon: const Icon(Icons.search),
                tooltip: 'Filter',
              ),
            ),
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
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 40),
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
                      itemBuilder: (context, data, index) => RecordTile(
                          index,
                          data,
                          hasAnySelected(),
                          select,
                          SettingsService().showOidTimestamp)),
                ))),
        resizeToAvoidBottomInset: false,
        floatingActionButton: widget.collection.isReadonly()
            ? null
            : LoadableFloatingActionButton(
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
