import 'package:flutter/material.dart';
import 'package:mondroid/models/connection.dart';
import 'package:mondroid/models/selectable.dart';

class ConnectionTile extends StatelessWidget {
  final Function(int, SelectType) onClick;
  final int index;
  final bool hasAnySelected;
  final Selectable<Connection> selectable;

  const ConnectionTile(
      this.index, this.selectable, this.hasAnySelected, this.onClick,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        selected: selectable.isSelected,
        contentPadding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        tileColor: Theme.of(context).colorScheme.onInverseSurface,
        selectedTileColor: Theme.of(context).colorScheme.onErrorContainer,
        selectedColor: Theme.of(context).colorScheme.onError,
        minLeadingWidth: 12,
        horizontalTitleGap: 8,
        leading: ReorderableDragStartListener(
          index: index,
          child: Container(
              width: 22,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.drag_indicator, size: 20)),
        ),
        onTap: () => onClick(index, SelectType.tap),
        onLongPress: () => onClick(index, SelectType.longPress),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.storage,
                color: selectable.isSelected
                    ? Theme.of(context).colorScheme.onError
                    : Theme.of(context).colorScheme.inverseSurface),
            const SizedBox(width: 5, height: 1),
            Flexible(child: Text(selectable.item.name,
                overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 1))
          ],
        ),
        subtitle: Text(selectable.item.uri.replaceAll("", "\u{200B}"),
            overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 1),
        isThreeLine: false,
        trailing: selectable.isSelected
            ? const Icon(Icons.check_box)
            : (hasAnySelected
                ? const Icon(Icons.check_box_outline_blank)
                : const Icon(Icons.keyboard_arrow_right)),
      ),
    );
  }
}
