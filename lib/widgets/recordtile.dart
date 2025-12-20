import 'package:flutter/material.dart';
import 'package:mondroid/models/selectable.dart';
import 'package:mondroid/utilities/recordtilestringifier.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

enum ExpandableType { array, obj }

class ExpandableColumn extends StatefulWidget {
  final List<Widget> values;
  final ExpandableType expandableType;
  final Widget field;
  final EdgeInsets padding;

  const ExpandableColumn(
      this.field, this.expandableType, this.padding, this.values,
      {super.key});

  @override
  State<StatefulWidget> createState() => ExpandableColumnState();
}

class ExpandableColumnState extends State<ExpandableColumn> {
  bool isExpanded = false;

  void onPressed() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  List<Widget> childrens() {
    List<Widget> result = <Widget>[];
    result.add(GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.field,
          Text(widget.expandableType == ExpandableType.array
              ? 'Array'
              : 'Object'),
          Icon(isExpanded ? Icons.expand_more : Icons.keyboard_arrow_right,
              size: 18)
        ],
      ),
    ));
    if (isExpanded) {
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
  final bool hasAnySelected;
  final Selectable<Map<String, dynamic>> selectable;
  final bool showOidTimestamp;

  const RecordTile(this.index, this.selectable, this.hasAnySelected,
      this.onClick, this.showOidTimestamp,
      {super.key});

  Widget generate(int level, String key, dynamic value) {
    var pad = EdgeInsets.only(left: level * 10);
    if (value is Iterable<dynamic>) {
      List<Widget> fields = <Widget>[];
      for (int i = 0; i < value.length; i++) {
        fields.add(generate(level + 1, '$i', value.elementAt(i)));
      }
      return ExpandableColumn(
          Padding(
              padding: pad,
              child: Text('$key: ',
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          ExpandableType.array,
          pad,
          fields);
    } else if (value is Map<String, dynamic>) {
      List<Widget> fields = <Widget>[];
      for (var subKey in value.keys) {
        fields.add(generate(level + 1, subKey, value[subKey]));
      }
      return ExpandableColumn(
          Padding(
            padding: pad,
            child: Text('$key: ',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          ExpandableType.obj,
          pad,
          fields);
    } else {
      return Padding(
          padding: pad,
          child: Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '$key: ',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(text: RecordTileStringifier.stringify(value)),
              ],
            ),
          ));
    }
  }

  Widget visualize() {
    List<Widget> fields = <Widget>[];
    for (var key in selectable.item.keys) {
      if (key != '_id') {
        fields.add(generate(0, key, selectable.item[key]));
      }
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: selectable.isSelected
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: ListTile(
        selected: selectable.isSelected,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        selectedColor: Theme.of(context).colorScheme.onError,
        dense: true,
        onTap: () => onClick(index, SelectType.tap),
        onLongPress: () => onClick(index, SelectType.longPress),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.article,
                  color: selectable.isSelected
                      ? Theme.of(context).colorScheme.onError
                      : Theme.of(context).colorScheme.inverseSurface),
              const SizedBox(width: 3, height: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showOidTimestamp &&
                      selectable.item['_id'] is mongo.ObjectId) ...[
                    Text(
                        (selectable.item['_id'] as mongo.ObjectId)
                            .dateTime
                            .toIso8601String(),
                        style: const TextStyle(fontSize: 11))
                  ],
                  Text(RecordTileStringifier.stringify(selectable.item['_id'])),
                ],
              ),
              const Spacer(),
              selectable.isSelected
                  ? Icon(Icons.check_box,
                      color: Theme.of(context).colorScheme.onError)
                  : (hasAnySelected
                      ? Icon(Icons.check_box_outline_blank,
                          color: Theme.of(context).colorScheme.inverseSurface)
                      : GestureDetector(
                          child: const Icon(Icons.keyboard_arrow_right),
                          onTap: () => onClick(index, SelectType.navigate),
                        ))
            ],
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
