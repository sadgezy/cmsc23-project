import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelect with ChangeNotifier {
  File? _image;

  File? get image => _image;

  Future pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    } else {
      print('No image selected.');
    }
  }
}
