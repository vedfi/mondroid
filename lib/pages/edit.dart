import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/services/settingsservice.dart';
import 'package:mondroid/utilities/jsonconverter.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/loadable.dart';

import '../services/popupservice.dart';

class Edit extends StatefulWidget {
  final Collection collection;
  final dynamic itemId;
  final dynamic item;

  const Edit({super.key, required this.collection, this.itemId, this.item});

  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<Edit> {
  bool isLoading = false;
  String title = "";
  final TextEditingController _jsonController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> encoder() async {
    try {
      String encoded = widget.itemId == null && !widget.collection.isReadonly()
          ? '{\n\n}'
          : await compute(JsonConverter.encode, widget.item);
      setState(() {
        _jsonController.text = encoded;
      });
    } catch (e) {
      setState(() {
        _jsonController.text = '{\n\n}';
        PopupService.show("Encode Error. $e");
      });
    }
  }

  Future<void> saveDialog() async {
    bool? ok = await showDialog(
        context: context,
        builder: (ctx) {
          return ConfirmDialog().build(context, 'Save record',
              'Are you sure you want to continue?', 'Cancel', 'Save');
        });
    if (ok == true) {
      await save();
    }
  }

  Future<void> save() async {
    final navigator = Navigator.of(context);
    setState(() {
      isLoading = true;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    if (_jsonController.value.text.isNotEmpty) {
      try {
        dynamic obj =
            await compute(JsonConverter.decode, _jsonController.value.text);
        bool result = false;
        if (widget.itemId != null) {
          //update
          obj.removeWhere((key, value) => key == '_id');
          result = await MongoService()
              .updateRecord(widget.collection.name, widget.itemId, obj);
        } else {
          //insert
          result =
              await MongoService().insertRecord(widget.collection.name, obj);
        }
        if (result) {
          navigator.pop(true);
        }
      } catch (e) {
        PopupService.show("Invalid JSON. $e");
      }
    } else {
      PopupService.show("Document is empty.");
    }
    setState(() {
      isLoading = false;
    });
  }

  void copy() {
    var jsonText = _jsonController.value.text;
    if (jsonText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: jsonText));
      Fluttertoast.showToast(msg: "Document copied to clipboard.");
    } else {
      Fluttertoast.showToast(msg: "Nothing to copy.");
    }
  }

  void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    super.initState();
    if (widget.collection.isReadonly()) {
      title = 'View Document';
    } else if (widget.item == null) {
      title = 'New Document';
    } else {
      title = 'Modify Document';
    }
    encoder();
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
    double kBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
              title: Text(title),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              actions: [
                Visibility(
                  maintainSize: false,
                  maintainAnimation: false,
                  maintainState: true,
                  visible: isKeyboardVisible,
                  child: IconButton(
                    onPressed: hideKeyboard,
                    icon: const Icon(Icons.keyboard_hide_outlined),
                    tooltip: isKeyboardVisible ? 'Hide Keyboard' : null,
                  ),
                ),
                IconButton(
                  onPressed: copy,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy',
                )
              ]),
          body: Padding(
            padding: EdgeInsets.only(bottom: kBoardHeight),
            child: SizedBox(
              height: netHeight,
              child: CupertinoScrollbar(
                controller: _scrollController,
                child: TextField(
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    scrollController: _scrollController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    smartQuotesType: SettingsService().smartQuotes
                        ? SmartQuotesType.disabled
                        : SmartQuotesType.enabled,
                    smartDashesType: SettingsService().smartDashes
                        ? SmartDashesType.disabled
                        : SmartDashesType.enabled,
                    scrollPhysics: const AlwaysScrollableScrollPhysics(),
                    decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.surface,
                        filled: true,
                        border: null,
                        enabledBorder: const UnderlineInputBorder(),
                        focusedBorder: const UnderlineInputBorder(),
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 8, 12, 8)),
                    controller: _jsonController),
              ),
            ),
          ),
          floatingActionButton: widget.collection.isReadonly()
              ? null
              : LoadableFloatingActionButton(
                  FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      onPressed: saveDialog,
                      tooltip: 'Save document.',
                      child: const Icon(Icons.save)),
                  isLoading));
    });
  }
}
