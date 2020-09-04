import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class Loader{
    Loader(this.context);
    BuildContext context;
    Future<void> show() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
              child: AlertDialog(
          content: Container(
            width: 100,
            height: 100,
                    child: SpinKitChasingDots(
              size: 50,
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      );
    },
  );
}
void hide(){
 Navigator.of(context).pop();
}
}
