
class UserModel{

  final String uid;
  final String email;
  final String rank;
  final String role;

  UserModel(this.uid,this.email,this.rank,this.role);

  Map<String, dynamic> toJson() => {
    'name' : this.email,
    'uid'  : this.uid,
    'rank' : this.rank,
    'role' : this.role,
  };
}