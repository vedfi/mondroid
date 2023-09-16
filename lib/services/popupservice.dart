import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mondroid/main.dart';

class PopupService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(String message) {
    message = message.trimRight();
    ThemeData themeData = View.of(scaffoldMessengerKey.currentContext!)
                .platformDispatcher
                .platformBrightness ==
            Brightness.light
        ? getLightTheme()
        : getDarkTheme();
    double maxHeight =
        MediaQuery.of(scaffoldMessengerKey.currentContext!).size.height * 0.2;
    final SnackBar snackBar = SnackBar(
      padding: EdgeInsets.zero,
      backgroundColor: themeData.colorScheme.onErrorContainer,
      content:
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: SingleChildScrollView(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 5),
                child: Text(message,
                    style: TextStyle(color: themeData.colorScheme.onError)),
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  Fluttertoast.showToast(msg: "Copied to clipboard.");
                },
                tooltip: "Copy",
                icon: Icon(
                  Icons.copy,
                  color: themeData.colorScheme.onError,
                )),
            IconButton(
                onPressed: () {
                  scaffoldMessengerKey.currentState?.clearSnackBars();
                },
                tooltip: "Close",
                icon: Icon(
                  Icons.close,
                  color: themeData.colorScheme.onError,
                ))
          ],
        ),
      ]),
      duration: const Duration(minutes: 5),
      dismissDirection: DismissDirection.none,
      closeIconColor: themeData.colorScheme.onError,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    });
  }
}
