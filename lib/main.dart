import 'package:flutter/material.dart';
import 'package:hello_flutter/auth.dart';
import 'package:hello_flutter/pages/excercise_page.dart';
import 'package:hello_flutter/pages/home.dart';
import 'package:hello_flutter/excercise.dart';
import 'package:hello_flutter/pages/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_flutter/pages/login.dart';
import 'package:hello_flutter/services/connect_db.dart';
import 'package:hello_flutter/user.dart';
import 'package:provider/provider.dart';
import 'package:hello_flutter/wrapper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var overlayWidget = LoadingOverlay.of(context);

    return ChangeNotifierProvider(
      create:(_) => AuthUser(),
      child: MaterialApp(
        initialRoute: '/login',
        // routes: {
        //     '/':(context) => Loading(),
        //     '/home':(context) => Home(),
        //     '/excercise_page':(context) => Excercise_Page(),
        //   },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/loading':
              return MaterialPageRoute(
                  builder: (_) => Loading(), settings: settings);
            case '/home':
              return MaterialPageRoute(
                  builder: (_) => Home(overlayWidget), settings: settings);
            case '/login':
              return MaterialPageRoute(
                  builder: (_) => Wrapper(), settings: settings);
            case '/excercise_page':
              return CupertinoPageRoute(
                  builder: (_) => Excercise_Page(), settings: settings);
          }
        }
      ),
    );
  }
}

// class CustomMaterialPageRoute extends CupertinoPageRoute {
//   @protected
//   bool get hasScopedWillPopCallback {
//     return false;
//   }
//   CustomMaterialPageRoute({
//     @required WidgetBuilder builder,
//     RouteSettings settings,
//     bool maintainState = true,
//     bool fullscreenDialog = false,
//   }) : super(
//           builder: builder,
//           settings: settings,
//           maintainState: maintainState,
//           fullscreenDialog: fullscreenDialog,
//         );
// }


 