import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hello_flutter/excercise.dart';
import 'package:hello_flutter/pages/excercise_page.dart';
import 'package:hello_flutter/services/connect_db.dart';
import 'package:provider/provider.dart';
import 'package:hello_flutter/auth.dart';
import 'package:hello_flutter/pages/loading.dart';

class Home extends StatefulWidget {
  final LoadingOverlay overlayWidget;
  Home(this.overlayWidget);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Widget> listCardExcercises = [];
  List listOfExcercises = [];
  Future futureList;
  AuthUser auth_user;

  String user_name;
  String user_surname = 'Маслов';
  String user_groupname = 'РИ-170018';


  int curExcerciseNumber;

  Widget checkDone(excercise){
    if (excercise.isReady == true){
      return Container(
                    child: Icon(
                      IconData(60381, fontFamily: 'MaterialIcons'),
                      color: Colors.orange[400],
                      size: 40.0,
                    )
                );
    }
    else{
      return Container(
                    child: Icon(
                      null,
                      color: Colors.white,
                      size: 20.0,
                    )
                );
    }
  }

  void changeDone(excercise){
    if (excercise.isReady == true){
      excercise.isReady = false;
    }
    else{
      excercise.isReady = true;
    }
  }

  StreamController readyExcerciseControl = StreamController<bool>();
  // Stream<bool> get excerciseUpdates => _readyExcerciseControl.stream;

  @override
  void initState() {
    Future.delayed(Duration.zero,() async {
    ConnectDataBase connect_db = ConnectDataBase();
    auth_user = context.read<AuthUser>();
    print(auth_user.name);
    var list = await connect_db.getUserExcercises(auth_user.group_id, auth_user.id);
  
    widget.overlayWidget.hide();
      setState(() {
        listOfExcercises = list;
      });
    });
    // futureList = _getDataExcercises(auth_user.group_id);

    readyExcerciseControl.stream.listen((event) {
      print(event);
      setState(() {
        listOfExcercises[curExcerciseNumber].isReady = event;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){

    if (auth_user == null){
      user_name = 'null';
    }
    else{
      user_name = auth_user.name;
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Text('Упражнения'),
        ),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              auth_user.sign_out();
            },
            icon: Icon(Icons.person,
                  color: Colors.white,), 
            label: Text('Выйти',
                        style: TextStyle(color: Colors.white),)
            )
        ],
      ),
      backgroundColor: Color.fromRGBO(255, 253, 243,1),
      // body: Column(
      //   crossAxisAlignment: CrossAxisAlignment.stretch,
      //   children: listCardExcercises,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listOfExcercises.length,
              itemBuilder: (context, index){
                return Card(
                    child: Ink(
                      color: Color.fromRGBO(255, 253, 243,1),
                        child: ListTile(
                        onTap: () async {
                          curExcerciseNumber = index;
                          dynamic result = await Navigator
                            .pushNamed(context, '/excercise_page', arguments: [listOfExcercises[index], readyExcerciseControl, auth_user.id]);
                        },
                        title: Text(listOfExcercises[index].name),
                        trailing: checkDone(listOfExcercises[index]),
                      ),
                    ),
                );
              }
              ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 0.5,
            indent: 40,
            endIndent: 40,
            height: 2,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Center(
                child: Text('Выполнить до: 30.01.2021'),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: Colors.orange[400],
                height: 150,
                child: DrawerHeader(
                  
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user_groupname,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Text(user_surname,
                      style: TextStyle(color: Colors.white),),
                      SizedBox(height: 3.0,),
                      Text(user_name,
                      style: TextStyle(color: Colors.white),),
                      SizedBox(height: 10.0,),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[400],
                  ),
                ),
              ),
              ListTile(
                title: Text('Расписание',
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                onTap: () {
                },
              ),
              ListTile(
                title: Text('Брс',
                    style: TextStyle(
                      fontSize: 16
                    ),),
                onTap: () {
                },
              ),
            ],
          ),
        ),
    );
  }

}