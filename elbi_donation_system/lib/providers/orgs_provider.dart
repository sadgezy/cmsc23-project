import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/api/firebase_orgs_api.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrgsProvider extends ChangeNotifier {
  FirebaseOrgsAPI firebaseService = FirebaseOrgsAPI();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _orgsStream;

  OrgsProvider() {
    fetchOrgs();
  }

  Stream<QuerySnapshot> get orgs => _orgsStream;
  Stream<QuerySnapshot> get orgsStream => firebaseService.getOrganizations();

  void fetchOrgs() async {
    _orgsStream = firebaseService.getOrganizations();
    // notifyListeners();
  }

  Future<void> addOrganization(Organization organization) async {
    try {
      await firebaseService.addOrganization(organization);
      fetchOrgs();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Reference> createProofFolder(String orgName) async {
    try {
      return await firebaseService.createProofFolder(orgName);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> getOrganizationId(String orgName) async {
    return await firebaseService.getOrganizationId(orgName);
  }

  Future<Map<String, dynamic>> getUserStatus(String userId) async {
    return await db.collection('users').doc(userId).get().then((value) {
      return {
        'is_org': value['is_org'],
        'user_type': value['user_type'],
      };
    });
  }

  Future<void> submitForm(GlobalKey<FormState> formKey, File? logo,
      List<File>? proofImages, String orgName, String orgMotto) async {
    if (formKey.currentState!.validate()) {
      if (logo != null && proofImages != null && proofImages.isNotEmpty) {
        // Upload logo
        final logoRef = FirebaseOrgsAPI.storage.ref().child('org_logos/${orgName}_logo');
        final logoUploadTask = logoRef.putFile(logo);
        final logoSnapshot = await logoUploadTask;
        final logoUrl = await logoSnapshot.ref.getDownloadURL();

        // Upload proof images
        await firebaseService.uploadProofPhotos(orgName, proofImages);

        final organization = Organization(
          name: orgName,
          motto: orgMotto,
          logoUrl: logoUrl,
          isVerified: false,
          proofImages: 'org_applications/$orgName proof',
        );
        await addOrganization(organization);
      } else {
        throw Exception('Please upload a logo and at least one proof photo');
      }
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      var imgurl = await firebaseService.getImageUrl(imagePath);
      return imgurl;
    } catch (error) {
      print('Error fetching image URL: $error');
      rethrow;
    }
  }
}
