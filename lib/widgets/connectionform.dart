import 'package:flutter/material.dart';

import '../services/settingsservice.dart';

class ConnectionForm extends StatelessWidget {
  final bool isAdd;
  final TextEditingController nameController;
  final TextEditingController uriController;
  final VoidCallback onSubmit;
  final VoidCallback onHelp;

  const ConnectionForm({
    super.key,
    required this.isAdd,
    required this.nameController,
    required this.uriController,
    required this.onSubmit,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                isAdd ? 'Add Connection' : 'Edit Connection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              onPressed: onHelp,
              icon: const Icon(Icons.help_outline, size: 22),
              tooltip: 'Help',
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          smartQuotesType: SettingsService().smartQuotes
              ? SmartQuotesType.disabled
              : SmartQuotesType.enabled,
          smartDashesType: SettingsService().smartDashes
              ? SmartDashesType.disabled
              : SmartDashesType.enabled,
          decoration: const InputDecoration(
            hintText: "Name",
            helperText: 'Will be used as title.',
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: uriController,
          textInputAction: TextInputAction.done,
          smartQuotesType: SettingsService().smartQuotes
              ? SmartQuotesType.disabled
              : SmartQuotesType.enabled,
          smartDashesType: SettingsService().smartDashes
              ? SmartDashesType.disabled
              : SmartDashesType.enabled,
          decoration: const InputDecoration(
            hintText: "Uri",
            helperText: 'Uri with database name.',
          ),
        ),

        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text(isAdd ? 'Add' : 'Edit'),
        ),
      ],
    );
  }
}
