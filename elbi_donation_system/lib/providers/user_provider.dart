import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/api/firebase_auth_api.dart';
import 'package:elbi_donation_system/api/firebase_donors_api.dart';
import 'package:elbi_donation_system/api/firebase_orgs_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuthAPI authService = FirebaseAuthAPI();
  final FirebaseDonorsAPI donorsAPI = FirebaseDonorsAPI();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseOrgsAPI storage = FirebaseOrgsAPI();
  File? _image;
  File? get image => _image;

  Future<DocumentSnapshot> getUserDetailsById(String id) async {
    return await db.collection('users').doc(id).get();
  }

  Future<DocumentSnapshot> getOrgDetails(String orgId) async {
    return await db.collection('organizations').doc(orgId).get();
  }

  Future<void> deleteUserAndAccount() async {
    String? userId = authService.auth.currentUser?.uid;
    var dbmsg = await donorsAPI.deleteDonor(userId);
    print(dbmsg);
    await authService.deleteAccount();
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      var imgurl = await storage.getImageUrl(imagePath);
      return imgurl;
    } catch (error) {
      print('Error fetching image URL: $error');
      rethrow;
    }
  }

  Future<void> updateUserDetails(String userId, Map<String, dynamic> newDetails) async {
    await db.collection('donor_view').doc(userId).update(newDetails);
  }

  Future pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    } else {}
  }
}
