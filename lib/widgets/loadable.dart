import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loadable extends StatelessWidget {
  final Widget _widget;
  final bool _isLoading;

  const Loadable(this._widget, this._isLoading, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? _widget
        : Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor, size: 25),
                const Text('Please wait..')
              ],
            ));
  }
}

class LoadableFloatingActionButton extends StatelessWidget {
  final FloatingActionButton _widget;
  final bool _isLoading;

  const LoadableFloatingActionButton(this._widget, this._isLoading, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? _widget
        : FloatingActionButton(
            onPressed: null,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.background, size: 10));
  }
}
