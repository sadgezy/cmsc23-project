import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/api/firebase_orgs_api.dart';
import 'package:flutter/foundation.dart';

class OrgsProvider extends ChangeNotifier {
  FirebaseOrgsAPI firebaseService = FirebaseOrgsAPI();
  late Stream<QuerySnapshot> _orgsStream;

  OrgsProvider() {
    fetchOrgs();
  }

  Stream<QuerySnapshot> get orgs => _orgsStream;

  void fetchOrgs() async {
    _orgsStream = firebaseService.getOrganizations();
    // notifyListeners();
  }
}
