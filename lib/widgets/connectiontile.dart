import 'package:flutter/material.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/models/selectable.dart';

class ConnectionTile extends StatelessWidget {
  final Function(int, SelectType) onClick;
  final int index;
  final bool has_any_selected;
  final Selectable<Connection> selectable;

  const ConnectionTile(this.index, this.selectable, this.has_any_selected, this.onClick, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: ListTile(
        selected: selectable.isSelected,
        contentPadding: const EdgeInsets.fromLTRB(0,10,20,10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        tileColor: Theme.of(context).colorScheme.onInverseSurface,
        selectedTileColor: Theme.of(context).colorScheme.onErrorContainer,
        selectedColor: Theme.of(context).colorScheme.onError,
        minLeadingWidth: 12,
        horizontalTitleGap: 8,
        leading: ReorderableDragStartListener(
          child: Container(
              width: 22,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.drag_indicator, size: 20)
          ),
          index: index,
        ),
        onTap: () => onClick(index, SelectType.Tap),
        onLongPress: () => onClick(index, SelectType.LongPress),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [Icon(Icons.storage, color: selectable.isSelected ? Theme.of(context).colorScheme.onError : Theme.of(context).colorScheme.inverseSurface), const SizedBox(width: 5, height: 1), Text(selectable.item.name)],
        ),
        subtitle: Text(selectable.item.uri.replaceAll("", "\u{200B}"),overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 1),
        isThreeLine: false,
        trailing: selectable.isSelected
            ? const Icon(Icons.check_box)
            : (has_any_selected
            ? const Icon(Icons.check_box_outline_blank)
            : const Icon(Icons.keyboard_arrow_right)),
      ),
      padding: const EdgeInsets.only(bottom: 10),
    );
  }
}