import 'package:cloud_firestore/cloud_firestore.dart';

class QueueModel {
  Timestamp _createdAt;
  List<String> _players;
  int _minPlayers;
  int _maxPlayers;
  Timestamp _eventDate;
  String _location;
  String _description;
  String _creator;

  List<String> _blueTeam;
  List<String> _redTeam;

  QueueModel(this._createdAt, this._players, this._minPlayers, this._maxPlayers,
      this._eventDate, this._location, this._description, this._creator,
      this._blueTeam, this._redTeam
      );

  List<String> get redTeam => _redTeam;

  List<String> get blueTeam => _blueTeam;

  String get creator => _creator;

  String get location => _location;

  String get description => _description;

  Timestamp get eventDate => _eventDate;

  int get maxPlayers => _maxPlayers;

  int get minPlayers => _minPlayers;

  List<String> get players => _players;

  Timestamp get createdAt => _createdAt;

  QueueModel.map(dynamic obj) {
    this._createdAt = obj['created_at'];
    this._players = obj['players'];
    this._maxPlayers = obj['max_players'];
    this._minPlayers = obj['min_players'];
    this._description = obj['description'];
    this._eventDate = obj['event_date'];
    this._location = obj['location'];
    this._creator = obj['creator'];
    this._redTeam = obj['red_team'];
    this._blueTeam = obj['blue_team'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['created_at'] = this._createdAt;
    map['players'] = this._players;
    map['max_players'] = this._maxPlayers;
    map['min_players'] = this._minPlayers;
    map['description'] = this._description;
    map['event_date'] = this._eventDate;
    map['location'] = this._location;
    map['creator'] = this._creator;
    map['red_team'] = this._redTeam;
    map['blue_team'] = this._blueTeam;
    return map;
  }

  QueueModel.fromMap(Map<String, dynamic> map) {
    this._createdAt = map['created_at'];
    var playerList = map['players'];
    this._players = new List<String>.from(playerList);
    this._minPlayers = map['min_players'];
    this._maxPlayers = map['max_players'];
    this._description = map['description'];
    this._location = map['location'];
    this._eventDate = map['event_date'];
    this._creator = map['creator'];

    var redTeamList = map['red_team'];
    this._redTeam = new List<String>.from(redTeamList);

    var blueTeamList = map['blue_team'];
    this._blueTeam = new List<String>.from(blueTeamList);
  }
}
