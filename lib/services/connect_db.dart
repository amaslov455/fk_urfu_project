import 'dart:async';
import 'package:provider/provider.dart';
import 'package:hello_flutter/excercise.dart';
import 'package:hello_flutter/user.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/auth.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class ConnectDataBase{

  static String host = 'urfu-fk.cxzes0jrvc0c.us-east-2.rds.amazonaws.com',
                user = 'admin',
                password = 'qwerty1608',
                db = 'urfufk';
  static int port = 3306;

  ConnectDataBase();


  Future<mysql.MySqlConnection> getConnection() async {
    var settings = new mysql.ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db
    );
    return await mysql.MySqlConnection.connect(settings);
  }


  // TODO: create DB connection
  List<String> namesExcercises = ['Отжимания',
                    'Подтягивания',
                    'Пресс'];

  List<String> descExcercises = ['Описание',
                                'Описание',
                                'Описание'];

  List<int> numberSets = [20,15,30];

  List<Excercise> listOfExcercises = [];
  List<int> listIds = [];

  Future getUserExcercises(int group_id, int user_id) async{

    String sql_query = 'select name, description, distance, time, isrunning, id from task where group_id = ?;';

    var conn = await getConnection();
    var results = await conn.query(sql_query, [group_id]);
    if (results.isEmpty == false){
      for (var row in results){
        listOfExcercises.add(Excercise(
          row[0],
          row[1],
          row[2],
          row[3],
          row[4],
          row[5]
        ));
      }

      print(listOfExcercises.length);
      
      for (var list_ex in listOfExcercises){
        listIds.add(list_ex.id);
      }


      sql_query = 'select distance, time, order_id from result where student_id = ?;';
      results = await conn.query(sql_query, [user_id]);
      if (results.isEmpty == false){
        for (var row in results){
          print(row[2]);
          var req_index = listIds.indexOf(row[2]);
          if (listOfExcercises[req_index].isRunning == 1){
            print(row[1]);
            listOfExcercises[req_index].timeDone = row[1];
            listOfExcercises[req_index].distanceDone = row[0];
            print('lol123');
          }
          listOfExcercises[req_index].isReady = true;
        }
      }
    }
    return listOfExcercises;
  }

  Future<bool> addExcerciseResult(GlobalKey<ScaffoldState> scaffoldKey, Excercise excercise, int user_id) async{
    try{
    scaffoldKey.currentState.showSnackBar(
                      new SnackBar(duration: new Duration(seconds: 4), content:
                      new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("  Синхронизация...")
                        ],
                      ),
                      ));
    double current_time = null;
    if (excercise.isRunning == 1){
      current_time = excercise.timeDone;
    }
    var conn = await getConnection();
    String sql_query = 'insert into result (distance, time, student_id, order_id, date) values (?,?,?,?,?);';
    await conn.query(sql_query, [excercise.volume, current_time, user_id, excercise.id, DateTime.now().toUtc()]);
    scaffoldKey.currentState.hideCurrentSnackBar();
    return true;
    }
    catch(e){
      scaffoldKey.currentState.hideCurrentSnackBar();
      scaffoldKey.currentState.showSnackBar(
                  new SnackBar(duration: new Duration(seconds: 4), content:
                  new Row(
                    children: <Widget>[
                      new Icon(IconData(59353, fontFamily: 'MaterialIcons')),
                      new Text("  Синхронизация не удалась")
                    ],
                  ),
      ));
      print(e.toString());
      return false;
    }
  }

  StreamController _streamController = StreamController<User>();

  Stream<User> get userUpdates => _streamController.stream;


  Future<List> logInUser(email, password) async {

    String sql_query = 'select name, id, group_id from student where email = ? and password = ?;';

    var conn = await getConnection();
    var results = await conn.query(sql_query, [email,password]);
    if (results.isEmpty){
      return null;
    }
    else{
      var res = results.first.fields;
      return [res['name'], res['id'], res['group_id']];
    }
  }

}