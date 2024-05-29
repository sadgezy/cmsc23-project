import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class MyDonationsProvider with ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserDonations(String userId) {
    return db.collection('donations').where('org_donor', isEqualTo: userId).snapshots();
  }

  Future<String> getOrgNameFromId(
    String orgId,
  ) async {
    DocumentSnapshot orgDoc = await db.collection('organizations').doc(orgId).get();
    return orgDoc.get('orgName');
  }

  Future<String> updateStatus(String donationId, String status) async {
    try {
      await db.collection('donations').doc(donationId).update({'status': status});
      return 'Status updated';
    } catch (e) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> captureAndSaveQRCode(ScreenshotController screenshotController) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/qr_code.png');

      final Uint8List? pngBytes = await screenshotController.capture();
      if (pngBytes != null) {
        await file.writeAsBytes(pngBytes);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentSnapshot> getDonationDetailsById(String donationId) async {
    try {
      DocumentSnapshot donationDoc =
          await db.collection('donations').doc(donationId).get();
      return donationDoc;
    } catch (e) {
      throw Exception('Failed to get donation details');
    }
  }
}
