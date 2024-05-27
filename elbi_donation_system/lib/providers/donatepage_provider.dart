import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/api/firebase_auth_api.dart';
import 'package:elbi_donation_system/api/firebase_orgs_api.dart';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DonatepageProvider with ChangeNotifier {
  File? _image;
  final FirebaseOrgsAPI _firebaseOrgApi = FirebaseOrgsAPI();
  final FirebaseAuthAPI _firebaseAuthApi = FirebaseAuthAPI();
  File? get image => _image;

  User? getUser() {
    return _firebaseAuthApi.getUser();
  }

  Future<DocumentSnapshot> getDonorData() async {
    try {
      DocumentSnapshot<Object?> donorData =
          await _firebaseOrgApi.getDonor(getUser()!.uid);
      print(donorData.id);
      return donorData;
    } catch (e) {
      print(e);
      throw Exception('Failed to get donor data');
    }
  }

  Future<String> getOrgName(String orgId) async {
    try {
      String orgName = await _firebaseOrgApi.getOrgName(orgId);
      return orgName;
    } catch (e) {
      print(e);
      throw Exception('Failed to get organization name');
    }
  }

  Future pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    } else {}
  }

  Future<String> uploadImage() async {
    if (_image != null) {
      String imageUrl = await _firebaseOrgApi.uploadPhoto(_image!);
      return imageUrl;
    } else {
      print('No image selected');
      throw Exception('No image selected');
    }
  }

  Future donate(Donation donation) async {
    try {
      await _firebaseOrgApi.addDonation(donation);
      print('Donation completed');
    } catch (e) {
      print(e);
    }
  }
}
