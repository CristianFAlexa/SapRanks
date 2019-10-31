import 'package:bored/model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference collectionReference =
    Firestore.instance.collection('users');

final CollectionReference gamesCollectionReference =
    Firestore.instance.collection('games');

final CollectionReference gamesEnrolmentCollectionReference =
    Firestore.instance.collection('games_enrolment');

final CollectionReference usersEnrolmentCollectionReference =
    Firestore.instance.collection('users_enrolment');

final CollectionReference queueCollectionReference =
    Firestore.instance.collection('queue');

class DatabaseService {
  Future<FirebaseUser> getFirebaseUser() async {
    return await FirebaseAuth.instance.currentUser();
  }

  Future<UserModel> createUserModel(String uid, String role, String rank,
      String email, String profilePicture, String name) async {
    final TransactionHandler transactionHandler = (Transaction tx) async {
      final DocumentSnapshot snapshot =
          await tx.get(collectionReference.document());
      final UserModel userModel =
          UserModel(uid, email, rank, role, profilePicture, name, 0, 0, 0);
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

  Stream<QuerySnapshot> getGamesList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = gamesCollectionReference.snapshots();
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }

  Stream<QuerySnapshot> getGamesEnrolmentList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots =
        gamesEnrolmentCollectionReference.snapshots();
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }

  Stream<QuerySnapshot> getUsersEnrolmentList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots =
        usersEnrolmentCollectionReference.snapshots();
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }
}
