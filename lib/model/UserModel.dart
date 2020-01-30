class UserModel {
  String _uid;
  String _email;
  String _rank;
  String _role;
  String _profilePicture;
  String _name;
  int _disputeWin;
  int _disputeLoss;
  int _xp;
  List<String> _history;

  UserModel(this._uid, this._email, this._rank, this._role, this._profilePicture, this._name, this._disputeWin, this._disputeLoss, this._xp, this._history);

  Map<String, dynamic> toJson() => {
        'email': this._email,
        'uid': this._uid,
        'rank': this._rank,
        'role': this._role,
        'profile_picture': this._profilePicture,
        'name': this._name,
        'dispute_win': this._disputeWin,
        'dispute_loss': this._disputeLoss,
        'xp': this._xp,
        'history': this._history
      };

  UserModel.map(dynamic obj) {
    this._role = obj['role'];
    this._rank = obj['rank'];
    this._email = obj['email'];
    this._uid = obj['uid'];
    this._profilePicture = obj['profile_picture'];
    this._name = obj['name'];
    this._disputeWin = obj['dispute_win'];
    this._disputeLoss = obj['dispute_loss'];
    this._xp = obj['xp'];
    var historyList = obj['history'];
    this._history = new List<String>.from(historyList);
  }

  String get name => _name;

  String get profilePicture => _profilePicture;

  String get role => _role;

  String get rank => _rank;

  String get email => _email;

  String get uid => _uid;

  int get disputeLoss => _disputeLoss;

  int get disputeWin => _disputeWin;

  int get xp => _xp;

  List<String> get history => _history;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['role'] = this._role;
    map['rank'] = this._rank;
    map['email'] = this._email;
    map['uid'] = this._uid;
    map['profile_picture'] = this._profilePicture;
    map['name'] = this._name;
    map['dispute_win'] = this._disputeWin;
    map['dispute_loss'] = this._disputeLoss;
    map['xp'] = this._xp;
    map['history'] = this._history;
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    this._role = map['role'];
    this._rank = map['rank'];
    this._email = map['email'];
    this._uid = map['uid'];
    this._name = map['name'];
    this._profilePicture = map['profile_picture'];
    this._disputeWin = map['dispute_win'];
    this._disputeLoss = map['dispute_loss'];
    this._xp = map['xp'];
  }
}
