import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mondroid/pages/collections.dart';
import 'package:mondroid/pages/home.dart';
import 'package:mondroid/pages/records.dart';

void main() {
  runApp(const MondroidApp());
}

class MondroidApp extends StatelessWidget {
  const MondroidApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mondroid',
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch(settings.name){
            case '/':{
              return MaterialPageRoute(
                  builder: (_) => const Home(title: 'Mondroid'));
            }
            case '/collections':{
              String arg = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => Collections(title: arg));
            }
            case '/records':{
              String arg = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => Records(collectionName: arg));
            }
          }
        },
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blueGrey,
        ));
  }
}
