import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/models/selectable.dart';

enum ExpandableType{
  Array,
  Obj
}

class ExpandableColumn extends StatefulWidget{
  final List<Widget> values;
  final ExpandableType expandableType;
  final Widget field;
  final EdgeInsets padding;
  ExpandableColumn(this.field, this.expandableType, this.padding, this.values);

  @override
  State<StatefulWidget> createState() => ExpandableColumnState();
}

class ExpandableColumnState extends State<ExpandableColumn>{

  bool isExpanded = false;

  void onPressed(){
    setState(() {
      this.isExpanded = !isExpanded;
    });
  }

  List<Widget> childrens(){
    List<Widget> result = <Widget>[];
    result.add(
      GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.field,
            Text(widget.expandableType == ExpandableType.Array ? 'Array' : 'Object'),
            Icon(isExpanded ? Icons.expand_more : Icons.keyboard_arrow_right, size: 18)
          ],
        ),
        onTap: onPressed,
      )
    );
    if(isExpanded){
      result.addAll(widget.values);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childrens(),
    );
  }

}

class RecordTile extends StatelessWidget {
  final Function(int, SelectType) onClick;
  final int index;
  final bool has_any_selected;
  final Selectable<Map<String, dynamic>> selectable;

  RecordTile(this.index, this.selectable,this.has_any_selected, this.onClick);

  Widget generate(int level, String key, dynamic value){
    var pad = EdgeInsets.only(left: level*10);
    if(value is Iterable<dynamic>){
      List<Widget> fields = <Widget>[];
      for(int i=0; i< value.length; i++){
        fields.add(
            generate(level+1, '${i}', value.elementAt(i))
        );
      }
      return ExpandableColumn(Padding(padding: pad, child: Text('${key}: ',style: TextStyle(fontWeight: FontWeight.w800))), ExpandableType.Array, pad, fields);
    }
    else if(value is Map<String,dynamic>){
      List<Widget> fields = <Widget>[];
      for(var sub_key in value.keys){
        fields.add(
            generate(level+1,sub_key, value[sub_key])
        );
      }
      return ExpandableColumn(Padding(padding: pad, child: Text('${key}: ',style: TextStyle(fontWeight: FontWeight.w800)),), ExpandableType.Obj, pad, fields);
    }
    else{
      return Padding(padding: pad, child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(text: '${key}: ', style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: '${value.toString()}'),
          ],
        ),
      ));
    }
  }

  Widget visualize(){
    List<Widget> fields = <Widget>[];
    for(var key in selectable.item.keys){
      if(key != '_id'){
        fields.add(
            generate(0, key, selectable.item[key])
        );
      }
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
      child: ListTile(
        selected: selectable.isSelected,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        selectedColor: Colors.red,
        dense: true,
        onTap: () => onClick(index, SelectType.Tap),
        onLongPress: () => onClick(index, SelectType.LongPress),
        title: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Icon(Icons.article, color: selectable.isSelected ? Colors.red : Colors.grey.shade600), SizedBox(width: 3, height: 1), Text(selectable.item['_id'].toString()), Spacer(),
              this.selectable.isSelected
                  ? Icon(Icons.check_box, color: Colors.red,)
                  : (has_any_selected
                  ? Icon(Icons.check_box_outline_blank, color: Colors.grey.shade600,)
                  : GestureDetector(child: Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade600,), onTap: ()=> onClick(index, SelectType.Navigate),))],
          ),
        ),
        subtitle: visualize(),
        // trailing: Column(
        //
        //   children: [this.selectable.isSelected
        //       ? Icon(Icons.check_box)
        //       : (has_any_selected
        //       ? Icon(Icons.check_box_outline_blank)
        //       : Icon(Icons.keyboard_arrow_right)),],
        // )
      ),
    );
  }
}


