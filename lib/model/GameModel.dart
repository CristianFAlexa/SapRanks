class GameModel {
  String _name;
  int _players;
  String _picture;
  String _uid;
  int _maxPlayers;
  int _minPlayers;
  int _xp;

  GameModel(this._name, this._players, this._picture, this._uid, this._maxPlayers, this._minPlayers, this._xp);

  int get xp => _xp;

  String get picture => _picture;

  int get players => _players;

  String get name => _name;

  String get uid => _uid;

  int get minPlayers => _minPlayers;

  int get maxPlayers => _maxPlayers;

  GameModel.map(dynamic obj) {
    this._name = obj['name'];
    this._players = obj['players'];
    this._picture = obj['picture'];
    this._uid = obj['uid'];
    this._minPlayers = obj['min_players'];
    this._maxPlayers = obj['max_players'];
    this._xp = obj['xp'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['name'] = this._name;
    map['players'] = this._players;
    map['picture'] = this._picture;
    map['uid'] = this._uid;
    map['min_players'] = this._minPlayers;
    map['max_players'] = this._maxPlayers;
    map['xp'] = this._xp;
    return map;
  }

  GameModel.fromMap(Map<String, dynamic> map) {
    this._name = map['name'];
    this._players = map['players'];
    this._picture = map['picture'];
    this._uid = map['uid'];
    this._minPlayers = map['min_players'];
    this._maxPlayers = map['max_players'];
    this._xp = map['xp'];
  }
}
