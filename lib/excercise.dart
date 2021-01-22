class Excercise{
  String name;
  double volume;
  double time;
  String desc;
  int id;
  int isRunning;

  bool isReady = false;

  double timeDone = 100000;
  double distanceDone = 1;

  bool tooslow = false;

  Excercise(this.name, 
            this.desc, 
            this.volume, 
            this.time,
            this.isRunning,
            this.id);
}