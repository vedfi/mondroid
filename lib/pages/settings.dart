import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mondroid/services/settingsservice.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SettingsService controller;
  bool maskPassword = false;
  bool showOidTimestamp = false;
  bool smartQuotes = false;
  bool smartDashes = false;
  bool systemCollections = false;
  int pageSize = 0;

  @override
  void initState() {
    super.initState();
    controller = SettingsService();
    maskPassword = controller.maskPassword;
    showOidTimestamp = controller.showOidTimestamp;
    smartQuotes = controller.smartQuotes;
    smartDashes = controller.smartDashes;
    pageSize = controller.pageSize;
    systemCollections = controller.systemCollections;
  }

  Future<void> _onSmartDashesChanged(bool? value) async {
    if (value == null) return;
    controller.updateSmartDashes(value);
    setState(() {
      smartDashes = value;
    });
  }

  Future<void> _onSmartQuotesChanged(bool? value) async {
    if (value == null) return;
    controller.updateSmartQuotes(value);
    setState(() {
      smartQuotes = value;
    });
  }

  Future<void> _onSystemCollectionsChanged(bool? value) async {
    if (value == null) return;
    controller.updateSystemCollections(value);
    setState(() {
      systemCollections = value;
    });
  }

  Future<void> _onOidTimestampChanged(bool? value) async {
    if (value == null) return;
    controller.updateTimestamp(value);
    setState(() {
      showOidTimestamp = value;
    });
  }

  Future<void> _onMaskPasswordChanged(bool? value) async {
    if (value == null) return;
    controller.updateMaskPassword(value);
    setState(() {
      maskPassword = value;
    });
  }

  Future<void> _onPageSizeChanged(int? value) async {
    if (value == null) return;
    controller.updatePageSize(value);
    setState(() {
      pageSize = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: controller.themeMode,
          builder: (context, currentTheme, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode)),
                        ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.settings)),
                        ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode)),
                      ],
                      selected: {currentTheme},
                      onSelectionChanged: (newSelection) {
                        final selected = newSelection.first;
                        controller.updateTheme(selected);
                      },
                      showSelectedIcon: false,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Page Size',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 5,
                          label: Text('5'),
                        ),
                        ButtonSegment(
                          value: 10,
                          label: Text('10'),
                        ),
                        ButtonSegment(
                          value: 20,
                          label: Text('20'),
                        ),
                        ButtonSegment(
                          value: 50,
                          label: Text('50'),
                        ),
                      ],
                      selected: {pageSize},
                      onSelectionChanged: (newSelection) {
                        final selected = newSelection.first;
                        _onPageSizeChanged(selected);
                      },
                      showSelectedIcon: false,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Text('Advanced', style: TextStyle(fontSize: 18)),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: maskPassword,
                        onChanged: _onMaskPasswordChanged,
                        activeColor: Theme.of(context).colorScheme.primary),
                    const SizedBox(
                      width: 5,
                    ),
                    const Expanded(
                      child: Text('Mask password in connection string'),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: showOidTimestamp,
                        onChanged: _onOidTimestampChanged,
                        activeColor: Theme.of(context).colorScheme.primary),
                    const SizedBox(
                      width: 5,
                    ),
                    const Expanded(
                      child: Text('Show embedded timestamp of ObjectId'),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: systemCollections,
                        onChanged: _onSystemCollectionsChanged,
                        activeColor: Theme.of(context).colorScheme.primary),
                    const SizedBox(
                      width: 5,
                    ),
                    const Expanded(
                      child: Text('Show system collections'),
                    )
                  ],
                ),
                if (Platform.isIOS) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                          value: smartQuotes,
                          onChanged: _onSmartQuotesChanged,
                          activeColor: Theme.of(context).colorScheme.primary),
                      const SizedBox(
                        width: 5,
                      ),
                      const Expanded(
                        child: Text('Disable smart quotes'),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                          value: smartDashes,
                          onChanged: _onSmartDashesChanged,
                          activeColor: Theme.of(context).colorScheme.primary),
                      const SizedBox(
                        width: 5,
                      ),
                      const Expanded(
                        child: Text('Disable smart dashes'),
                      )
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
