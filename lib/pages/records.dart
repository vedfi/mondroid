import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/services/fileservice.dart';
import 'package:mondroid/utilities/jsonconverter.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/filepermissiondialog.dart';
import 'package:mondroid/widgets/loadable.dart';
import 'package:mondroid/widgets/recordtile.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/popupservice.dart';

class Records extends StatefulWidget {
  final String collectionName;

  const Records({super.key, required this.collectionName});

  @override
  State<StatefulWidget> createState() => RecordsState();
}

class RecordsState extends State<Records> {
  final TextEditingController _filterQueryController = TextEditingController();
  final TextEditingController _sortQueryController = TextEditingController();
  final TextEditingController _directoryController = TextEditingController();
  final TextEditingController _filenameController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  static const _pageSize = 10;
  final PagingController<int, Selectable<Map<String, dynamic>>>
      _pagingController = PagingController(firstPageKey: 0);
  final ScrollController _scrollController = ScrollController();
  double offset = 0.0;
  bool refreshRequired = false;

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
      final newItems = (await MongoService().find(widget.collectionName, page,
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

  Future<void> sortDialog() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            title: const Text('Sort Query'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 0,
                  child: TextField(
                    controller: _sortQueryController,
                    maxLines: 7,
                    decoration: const InputDecoration(
                        hintText: '{"field": "\$asc" or "\$desc"}',
                        helperText:
                            'Multiple sorting criteria supported.\nLeave blank if you dont want to use sorting.'),
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

  Future<void> searchDialog() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            title: const Text('Filter Query'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 0,
                  child: TextField(
                    controller: _filterQueryController,
                    maxLines: 7,
                    decoration: const InputDecoration(
                        hintText: '{"key": "value" or {"\$operator"}}',
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

  Future<void> exportCollection() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
              title: const Text('Export Collection'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          String? newPath =
                              await FileService().getNewDirectoryPath();

                          if (newPath != 'null') {
                            setState(() {
                              _directoryController.text = newPath;
                            });
                          }
                        },
                        icon: const Icon(Icons.folder_open),
                      ),
                      Flexible(
                          child: InkWell(
                        onTap: () async {
                          String? newPath =
                              await FileService().getNewDirectoryPath();

                          if (newPath != 'null') {
                            setState(() {
                              _directoryController.text = newPath;
                            });
                          }
                        },
                        child: Text(
                          '${_directoryController.text}/',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TextField(
                      controller: _filenameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter filename',
                        helperText: 'Enter Filename without extension.',
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          await _exportData('csv');
                        },
                        child: const Text('CSV'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          await _exportData('json');
                        },
                        child: const Text('JSON'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _exportData(String format) async {
    try {
      setState(() {
        isLoading = true;
        isSaving = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fetching Data...')),
        );
      }
      List<Map<String, dynamic>> data = await MongoService()
          .findAll(widget.collectionName, await filter(), await sort());

      bool fileSaved = false;

      if (format == 'csv') {
        fileSaved = await FileService().saveAsCsv(
            data, _directoryController.text, _filenameController.text);
      } else if (format == 'json') {
        fileSaved = await FileService().saveAsJson(
            data, _directoryController.text, _filenameController.text);
      }

      setState(() {
        isLoading = false;
        isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(fileSaved
                  ? 'Data exported successfully!'
                  : 'Error exporting data')),
        );
      }

      return fileSaved;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
      return false;
    }
  }

  Future<bool> _checkPermissions(BuildContext context) async {
    final status = await Permission.storage.status;

    if (!status.isGranted) {
      final result = await Permission.storage.request();

      if (result.isGranted) {
        return true;
      } else if (result.isDenied || result.isPermanentlyDenied) {
        return false;
      }
    } else {
      return true;
    }

    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(widget.collectionName),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          actions: [
            IconButton(
              onPressed: () async {
                if (isSaving) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Exporting in progress. Please wait...')),
                    );
                  }

                  return;
                }

                _directoryController.text =
                    await FileService().getDiretoryPath();
                _filenameController.text = widget.collectionName;

                bool directoryExists =
                    await Directory(_directoryController.text).exists();
                if (!directoryExists) {
                  _directoryController.text =
                    await FileService().getNewDirectoryPath();
                  directoryExists =
                    await Directory(_directoryController.text).exists();
                }

                if (!context.mounted) return;
                bool hasFilePermission = await _checkPermissions(context);
                if (!hasFilePermission) {
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PermissionDialog(
                        message:
                            'Storage permission denied. Please enable it in app settings.',
                        onOpenSettings: () {
                          openAppSettings();
                        },
                      );
                    },
                  );
                }
                if (hasFilePermission && directoryExists) {
                  exportCollection();
                } else if (!directoryExists) {
                  PopupService.show('Directory does not exist');
                } else if (!hasFilePermission) {
                  PopupService.show('Permission denied');
                }
              },
              icon: const Icon(Icons.share),
              tooltip: 'Export Collection',
            ),
            IconButton(
              onPressed: sortDialog,
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
            ),
            IconButton(
              onPressed: searchDialog,
              icon: const Icon(Icons.search),
              tooltip: 'Filter',
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
