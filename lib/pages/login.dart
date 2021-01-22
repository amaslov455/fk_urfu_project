import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hello_flutter/services/connect_db.dart';
// import 'package:hello_flutter/user.dart';
import 'package:hello_flutter/auth.dart';
import 'package:provider/provider.dart';
import 'package:hello_flutter/pages/loading.dart';


class LogIn extends StatefulWidget {
  final LoadingOverlay overlayWidget;
  LogIn(this.overlayWidget);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final connect_db = ConnectDataBase();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  // @override
  // void initState() {
  //   connect_db.userUpdates.listen((event) {
  //     print(event.name);
  //   });
  //   super.initState();
  // }
  

  @override
  Widget build(BuildContext context) {

    AuthUser auth_user = context.watch<AuthUser>();

    var mainWidget = Scaffold(
      backgroundColor: Color.fromRGBO(255, 249, 225,1),
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        elevation: 0.0,
        title: Text('Вход через УрФУ'),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
               Container(
                  height: 120,
                  width: 400,
                  child: Image(
                    alignment: Alignment.topLeft,
                    image: NetworkImage('https://urfu.ru/fileadmin/user_upload/common_files/about/brand/UrFULogo_Full_Russian.png')),
                ),
              TextFormField(
               decoration: InputDecoration(
                hintText: 'логин'
                ),
                validator: (val) => val.isEmpty ? 'Введите email' : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(height: 12.0,),
              TextFormField(
                decoration: InputDecoration(
                hintText: 'пароль'
                ),
                validator: (val) => val.isEmpty ? 'Введите пароль' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(height: 20.0,),
              RaisedButton(
                color: Colors.pink[500],
                child: Text(
                  'Войти',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()){
                    setState(() {
                      // loading = true;
                      widget.overlayWidget.show();
                    });
                    dynamic userData = await connect_db.logInUser(email, password);
                    print(userData.runtimeType);
                    if (userData == null){
                      setState(() {
                        error = 'Неверный логин или пароль';
                        // loading = false;
                        widget.overlayWidget.hide();
                      });
                    }
                    else{
                      auth_user.sign_in(userData[0], userData[1], userData[2]);
                      // print('');
                    }
                  }
                }
              ),
              SizedBox(height:12.0,),
              Text(error,
              style: TextStyle(color: Colors.red, fontSize: 14.0)),
            ]
          ),
        ),
      ),
    );
    var loadingWidget = Loading();
    Widget currentWidget;

    if (loading){
      currentWidget = loadingWidget;
    }
    else{
      currentWidget = mainWidget;
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: currentWidget,

    );



}
}