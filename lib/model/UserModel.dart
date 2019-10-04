import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String _uid;
  String _email;
  String _rank;
  String _role;

  UserModel(this._uid, this._email, this._rank, this._role);

  Map<String, dynamic> toJson() => {
        'name': this._email,
        'uid': this._uid,
        'rank': this._rank,
        'role': this._role,
      };

  UserModel.map(dynamic obj) {
    this._role = obj['role'];
    this._rank = obj['rank'];
    this._email = obj['email'];
    this._uid = obj['uid'];
  }

  String get role => _role;

  String get rank => _rank;

  String get email => _email;

  String get uid => _uid;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['role'] = this._role;
    map['rank'] = this._rank;
    map['email'] = this._email;
    map['uid'] = this._uid;
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    this._role = map['role'];
    this._rank = map['rank'];
    this._email = map['name'];  // todo : add attribute name and email as separate, modify in login too
    this._uid = map['uid'];
  }
}
