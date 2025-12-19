import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/pages/collections.dart';
import 'package:mondroid/pages/edit.dart';
import 'package:mondroid/pages/home.dart';
import 'package:mondroid/pages/records.dart';
import 'package:mondroid/pages/settings.dart';
import 'package:mondroid/services/popupservice.dart';
import 'package:mondroid/services/settingsservice.dart';

import 'models/collection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().load();
  runApp(MondroidApp(settingsService: SettingsService()));
}

ThemeData getLightTheme() {
  final base = ThemeData.from(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green).copyWith(
          tertiary: const Color(0xff3b6939),
          onInverseSurface: const Color(0xfffcfdf6),
          surface: const Color(0xfff0f1eb),
          onError: const Color(0xffba1a1a),
          onErrorContainer: const Color(0xffffdad6)));

  return base.copyWith(
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  final base = ThemeData.from(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green, brightness: Brightness.dark)
          .copyWith(
              tertiary: Colors.grey[850]!,
              surface: Colors.grey[900]!,
              onInverseSurface: Colors.grey[850]!,
              primary: const Color(0xff78dd77),
              onErrorContainer: const Color(0xfffeb4ab)));

  return base.copyWith(
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}

class MondroidApp extends StatelessWidget {
  final SettingsService settingsService;

  const MondroidApp({super.key, required this.settingsService});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: settingsService.themeMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Mondroid',
            initialRoute: '/',
            scaffoldMessengerKey: PopupService.scaffoldMessengerKey,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  {
                    return CupertinoPageRoute(
                        builder: (_) => const Home(title: 'Mondroid'));
                  }
                case '/settings':
                  {
                    return CupertinoPageRoute(builder: (_) => const Settings());
                  }
                case '/collections':
                  {
                    String arg = settings.arguments as String;
                    return CupertinoPageRoute(
                        builder: (_) => Collections(title: arg));
                  }
                case '/records':
                  {
                    Collection arg = settings.arguments as Collection;
                    return CupertinoPageRoute(
                        builder: (_) => Records(collection: arg));
                  }
                case '/edit':
                  {
                    List<dynamic> args = settings.arguments as List<dynamic>;
                    dynamic id = args[1] == null ? null : args[1]['_id'];
                    return CupertinoPageRoute(
                        builder: (_) => Edit(
                            collection: args[0], itemId: id, item: args[1]));
                  }
                default:
                  return null;
              }
            },
            theme: getLightTheme(),
            darkTheme: getDarkTheme(),
            themeMode: themeMode,
          );
        });
  }
}
