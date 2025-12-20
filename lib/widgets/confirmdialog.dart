import 'package:flutter/material.dart';

class ConfirmDialog {
  static Widget create(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String okText,
    bool isDestructive,
  ) {
    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
              foregroundColor: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary),
          child: Text(okText),
        ),
      ],
    );
  }
}
