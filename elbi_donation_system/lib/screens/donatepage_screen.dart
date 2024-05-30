import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:elbi_donation_system/providers/donatepage_provider.dart';
import 'package:elbi_donation_system/screens/donation_success_screen.dart';
import 'package:elbi_donation_system/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DonatePage extends StatefulWidget {
  final String orgId;

  const DonatePage({super.key, required this.orgId});

  @override
  DonatePageState createState() => DonatePageState();
}

class DonatePageState extends State<DonatePage> {
  final List<String> categories = ['Food', 'Clothes', 'Necessities', 'Others'];
  final Map<String, bool> selectedCategories = {};
  String deliveryMethod = 'Pickup';
  String weight = '';
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  DateTime? pickupDropoffDateTime;
  String? selectedAddress;
  String? contactNumber;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    for (var category in categories) {
      selectedCategories[category] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DonatepageProvider>(context, listen: true);

    return isLoading
        ? PopScope(
            onPopInvoked: (didPop) => didPop ? provider.clear() : null,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Donate'),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Item Category',
                            style: AppTextStyles.cardHeader,
                          ),
                        ),
                      ),
                      Card(
                        child: Column(
                          children: categories
                              .map((category) => CheckboxListTile(
                                    title: Text(category),
                                    value: selectedCategories[category],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        selectedCategories[category] = value!;
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Donation Details',
                            style: AppTextStyles.cardHeader,
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text('Delivery Method'),
                          trailing: DropdownButton<String>(
                            value: deliveryMethod,
                            items: <String>['Pickup', 'Drop-off']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                deliveryMethod = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      Card(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight of items to donate in kg',
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              weight = value;
                            });
                          },
                        ),
                      ),
                      Card(
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext bc) {
                                return SafeArea(
                                  child: Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Photo from Library'),
                                        onTap: () {
                                          provider.pickImage(ImageSource.gallery);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_camera),
                                        title: const Text('Take a Photo'),
                                        onTap: () {
                                          provider.pickImage(ImageSource.camera);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Upload Image'),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 32, 8),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  height: MediaQuery.of(context).size.width * 0.15,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: provider.image != null
                                      ? Image.file(
                                          provider.image!,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.photo,
                                          color: Colors.grey[600],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text('Pickup/Drop-off Date'),
                          subtitle: pickupDropoffDateTime != null
                              ? Text(
                                  'Selected date: ${DateFormat('MM/dd/yyyy').format(pickupDropoffDateTime!)}')
                              : null,
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2022),
                                lastDate: DateTime(2025),
                              );
                              if (picked != null) {
                                setState(() {
                                  pickupDropoffDateTime = picked;
                                });
                              }
                            },
                            child: const Icon(Icons.calendar_today_rounded),
                          ),
                        ),
                      ),
                      if (deliveryMethod == 'Pickup') ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pickup Details',
                              style: AppTextStyles.cardHeader,
                            ),
                          ),
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: provider.getDonorData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(child: Text('Error'));
                            } else {
                              DocumentSnapshot donorSnapshot = snapshot.data!;
                              Map<String, String> addresses = Map<String, String>.from(
                                  donorSnapshot.get('addresses'));
                              contactNumber = donorSnapshot.get('contact_no');
                              selectedAddress ??= addresses.entries.first.value;
                              return Column(
                                children: [
                                  ...addresses.entries.map((entry) {
                                    return Card(
                                      child: RadioListTile<String>(
                                        title: Text(entry.value),
                                        value: entry.value,
                                        groupValue: selectedAddress,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedAddress = value;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                  Card(
                                    child: ListTile(
                                      title: const Text('Contact Number for Pickup'),
                                      trailing: Text(contactNumber!),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var imgUrl = await provider.uploadImage();
                    final donation = Donation(
                      dateTime: pickupDropoffDateTime!,
                      deliveryMethod: deliveryMethod,
                      image: imgUrl,
                      itemCategory: ItemCategory(
                        clothes: selectedCategories['Clothes']!,
                        food: selectedCategories['Food']!,
                        necessities: selectedCategories['Necessities']!,
                        others: selectedCategories['Others']!,
                      ),
                      orgDonor: provider.getUser()!.uid,
                      weight: double.parse(weight),
                      orgID: widget.orgId,
                      selectedAddress: selectedAddress,
                      contactNumber: contactNumber,
                      createTime: DateTime.now(),
                      status: 'Pending',
                      drive: '',
                    );
                    await provider.donate(donation);

                    String orgName = await provider.getOrgName(widget.orgId);
                    setState(() {
                      isLoading = true;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationSuccessScreen(
                          orgName: orgName,
                          donorID: provider.getUser()!.uid,
                        ),
                      ),
                    );
                  },
                  child: const Text('Donate'),
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
