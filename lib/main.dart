import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mondroid/pages/collections.dart';
import 'package:mondroid/pages/edit.dart';
import 'package:mondroid/pages/home.dart';
import 'package:mondroid/pages/records.dart';
import 'package:mondroid/services/popupservice.dart';

void main() {
  runApp(const MondroidApp());
}

ThemeData getLightTheme() {
  return ThemeData.from(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green).copyWith(
          tertiary: const Color(0xff3b6939),
          onInverseSurface: const Color(0xfffcfdf6),
          surface: const Color(0xfff0f1eb),
          onError: const Color(0xffba1a1a),
          onErrorContainer: const Color(0xffffdad6)));
}

ThemeData getDarkTheme() {
  return ThemeData.from(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green, brightness: Brightness.dark)
          .copyWith(
              tertiary: Colors.grey[850]!,
              surface: Colors.grey[900]!,
              onInverseSurface: Colors.grey[850]!,
              primary: const Color(0xff78dd77),
              onErrorContainer: const Color(0xfffeb4ab)));
}

class MondroidApp extends StatelessWidget {
  const MondroidApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
          case '/collections':
            {
              String arg = settings.arguments as String;
              return CupertinoPageRoute(
                  builder: (_) => Collections(title: arg));
            }
          case '/records':
            {
              String arg = settings.arguments as String;
              return CupertinoPageRoute(
                  builder: (_) => Records(collectionName: arg));
            }
          case '/edit':
            {
              List<dynamic> args = settings.arguments as List<dynamic>;
              dynamic id = args[1] == null ? null : args[1]['_id'];
              return CupertinoPageRoute(
                  builder: (_) =>
                      Edit(collectionName: args[0], itemId: id, item: args[1]));
            }
          default:
            return null;
        }
      },
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: ThemeMode.system,
    );
  }
}
