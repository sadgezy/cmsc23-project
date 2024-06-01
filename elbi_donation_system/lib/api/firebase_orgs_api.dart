import 'dart:io';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:path/path.dart' as path;
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

  Future<DocumentSnapshot> getOrganizationById(String orgId) async {
    DocumentSnapshot orgSnapshot = await db.collection('organizations').doc(orgId).get();
    if (orgSnapshot.exists) {
      return orgSnapshot;
    } else {
      throw Exception('Organization not found');
    }
  }

  Future<DocumentSnapshot> getDonor(String donorId) async {
    DocumentSnapshot donorSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(donorId).get();
    if (donorSnapshot.exists) {
      return donorSnapshot;
    } else {
      throw Exception('Donor not found');
    }
  }

  Future<String> getOrgName(String orgId) async {
    DocumentSnapshot orgSnapshot =
        await FirebaseFirestore.instance.collection('organizations').doc(orgId).get();
    if (orgSnapshot.exists) {
      var data = orgSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        return data['orgName'];
      } else {
        throw Exception('Organization data is null');
      }
    } else {
      throw Exception('Organization not found');
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      var path = Uri.parse(imagePath).path;
      var imgURL = await storage.ref(path).getDownloadURL();
      return imgURL;
    } catch (e) {
      throw Exception('Invalid image data');
    }
  }

  Future<String> uploadPhoto(File photo) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('donation_photos/${path.basename(photo.path)}');

      UploadTask uploadTask = storageReference.putFile(photo);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('Photo uploaded');
      return downloadUrl;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto(File photo) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${path.basename(photo.path)}');

      UploadTask uploadTask = storageReference.putFile(photo);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('Photo uploaded');
      return downloadUrl;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<String>> uploadProofPhotos(String orgName, List<File> images) async {
    List<String> downloadUrls = [];

    for (var image in images) {
      String fileName = path.basename(image.path);
      Reference ref = await createProofFolder(orgName);
      Reference fileRef = ref.child(fileName);

      UploadTask uploadTask = fileRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  Future<String> uploadOrgLogo(File photo) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('org_logos/${path.basename(photo.path)}');

      UploadTask uploadTask = storageReference.putFile(photo);
      await uploadTask.whenComplete(() => null);

      // Get the gs path
      String gsPath = 'gs://${storageReference.bucket}/${storageReference.fullPath}';

      print('Photo uploaded');
      return gsPath;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> addOrganization(Organization organization) async {
    try {
      DocumentReference docRef =
          await db.collection('organizations').add(organization.toMap());
      print('Organization added');
      return docRef.id;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteOrganization(String orgId, String userId, String orgName) async {
    try {
      // Delete the organization
      await db.collection('organizations').doc(orgId).delete();
      print('Organization deleted');

      // Update the user's org_id
      await db.collection('users').doc(userId).update({
        'org_id': '',
      });
      print('User org_id updated');
      // Delete the proof images folder
      var proofFolder =
          FirebaseStorage.instance.ref().child('org_applications/$orgName proof');
      var files = await proofFolder.listAll();
      for (var file in files.items) {
        await file.delete();
      }
      print('Proof images folder deleted');
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateVerification(String docId, String userId) async {
    try {
      await db.collection('organizations').doc(docId).update({
        'is_verified': true,
      });
      print('Organization verification updated');
      // Update the user's org_id and user_type
      await db.collection('users').doc(userId).update({
        'user_type': 'org',
      });
      print('User org_id and user_type updated');
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Reference> createProofFolder(String orgName) async {
    try {
      return FirebaseStorage.instance
          .ref()
          .child('org_applications')
          .child('$orgName proof');
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<String>> getProofPhotos(String applicationPath) async {
    try {
      ListResult result = await FirebaseStorage.instance.ref(applicationPath).listAll();

      List<String> imageUrls = [];
      for (var ref in result.items) {
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addDonation(Donation donation) async {
    try {
      DocumentReference docRef = await db.collection('donations').add({
        'date_time': donation.dateTime,
        'delivery_method': donation.deliveryMethod,
        'image': donation.image,
        'item_category': {
          'Clothes': donation.itemCategory.clothes,
          'Food': donation.itemCategory.food,
          'Necessities': donation.itemCategory.necessities,
          'Others': donation.itemCategory.others,
        },
        'org_donor': donation.orgDonor,
        'org_id': donation.orgID,
        'weight': donation.weight,
        'selected_address': donation.selectedAddress,
        'contact_number': donation.contactNumber,
        'create_time': donation.createTime,
        'status': donation.status,
        'drive': donation.drive,
      });
      await docRef.update({'id': docRef.id});
      print('Donation added');
    } catch (e) {
      print(e);
    }
  }
}
