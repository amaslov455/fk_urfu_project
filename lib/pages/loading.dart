import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hello_flutter/excercise.dart';
import 'package:hello_flutter/services/connect_db.dart';
import 'package:flutter/cupertino.dart';

class LoadingOverlay {
  BuildContext _context;

  void hide() {
    Navigator.of(_context).pop();
  }

  void show() {
     showGeneralDialog(
        context: _context,
        barrierDismissible: false,
        pageBuilder: (
        BuildContext context, 
        Animation<double> animation, 
        Animation<double> secondaryAnimation) {
            return Loading();
        },
        transitionDuration: Duration(milliseconds: 250),
        transitionBuilder: (
            BuildContext context, 
            Animation<double> animation, 
            Animation<double> secondaryAnimation, 
            Widget child) {
          return Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          );
        },

        );
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}

class Loading extends StatelessWidget {
@override
  Widget build(BuildContext context) {
        return Scaffold(
      body: Center(
          child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.orange[400], Colors.pink[500]])),
        child: Center(
        child: SpinKitFadingCircle(
          color: Colors.white,
          size: 70.0,
        ),
      )
      )));
  }
}