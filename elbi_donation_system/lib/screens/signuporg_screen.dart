import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'pendingorg_screen.dart';

class SignUpOrgScreen extends StatefulWidget {
  @override
  _SignUpOrgScreenState createState() => _SignUpOrgScreenState();
}

class _SignUpOrgScreenState extends State<SignUpOrgScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orgNameController = TextEditingController();
  File? _image;
  String? _photoError;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _photoError = null; // clear the error message if an image is picked
      });
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_image == null) {
          _photoError = 'Please upload at least one photo';
        } else {
          _photoError = null;
        }
      });

      if (_image != null) {
        // pop the current screen and then navigate to the PendingOrgScreen
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PendingOrgScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Organization Application",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _orgNameController,
                decoration: InputDecoration(
                  labelText: 'Organization Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the organization name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Proof(s) of Legitimacy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
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
                                    _pickImage(ImageSource.gallery);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_camera),
                                  title: const Text('Take a Photo'),
                                  onTap: () {
                                    _pickImage(ImageSource.camera);
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
                          child: _image != null
                              ? Image.file(
                                  _image!,
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
              if (_photoError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _photoError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Submit Application"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
