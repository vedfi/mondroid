import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mondroid/services/mongoservice.dart';
import 'package:mondroid/utilities/customjsondecoder.dart';
import 'package:mondroid/utilities/customjsonencoder.dart';
import 'package:mondroid/widgets/confirmdialog.dart';
import 'package:mondroid/widgets/loadable.dart';

String jsonEncode(dynamic item){
  return CustomJsonEncoder.Encode(item);
}

dynamic jsonDecode(String json){
  return CustomJsonDecoder.Decode(json);
}

class Edit extends StatefulWidget{
  final String collectionName;
  final dynamic item_id;
  final dynamic item;
  const Edit({Key? key, required this.collectionName, this.item_id, this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<Edit>{
  bool isLoading = false;
  TextEditingController _jsonController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  Future<void> encoder() async{
    String encoded = widget.item_id == null ?'{\n\n}' : await compute(jsonEncode, widget.item);
    setState(() {
      _jsonController.text = encoded;
    });
  }


  Future<void> saveDialog() async {
    bool? ok = await showDialog(
        context: context,
        builder: (ctx) {
          return ConfirmDialog().Build(context, 'Save record', 'Are you sure you want to continue?', 'Cancel', 'Save');
        });
    if (ok == true) {
      await save();
    }
  }

  Future<void> save() async{
    setState(() {
      isLoading = true;
    });
    if(_jsonController.value.text.isNotEmpty){
      try{
        dynamic obj = await compute(jsonDecode,_jsonController.value.text);
        bool result = false;
        if(widget.item_id != null){
          //update
          obj.removeWhere((key, value) => key == '_id');
          result = await MongoService().updateRecord(widget.collectionName, widget.item_id, obj);
        }
        else{
          //insert
          result = await MongoService().insertRecord(widget.collectionName, obj);
        }
        if(result){
          Navigator.of(context).pop();
        }
      }
      catch(e){
        Fluttertoast.showToast(msg: 'Invalid JSON.');
      }
    }
    else{
      Fluttertoast.showToast(msg: 'Document is empty.');
    }
    setState(() {
      isLoading = false;
    });
  }
  
  void copy(){
    var json_text = _jsonController.value.text;
    if(json_text.isNotEmpty){
      Clipboard.setData(ClipboardData(text: json_text));
      Fluttertoast.showToast(msg: "Document copied to clipboard.");
    }
    else{
      Fluttertoast.showToast(msg: "Nothing to copy.");
    }
  }

  @override
  void initState(){
    super.initState();
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(widget.item == null ? 'New Document' : 'Modify Document'),
          actions: [IconButton(onPressed: copy, icon: Icon(Icons.copy, color: Colors.white,), tooltip: 'Copy',)],
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: kBoardHeight),
          child: Container(
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
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: null,
                    contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 8)
                ),
                controller: _jsonController,
              ),
            ),
          ),
        ),
        floatingActionButton: LoadableFloatingActionButton(
          FloatingActionButton(
            onPressed: saveDialog,
            tooltip: 'Save document.',
            child: const Icon(Icons.save)), isLoading)
    );
  }
}