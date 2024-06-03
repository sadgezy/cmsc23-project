import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class SignUpOrgScreen extends StatefulWidget {
  final String? userId;

  const SignUpOrgScreen({super.key, this.userId});

  @override
  SignUpOrgScreenState createState() => SignUpOrgScreenState();
}

class SignUpOrgScreenState extends State<SignUpOrgScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgMottoController = TextEditingController();
  File? _logo;
  final ImagePicker _picker = ImagePicker();
  List<File>? _images;
  bool _isLoading = false;

  Future<void> loadProofs() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _images = pickedFiles.map<File>((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Organization Application"),
        ),
        body: _isLoading == false
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              textAlign: TextAlign.center,
                              "Complete this form for your organization account application."),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _logo = File(pickedFile.path);
                                });
                              }
                            },
                            child: Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                child: _logo != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.file(
                                          _logo!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey[600],
                                        size: 40,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Organization Logo',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orgNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          labelText: 'Organization Name',
                          labelStyle:
                              TextStyle(color: Theme.of(context).colorScheme.primary),
                          prefixIcon: Icon(Icons.people,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the organization name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        maxLines: 3,
                        controller: _orgMottoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelText: 'What\'s your organization motto?',
                          labelStyle:
                              TextStyle(color: Theme.of(context).colorScheme.primary),
                          prefixIcon: Icon(Icons.message_outlined,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a short motto for your organization';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Proof(s) of Legitimacy",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_images != null)
                        SingleChildScrollView(
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            children: List.generate(_images?.length ?? 0, (index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.file(
                                    File(_images![index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: loadProofs,
                        child: const Text("Pick images"),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: (_images != null && _images!.isNotEmpty)
                            ? () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await Provider.of<OrgsProvider>(context, listen: false)
                                    .submitForm(
                                  _formKey,
                                  _logo,
                                  _images,
                                  _orgNameController.text,
                                  _orgMottoController.text,
                                  widget.userId!,
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
