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
  DonationStatus status;

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

class DonationStatus {
  final Status status;

  DonationStatus({required this.status});
}

enum Status {
  Pending,
  Confirmed,
  Completed,
  Cancelled,
  ScheduledForPickup,
}
