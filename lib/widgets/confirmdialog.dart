import 'package:flutter/material.dart';

class ConfirmDialog{

  Widget Build(BuildContext context){
    return AlertDialog(
      title: Text('Delete Connection(s)'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [Text('This action cannot be undone. Are you sure you want to continue?')],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Delete')),
        TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                primary: Colors.white
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('Cancel')),
      ],
    );
  }

}