import 'package:flutter/cupertino.dart';
import 'package:hello_flutter/user.dart';
import 'package:provider/provider.dart';

class AuthUser extends ChangeNotifier{
  String _name;
  String get name => _name;

  int _id;
  int get id => _id;

  int _group_id;
  int get group_id => _group_id;

  bool _isAuth = false;
  bool get isAuth => _isAuth;
  
  
  void sign_out(){
    this._name = null;
    this._id = null;
    this._isAuth = false;
    notifyListeners();
  }

  void sign_in(String name, int id, int group_id){
    this._name = name;
    this._id = id;
    this._group_id = group_id;
    this._isAuth = true;
    notifyListeners();
  }

  // }
  // User _pudge;
  // User get pudge => _pudge;

  // User()

}