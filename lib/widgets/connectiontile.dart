import 'package:flutter/material.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/models/selectable.dart';

class ConnectionTile extends StatelessWidget {
  final Function(int, SelectType) onClick;
  final int index;
  final bool has_any_selected;
  final Selectable<Connection> selectable;

  ConnectionTile(this.index, this.selectable, this.has_any_selected, this.onClick, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: ListTile(
        selected: selectable.isSelected,
        contentPadding: EdgeInsets.fromLTRB(0,10,20,10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        tileColor: Colors.white,
        selectedTileColor: Colors.red.shade50,
        selectedColor: Colors.red,
        minLeadingWidth: 12,
        horizontalTitleGap: 8,
        leading: ReorderableDragStartListener(
          child: Container(
              width: 22,
              alignment: Alignment.centerLeft,
              child: Icon(Icons.drag_indicator, size: 20)
          ),
          index: index,
        ),
        onTap: () => onClick(index, SelectType.Tap),
        onLongPress: () => onClick(index, SelectType.LongPress),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [Icon(Icons.storage, color: selectable.isSelected ? Colors.red : Colors.grey.shade600), SizedBox(width: 5, height: 1), Text(selectable.item.name)],
        ),
        subtitle: Text(selectable.item.uri.replaceAll("", "\u{200B}"),overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 1),
        isThreeLine: false,
        trailing: selectable.isSelected
            ? Icon(Icons.check_box)
            : (has_any_selected
            ? Icon(Icons.check_box_outline_blank)
            : Icon(Icons.keyboard_arrow_right)),
      ),
      padding: EdgeInsets.only(bottom: 10),
    );
  }
}