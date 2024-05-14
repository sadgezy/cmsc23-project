import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseOrgsAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getOrganizations() {
    return db.collection("organizations").snapshots();
  }

  Future<String> getOrganizationId(String orgName) async {
    final querySnapshot =
        await db.collection("organizations").where("orgName", isEqualTo: orgName).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      throw Exception('Organization not found');
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    print("API: $imagePath");
    return await storage.ref(imagePath).getDownloadURL();
  }
}
