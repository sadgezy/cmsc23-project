import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDonorsAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> deleteDonor(String? id) async {
    try {
      await db.collection("users").doc(id).delete();
      return "Successfully deleted!";
    } on FirebaseException catch (e) {
      return "Error in ${e.code}: ${e.message}";
    }
  }

  Future<String> editDonor(String id, String username) async {
    try {
      // await db.collection("donor_view").doc(id).update({"Username": username});
      // Dito yung pagedit ng donor, di ko lang sure pano implement

      return "Successfully edited!";
    } on FirebaseException catch (e) {
      return "Error in ${e.code}: ${e.message}";
    }
  }
}
