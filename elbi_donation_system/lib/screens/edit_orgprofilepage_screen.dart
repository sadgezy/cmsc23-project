import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditOrgProfilePage extends StatefulWidget {
  final String orgId;

  const EditOrgProfilePage({super.key, required this.orgId});

  @override
  EditOrgProfilePageState createState() => EditOrgProfilePageState();
}

class EditOrgProfilePageState extends State<EditOrgProfilePage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  late String _orgLogo, _orgMotto, _orgName;
  File? _logo;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrgsProvider>(context, listen: false);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Organization Profile'),
          centerTitle: true,
        ),
        body: !_isLoading
            ? FutureBuilder<DocumentSnapshot<Object?>>(
                future: provider.getOrgDetailsById(widget.orgId),
                builder:
                    (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  _orgLogo = data['orgLogo'];
                  _orgMotto = data['orgMotto'];
                  _orgName = data['orgName'];

                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: <Widget>[
                        Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3.0,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _logo != null
                                      ? Image.file(
                                          _logo!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          _orgLogo,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 5.0,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                    onPressed: () async {
                                      final pickedFile = await ImagePicker()
                                          .pickImage(source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setState(() {
                                          _logo = File(pickedFile.path);
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('No image selected.'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          subtitle: TextFormField(
                            initialValue: _orgName,
                            onSaved: (value) => _orgName = value!,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: 'Organization Name',
                              labelStyle:
                                  TextStyle(color: Theme.of(context).colorScheme.primary),
                              prefixIcon: Icon(Icons.business,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        ListTile(
                          subtitle: TextFormField(
                            maxLines: 3,
                            initialValue: _orgMotto,
                            onSaved: (value) => _orgMotto = value!,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              labelText: 'Organization Motto',
                              labelStyle:
                                  TextStyle(color: Theme.of(context).colorScheme.primary),
                              prefixIcon: Icon(Icons.lightbulb_outline,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                if (_logo != null) {
                                  _orgLogo = await provider.uploadLogo(_logo!, _orgName);
                                }
                                Map<String, dynamic> newDetails = {
                                  'orgLogo': _orgLogo,
                                  'orgMotto': _orgMotto,
                                  'orgName': _orgName,
                                };
                                await provider.updateOrgDetails(widget.orgId, newDetails);
                                setState(() {
                                  _isLoading = false;
                                });
                                _scaffoldMessengerKey.currentState!.showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color.fromARGB(255, 173, 130, 181),
                                    content: Text('Changes saved successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
