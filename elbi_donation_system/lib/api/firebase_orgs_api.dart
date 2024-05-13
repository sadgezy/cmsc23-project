import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseOrgsAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOrganizations() {
    return db.collection("organizations").snapshots();
  }
}
