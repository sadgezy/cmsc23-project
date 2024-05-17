import 'package:elbi_donation_system/providers/donatepage_provider.dart';
import 'package:elbi_donation_system/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key, required String orgId});

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final List<String> categories = [
    'Food',
    'Clothes',
    'Cash',
    'Necessities',
    'Others'
  ];
  final Map<String, bool> selectedCategories = {};
  String deliveryMethod = 'Pickup';
  String weight = '';
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  DateTime? pickupDropoffDateTime;

  @override
  void initState() {
    super.initState();
    for (var category in categories) {
      selectedCategories[category] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageSelect>(context, listen: false);
    return Scaffold(
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
                          child: Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Photo from Library'),
                                  onTap: () {
                                    imageProvider
                                        .pickImage(ImageSource.gallery);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_camera),
                                  title: const Text('Take a Photo'),
                                  onTap: () {
                                    imageProvider.pickImage(ImageSource.camera);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
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
                          child: imageProvider.image != null
                              ? Image.file(
                                  imageProvider.image!,
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
                  title: const Text('Pickup/Drop-off Date and Time'),
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
                    child: const Text('Select Date'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // Do nothing for now
          },
          child: const Text('Donate'),
        ),
      ),
    );
  }
}
