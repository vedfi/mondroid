import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/models/paginationmode.dart';
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

  const Records({
    super.key,
    required this.collection,
  });

  @override
  State<StatefulWidget> createState() => RecordsState();
}

class RecordsState extends State<Records> {
  final TextEditingController _filterQueryController = TextEditingController();
  final TextEditingController _sortQueryController = TextEditingController();
  bool isLoading = true;
  final _pageSize = SettingsService().pageSize;
  final _paginationMode = SettingsService().paginationMode;

  late bool _useInfiniteScroll;
  late int _totalItems;
  int _currentPage = 0;

  bool _needsCount = false;

  final PagingController<int, Selectable<Map<String, dynamic>>>
      _pagingController = PagingController(firstPageKey: 0);
  final ScrollController _scrollController = ScrollController();
  double offset = 0.0;
  bool refreshRequired = false;

  final Uri _filterUrl =
      Uri.parse('https://vedfi.github.io/mondroid/help/queries/filter');
  final Uri _sortUrl =
      Uri.parse('https://vedfi.github.io/mondroid/help/queries/sort');

  int get _totalPages {
    if (_totalItems <= 0) return 1;
    return (_totalItems / _pageSize).ceil();
  }

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

  Future<void> getRecords(int pageKey) async {
    try {
      if (!_useInfiniteScroll && _needsCount) {
        final filterQuery = await filter();
        final totalCountData =
            await MongoService().count(widget.collection.name, filterQuery);

        setState(() {
          _totalItems = (totalCountData as num).toInt();
          _needsCount = false;

          if (_currentPage >= _totalPages) {
            _currentPage = (_totalPages - 1).clamp(0, double.infinity).toInt();
          }
        });
      }

      final int mongoPageParam =
          _useInfiniteScroll ? pageKey : (_currentPage * _pageSize);
      final filterQuery = await filter();
      final sortQuery = await sort();

      final fetchedRecords = await MongoService().find(widget.collection.name,
          mongoPageParam, _pageSize, filterQuery, sortQuery);

      final newItems = fetchedRecords.map((e) => Selectable(e)).toList();
      final isLastPage = newItems.length < _pageSize;

      if (_useInfiniteScroll) {
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      } else {
        _pagingController.value = PagingState(
          nextPageKey: null,
          error: null,
          itemList: newItems,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      _pagingController.error = error;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _changePage(int newPage) {
    if (newPage < 0 || newPage >= _totalPages) return;
    setState(() {
      _currentPage = newPage;
      isLoading = true;
    });
    getRecords(_currentPage);
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
    if (widget.collection.isReadonly()) return;

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

  bool hasAnySelected() =>
      _pagingController.itemList?.any((e) => e.isSelected) ?? false;

  Future<void> sortDialog() async {
    final form = SortQueryForm(
      controller: _sortQueryController,
      onApply: () {
        if (_sortQueryController.value.text.trim().isEmpty) {
          _sortQueryController.clear();
        }
        if (_useInfiniteScroll) {
          _pagingController.refresh();
        } else {
          _changePage(0);
        }
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
        setState(() {
          _needsCount = true;
        });
        if (_useInfiniteScroll) {
          _pagingController.refresh();
        } else {
          _changePage(0);
        }
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
          return ConfirmDialog.create(
              context,
              'Delete Document(s)',
              'This action cannot be undone. Are you sure?',
              'Cancel',
              'Delete',
              true);
        });
    if (delete == true) {
      setState(() {
        isLoading = true;
        _needsCount = true;
      });
      final selectedIds = _pagingController.itemList!
          .where((element) => element.isSelected)
          .map((q) => q.item['_id'])
          .toList();
      await MongoService()
          .deleteRecords(widget.collection.name, selectedIds);
      if (_useInfiniteScroll) {
        _pagingController.refresh();
      } else {
        getRecords(_currentPage);
      }
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
      setState(() {
        _needsCount = true;
      });
      if (_useInfiniteScroll) {
        offset = _scrollController.offset;
        _pagingController.refresh();
      } else {
        getRecords(_currentPage);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _totalItems = widget.collection.count;

    if (_paginationMode == PaginationMode.infinite) {
      _useInfiniteScroll = true;
    } else if (_paginationMode == PaginationMode.paged) {
      _useInfiniteScroll = false;
    } else {
      _useInfiniteScroll = _totalItems < 200;
    }

    if (_useInfiniteScroll) {
      _pagingController
          .addPageRequestListener((pageKey) => getRecords(pageKey));
    } else {
      getRecords(_currentPage);
    }

    _pagingController.addStatusListener((status) {
      setState(() {
        isLoading = status == PagingStatus.loadingFirstPage;
        if (refreshRequired && status == PagingStatus.completed) {
          if (_useInfiniteScroll) {
            _scrollController.jumpTo(offset);
          }
          refreshRequired = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hideActions = isLoading || hasAnySelected();
    final bool hasBottomNavigationBar = (!_useInfiniteScroll &&
        _pagingController.itemList != null &&
        _totalItems > 0);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(widget.collection.name),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          actions: [
            Visibility(
              visible: !hideActions,
              child: IconButton(
                  onPressed: sortDialog,
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sort'),
            ),
            Visibility(
              visible: !hideActions,
              child: IconButton(
                  onPressed: searchDialog,
                  icon: const Icon(Icons.search),
                  tooltip: 'Filter'),
            ),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() => _needsCount = true);
              if (_useInfiniteScroll) {
                _pagingController.refresh();
              } else {
                _changePage(_currentPage);
              }
            },
            child: CupertinoScrollbar(
                controller: _scrollController,
                child: PagedListView<int,
                    Selectable<Map<String, dynamic>>>.separated(
                  pagingController: _pagingController,
                  scrollController: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                      15, 20, 15, Platform.isAndroid || hasBottomNavigationBar ? 90 : 140),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  builderDelegate: PagedChildBuilderDelegate<
                          Selectable<Map<String, dynamic>>>(
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      noItemsFoundIndicatorBuilder: (context) =>
                          const Center(child: Text('No records.')),
                      itemBuilder: (context, data, index) => RecordTile(
                          index,
                          data,
                          hasAnySelected(),
                          select,
                          SettingsService().showOidTimestamp)),
                ))),
        bottomNavigationBar: hasBottomNavigationBar
            ? Material(
                color: Theme.of(context).colorScheme.onInverseSurface,
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      top: 8,
                      bottom: MediaQuery.of(context).padding.bottom > 0
                          ? MediaQuery.of(context).padding.bottom
                          : 12,
                      left: 16,
                      right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: const Icon(Icons.first_page, size: 22),
                        splashRadius: 20,
                        onPressed: (!isLoading && _currentPage > 0)
                            ? () => _changePage(0)
                            : null,
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: const Icon(Icons.chevron_left, size: 22),
                        splashRadius: 20,
                        onPressed: (!isLoading && _currentPage > 0)
                            ? () => _changePage(_currentPage - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 130,
                        child: Text(
                          "Page ${_currentPage + 1} of $_totalPages",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: const Icon(Icons.chevron_right, size: 22),
                        splashRadius: 20,
                        onPressed:
                            (!isLoading && _currentPage < (_totalPages - 1))
                                ? () => _changePage(_currentPage + 1)
                                : null,
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        icon: const Icon(Icons.last_page, size: 22),
                        splashRadius: 20,
                        onPressed:
                            (!isLoading && _currentPage < (_totalPages - 1))
                                ? () => _changePage(_totalPages - 1)
                                : null,
                      ),
                    ],
                  ),
                ),
              )
            : null,
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
                        tooltip: 'Delete',
                        child: const Icon(Icons.delete_forever))
                    : FloatingActionButton(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onPressed: () => navigate(-1),
                        tooltip: 'Insert',
                        child: const Icon(Icons.add)),
                isLoading));
  }
}
