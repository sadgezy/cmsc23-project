import 'package:cloud_firestore/cloud_firestore.dart';

class Organization {
  final String name;
  final String motto;
  final String logoUrl;
  final bool isVerified;
  final String proofImages;
  List<String>? drives; // Changed from Map to List

  Organization({
    required this.name,
    required this.motto,
    required this.logoUrl,
    required this.isVerified,
    required this.proofImages,
    required this.drives,
  });

  Map<String, dynamic> toMap() {
    return {
      'orgName': name,
      'orgMotto': motto,
      'orgLogo': logoUrl,
      'is_verified': isVerified,
      'proofimages': proofImages,
      'donation_drives': drives,
    };
  }

  static Organization fromDocumentSnapshot(DocumentSnapshot doc) {
    return Organization(
      name: doc['orgName'],
      motto: doc['orgMotto'],
      logoUrl: doc['orgLogo'],
      isVerified: doc['is_verified'],
      proofImages: doc['proofimages'],
      drives: List<String>.from(doc['donation_drives'] ?? []),
    );
  }
}
