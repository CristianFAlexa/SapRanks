import 'package:cloud_firestore/cloud_firestore.dart';

class QueueModel {
  Timestamp _createdAt;
  List<String> _players;
  int _minPlayers;
  int _maxPlayers;

  QueueModel(
      this._createdAt, this._players, this._minPlayers, this._maxPlayers);

  int get maxPlayers => _maxPlayers;

  int get minPlayers => _minPlayers;

  List<String> get players => _players;

  Timestamp get createdAt => _createdAt;

  QueueModel.map(dynamic obj) {
    this._createdAt = obj['created_at'];
    this._players = obj['players'];
    this._maxPlayers = obj['max_players'];
    this._minPlayers = obj['min_players'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['created_at'] = this._createdAt;
    map['players'] = this._players;
    map['max_players'] = this._maxPlayers;
    map['min_players'] = this._minPlayers;
    return map;
  }

  QueueModel.fromMap(Map<String, dynamic> map) {
    this._createdAt = map['created_at'];
    this._players = map['players'];
    this._minPlayers = map['min_players'];
    this._maxPlayers = map['max_players'];
  }
}
