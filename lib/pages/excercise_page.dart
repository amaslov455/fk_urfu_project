import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:hello_flutter/excercise.dart';
import 'package:hello_flutter/services/connect_db.dart';
import 'dart:math';
import 'package:pedometer/pedometer.dart';

class Excercise_Page extends StatefulWidget {
  @override
  _Excercise_PageState createState() => _Excercise_PageState();

}

class _Excercise_PageState extends State<Excercise_Page> {
  ConnectDataBase connect_db;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List getted;
  Excercise excercise;
  StreamController excerciseControl;
  int user_id;

  Color backcolor = Color.fromRGBO(255, 253, 243,1);

  // Таймер
  double counter = 0;
  double endcounter = 0;
  bool isTimerStart = false;
  bool anime = false;
  double currentDistance = 0;
  String tooslowText = '';

  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  double _numerox;
  double _kmx;
  double _burnedx;

  void changeTimerStatus(){
    if (isTimerStart){
      isTimerStart = false;
    }
    else{
      isTimerStart = true;
    }
  }
  Timer _timer;

  void startTimer() {
      const oneSec = const Duration(seconds: 1);
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) async {
          if (isTimerStart) {
            if (currentDistance < excercise.volume * 1000){
              if (counter >= endcounter){
                // isTimerStart = false;
                excercise.tooslow = true;
                tooslowText = 'Слишком медленно';
              }
              setState(() {
                currentDistance = currentDistance + getDistance(3.7, 4.2);
                counter++;
              });
            }
            else{
              isTimerStart = false;
              if (excercise.tooslow == false){
                tooslowText = 'Упражнение выполнено';
                if ((excercise.distanceDone / excercise.timeDone) < (currentDistance / counter)){
                  print('good');
                  excercise.timeDone = counter;
                  excercise.distanceDone = currentDistance;
                  var issuccess = await connect_db.addExcerciseResult(scaffoldKey, this.excercise, user_id);
                  if (issuccess){
                    setState(() {
                      changeReady();
                    });
                  }
                }
              }
            }
          }
        },
      );
    }
  //

  void changeReady(){
    if (this.excercise.isReady == true){
      this.excercise.isReady = false;
    }
    else{
      this.excercise.isReady = true;
    }
    excerciseControl.add(this.excercise.isReady);
  }

  getDistance(min, max){
    var rn = new Random();
    return rn.nextDouble() * (max - min) + min;
  }

  
  String setReadyString(){
    if (isTimerStart){
      return 'Остановить';
    }
    else{
      if (this.excercise.isReady == true){
        return 'Выполнено';
      }
      else{
        if (excercise.isRunning == 1){
          if (excercise.tooslow){
            return 'Перебежать';
          }
          else{
            return 'Начать упражнение';
          }
          
        }
        else{
          return 'Выполнить';
        }

      }
    }

  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
      print(_status);
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }


  @override
  void initState() {
    startTimer();
    connect_db = ConnectDataBase();

    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {

    getted = ModalRoute.of(context).settings.arguments;

    excercise = getted[0];
    excerciseControl = getted[1];
    user_id = getted[2];

    if (excercise.isRunning == 1){
      endcounter = excercise.time * 60;
    }

    tooslowText = '';

    if (excercise.tooslow){
      tooslowText = 'Слишком медленно';
    }

    if (excercise.isReady && isTimerStart == false){
      currentDistance = excercise.distanceDone;
      counter = excercise.timeDone;
    }

    AppBar appBar = AppBar(
        backgroundColor: Colors.orange[400],
        title: Text(excercise.name),
        centerTitle: true,
        elevation: 0,
        );

    return (excercise.isRunning == 0) ? Scaffold(
      key: scaffoldKey,
      backgroundColor: backcolor,
      appBar: appBar,
      body: LayoutBuilder(builder: (context, constraints){
          return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
              child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
              child: IntrinsicHeight(
                              child: DefaultTextStyle(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Text('Необходимо выполнить',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                      SizedBox(height: 20.0,),
                      Text(
                        'Подходов: 1',
                        textAlign: TextAlign.left,),
                      SizedBox(height: 3.0,),
                      Text('Повторений: ${excercise.volume}'),
                      SizedBox(height: 10.0,),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        indent: 10,
                        endIndent: 10,
                      ),
                      SizedBox(height: 20.0,),
                      Text('Методика выполнения',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 20.0,),
                      Text('${excercise.desc}'),
                      SizedBox(height: 20.0,),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                              child: FittedBox(
                                child: FloatingActionButton.extended(
                                  backgroundColor: this.excercise.isReady ? Colors.green[300] :Colors.pink[500],
                                  onPressed: this.excercise.isReady ? null : () async {
                                    var issuccess = await connect_db.addExcerciseResult(scaffoldKey, this.excercise, user_id);
                                    if (issuccess){
                                      setState(() {
                                        changeReady();
                                      });
                                    }
                                  },
                                  icon: Icon(IconData(0xe6f5, fontFamily: 'MaterialIcons')),
                                  label: Text(setReadyString()),
                                  heroTag: 1,
                                ),
                              ),
                      ),
                          ),
                    ],
                  ),
                  style: TextStyle(fontSize: 17.0, color: Colors.black),
                ),
              ),
            ),
          ),
        );
        }
      ),
    ) : Scaffold(
      key: scaffoldKey,
      backgroundColor: backcolor,
      appBar: appBar,
      body: LayoutBuilder(builder: (context, constraints){
          return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
              child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
              child: IntrinsicHeight(
                              child: DefaultTextStyle(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Text('Необходимо пробежать',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                      SizedBox(height: 20.0,),
                      Text(
                        'Расстояние: ${excercise.volume} км',
                        textAlign: TextAlign.left,),
                      SizedBox(height: 3.0,),
                      Text('Время: ${excercise.time} минут'),
                      SizedBox(height: 10.0,),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        indent: 10,
                        endIndent: 10,
                      ),
                      SizedBox(height: 20.0,),
                      Text('Методика выполнения',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 20.0,),
                      Text('${excercise.desc}'),
                      SizedBox(height: 10.0,),
                       Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        indent: 10,
                        endIndent: 10,
                      ),
                      SizedBox(height: 20.0,),
                      Center(
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40.0),
                          width: 100.0,
                          height: 100.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              excercise.tooslow ? Colors.red : Colors.green,
                            ),
                            value: currentDistance / (excercise.volume * 1000),
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                          )
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '${currentDistance.round()/1000}/${excercise.volume} км',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            '${counter ~/ 60}:${counter % 60}',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                            )
                        ],),
                        SizedBox(height: 40.0,),
                        Center(
                          child: Text(
                              tooslowText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: excercise.tooslow ? Colors.red : Colors.green
                                ),
                              ),
                        ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                            child: FittedBox(
                              child: FloatingActionButton.extended(
                                backgroundColor: this.excercise.isReady ? Colors.green[300] : Colors.pink[500],
                                onPressed: this.excercise.isReady ? null : () {
                                  excercise.tooslow = false;
                                  changeTimerStatus();
                                  setState(() {
                                    counter = 0;
                                    currentDistance = 0;
                                  });
                                },
                                icon: Icon(IconData(0xe6f5, fontFamily: 'MaterialIcons')),
                                label: Text(setReadyString()),
                                heroTag: 1,
                              ),
                            ),
                          ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 17.0, color: Colors.black),
                ),
              ),
            ),
          ),
        );
        }
      ),
    );
  }
}