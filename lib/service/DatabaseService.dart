import 'package:bored/model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference collectionReference =
    Firestore.instance.collection('users');

class DatabaseService {

  Future<FirebaseUser> getFirebaseUser() async{
    return await FirebaseAuth.instance.currentUser();
  }

  Future<UserModel> createUserModel(
      String uid, String role, String rank, String email) async {
    final TransactionHandler transactionHandler = (Transaction tx) async {
      final DocumentSnapshot snapshot =
          await tx.get(collectionReference.document());
      final UserModel userModel = UserModel(uid, email, rank, role);
      final Map<String, dynamic> data = userModel.toMap();
      await tx.set(snapshot.reference, data);
      return data;
    };
    return Firestore.instance
        .runTransaction(transactionHandler)
        .then((mapData) {
      return UserModel.fromMap(mapData);
    }).catchError((onError) {
      print(onError);
      return null;
    });
  }

  Stream<QuerySnapshot> getUserModelList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = collectionReference.snapshots();
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }
}
