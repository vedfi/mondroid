import 'package:flutter/material.dart';

import '../services/settingsservice.dart';

class FilterQueryForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final VoidCallback onHelp;

  const FilterQueryForm({
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
                'Filter Query',
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
            hintText: '{"key": "value" or {"\$operator"}}',
            helperText: 'All query operators are supported.\n'
                'Leave blank if you want to fetch all records.',
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
