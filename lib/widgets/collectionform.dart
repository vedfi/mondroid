import 'package:flutter/material.dart';

import '../services/settingsservice.dart';

class CollectionForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CollectionForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Collection',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          smartQuotesType: SettingsService().smartQuotes
              ? SmartQuotesType.disabled
              : SmartQuotesType.enabled,
          smartDashesType: SettingsService().smartDashes
              ? SmartDashesType.disabled
              : SmartDashesType.enabled,
          decoration: const InputDecoration(
            hintText: 'Name',
          ),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
