import 'package:flutter/material.dart';

import '../services/settingsservice.dart';

class SortQueryForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final VoidCallback onHelp;

  const SortQueryForm({
    super.key,
    required this.controller,
    required this.onApply,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Sort Query',
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
          controller: controller,
          maxLines: 7,
          smartQuotesType: SettingsService().smartQuotes
              ? SmartQuotesType.disabled
              : SmartQuotesType.enabled,
          smartDashesType: SettingsService().smartDashes
              ? SmartDashesType.disabled
              : SmartDashesType.enabled,
          decoration: const InputDecoration(
            hintText: '{"field": "\$asc" or "\$desc"}',
            helperText: 'Multiple sorting criteria supported.\n'
                'Leave blank if you don\'t want to use sorting.',
          ),
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onApply,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
