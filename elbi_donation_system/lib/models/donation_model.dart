import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final DateTime dateTime;
  final String deliveryMethod;
  final String image;
  final ItemCategory itemCategory;
  final String orgDonor;
  String orgID;
  final double weight;
  final String? selectedAddress;
  final String? contactNumber;
  final DateTime createTime;
  final String status;

  Donation({
    required this.dateTime,
    required this.deliveryMethod,
    required this.image,
    required this.itemCategory,
    required this.orgDonor,
    required this.orgID,
    required this.weight,
    this.selectedAddress,
    this.contactNumber,
    required this.createTime,
    required this.status,
  });
  static Donation fromDocumentSnapshot(DocumentSnapshot doc) {
    return Donation(
      dateTime: (doc['date_time'] as Timestamp).toDate(),
      deliveryMethod: doc['delivery_method'],
      image: doc['image'],
      itemCategory: ItemCategory(
        clothes: doc['item_category']['clothes'] ?? false,
        food: doc['item_category']['food'] ?? false,
        necessities: doc['item_category']['necessities'] ?? false,
        others: doc['item_category']['others'] ?? false,
      ),
      orgDonor: doc['org_donor'],
      orgID: doc['org_id'],
      weight: doc['weight'],
      selectedAddress: doc['selected_address'],
      contactNumber: doc['contact_number'],
      createTime: (doc['create_time'] as Timestamp).toDate(),
      status: doc['status'],
    );
  }
}

class ItemCategory {
  final bool clothes;
  final bool food;
  final bool necessities;
  final bool others;

  ItemCategory({
    required this.clothes,
    required this.food,
    required this.necessities,
    required this.others,
  });
}
