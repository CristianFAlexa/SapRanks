import 'package:uuid/uuid.dart';

class GameModel {
  String _name;
  int _players;
  String _picture;
  String _uid;

  GameModel(this._name, this._players, this._picture, this._uid);

  String get picture => _picture;

  int get players => _players;

  String get name => _name;

  String get uid => _uid;

  GameModel.map(dynamic obj) {
    this._name = obj['name'];
    this._players = obj['players'];
    this._picture = obj['picture'];
    this._uid = obj['uid'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = this._name;
    map['players'] = this._players;
    map['picture'] = this._picture;
    map['uid'] = this._uid;
    return map;
  }

  GameModel.fromMap(Map<String, dynamic> map) {
    this._name = map['name'];
    this._players = map['players'];
    this._picture = map['picture'];
    this._uid = map['uid'];
  }
}
