import 'package:flutter/material.dart';
import 'package:mondroid/models/collection.dart';
import 'package:mondroid/models/selectable.dart';

class CollectionTile extends StatelessWidget {
  final Function(int, SelectType) onClick;
  final int index;
  final bool hasAnySelected;
  final Selectable<Collection> selectable;

  const CollectionTile(
      {Key? key,
      required this.index,
      required this.selectable,
      required this.hasAnySelected,
      required this.onClick})
      : super(key: key);

  String getDocumentText() {
    switch (selectable.item.count) {
      case -2:
        {
          return '...';
        }
      case -1:
        {
          return 'Error';
        }
      case 0:
        {
          return 'No document';
        }
      case 1:
        {
          return '1 document';
        }
      default:
        {
          return '${selectable.item.count} documents';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selectable.isSelected,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      tileColor: Theme.of(context).colorScheme.onInverseSurface,
      selectedTileColor: Theme.of(context).colorScheme.onErrorContainer,
      selectedColor: Theme.of(context).colorScheme.onError,
      onTap: () => onClick(index, SelectType.tap),
      onLongPress: () => onClick(index, SelectType.longPress),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.folder,
              color: selectable.isSelected
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.inverseSurface),
          const SizedBox(width: 5, height: 1),
          Text(selectable.item.name)
        ],
      ),
      subtitle: Text(getDocumentText()),
      trailing: selectable.isSelected
          ? const Icon(Icons.check_box)
          : (hasAnySelected
              ? const Icon(Icons.check_box_outline_blank)
              : const Icon(Icons.keyboard_arrow_right)),
    );
  }
}
