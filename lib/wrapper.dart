import 'package:hello_flutter/pages/login.dart';
import 'package:hello_flutter/user.dart';
import 'package:hello_flutter/auth.dart';
import 'services/connect_db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_flutter/pages/home.dart';
import 'package:hello_flutter/pages/loading.dart';

  class Wrapper extends StatefulWidget {

    @override
    _WrapperState createState() => _WrapperState();
  }

  
  class _WrapperState extends State<Wrapper> {

    // final connect_db = ConnectDataBase();
    

    String name;
    @override
    void initState() {
      // ConnectDataBase().userUpdates.listen((event) {
      //   setState(() {
      //     name = event.name;
      //   });
      //   print(name);
      // });
      super.initState();
    }

    @override
    Widget build(BuildContext context) {
      // final user1 = Provider.of<User>(context);
      // final user1 = context.watch<User>();
      var overlayWidget = LoadingOverlay.of(context);
      AuthUser current_auth = context.watch<AuthUser>();

      // if (current_auth.isAuth){
      //   return Home();
      // }
      // else{
      //   return LogIn();
      // }



      return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: current_auth.isAuth ? Home(overlayWidget) : LogIn(overlayWidget),

    );
    }
}