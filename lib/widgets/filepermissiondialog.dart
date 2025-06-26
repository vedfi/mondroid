import 'package:flutter/material.dart';

class PermissionDialog extends StatelessWidget {
  final String message;
  final VoidCallback onOpenSettings;

  const PermissionDialog({super.key, 
    required this.message,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permission Required'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onOpenSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    );
  }
}
