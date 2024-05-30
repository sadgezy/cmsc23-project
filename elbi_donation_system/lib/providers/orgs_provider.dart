import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/api/firebase_auth_api.dart';
import 'package:elbi_donation_system/api/firebase_orgs_api.dart';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class OrgsProvider extends ChangeNotifier {
  FirebaseOrgsAPI firebaseService = FirebaseOrgsAPI();
  FirebaseAuthAPI auth = FirebaseAuthAPI();
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

  Future<String> addOrganization(Organization organization) async {
    try {
      String orgId = await firebaseService.addOrganization(organization);
      fetchOrgs();
      return orgId;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateOrgId(String userId, String orgId) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {
      await userDocRef.update({
        'org_id': orgId,
      });
    } else {
      print('User document not found');
    }
  }

  Stream<Organization> getOrgDetailsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(auth.auth.currentUser!.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      String orgId = snapshot.data()?['org_id'];
      DocumentSnapshot orgSnapshot =
          await FirebaseFirestore.instance.collection('organizations').doc(orgId).get();
      return Organization.fromDocumentSnapshot(orgSnapshot);
    });
  }

  Stream<List<Donation>> getOrgDonationsStream(String orgId) {
    return FirebaseFirestore.instance
        .collection('donations')
        .where('org_id', isEqualTo: orgId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Donation.fromDocumentSnapshot(doc)).toList());
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

  Future<void> updateOrgDetails(String orgId, Map<String, dynamic> newDetails) async {
    await db.collection('organizations').doc(orgId).update(newDetails);
  }

  Future<DocumentSnapshot> getOrgDetailsById(String orgId) async {
    return await db.collection('organizations').doc(orgId).get();
  }

  Future<String> uploadLogo(File logo, String orgName) async {
    final logoRef = FirebaseOrgsAPI.storage.ref().child('org_logos/${orgName}_logo');
    final logoUploadTask = logoRef.putFile(logo);
    final logoSnapshot = await logoUploadTask;
    final logoUrl = await logoSnapshot.ref.getDownloadURL();

    return logoUrl;
  }

  Future<void> submitForm(GlobalKey<FormState> formKey, File? logo,
      List<File>? proofImages, String orgName, String orgMotto, String userId) async {
    if (formKey.currentState!.validate()) {
      if (logo != null && proofImages != null && proofImages.isNotEmpty) {
        // Upload logo
        final logoUrl = await uploadLogo(logo, orgName);

        // Upload proof images
        await firebaseService.uploadProofPhotos(orgName, proofImages);

        final organization = Organization(
          name: orgName,
          motto: orgMotto,
          logoUrl: logoUrl,
          isVerified: false,
          proofImages: 'org_applications/$orgName proof',
        );
        String orgId = await addOrganization(organization);
        await updateOrgId(userId, orgId);
      } else {
        throw Exception('Please upload a logo and at least one proof photo');
      }
    }
  }

  Future<String> getUserName(String donorId) async {
    try {
      var userDoc =
          await FirebaseFirestore.instance.collection('users').doc(donorId).get();
      return userDoc.data()?['user_name'] ?? '';
    } catch (error) {
      print('Error fetching user name: $error');
      rethrow;
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
