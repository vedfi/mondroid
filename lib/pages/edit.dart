import 'dart:convert';
import 'dart:developer';

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
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(widget.item == null ? 'New Document' : 'Modify Document'),
        ),
        body: Container(
          height: netHeight,
          child: TextField(
            expands: true,
            minLines: null,
            maxLines: null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: null,
            ),
            controller: _jsonController,
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