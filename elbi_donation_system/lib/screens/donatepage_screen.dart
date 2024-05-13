import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key, required String orgId});

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final List<String> categories = ['Food', 'Clothes', 'Cash', 'Necessities', 'Others'];
  final Map<String, bool> selectedCategories = {};
  String deliveryMethod = 'Pickup';
  String weight = '';
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    for (var category in categories) {
      selectedCategories[category] = false;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ...categories.map((category) => CheckboxListTile(
                title: Text(category),
                value: selectedCategories[category],
                onChanged: (bool? value) {
                  setState(() {
                    selectedCategories[category] = value!;
                  });
                },
              )),
          ListTile(
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
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight of items to donate in kg',
            ),
            onChanged: (value) {
              setState(() {
                weight = value;
              });
            },
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ElevatedButton(
              onPressed: pickImage,
              child: const Text('Take a Photo'),
            ),
          ),
          if (imageFile != null)
            Image.file(
              File(imageFile!.path),
            ),
        ],
      ),
    );
  }
}
