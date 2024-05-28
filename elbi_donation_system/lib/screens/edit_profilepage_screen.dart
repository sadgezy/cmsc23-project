import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _email, _profilePictureUrl, _contactNo, _userName;
  late Map<String, dynamic> _addresses;
  late bool _isOrg;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Object?>>(
        future: provider.getUserDetailsById(widget.userId),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          _name = data['name'];
          _email = data['email'];
          _profilePictureUrl = data['profile_picture'];
          _addresses = data['addresses'];
          _contactNo = data['contact_no'];
          _userName = data['user_name'];
          _isOrg = data['is_org'];

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                ListTile(
                  subtitle: TextFormField(
                    initialValue: _userName,
                    onSaved: (value) => _userName = value!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      prefixIcon: Icon(Icons.person,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                ListTile(
                  subtitle: TextFormField(
                    keyboardType: TextInputType.phone,
                    initialValue: _contactNo,
                    onSaved: (value) => _contactNo = value!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.grey, width: 5.0),
                      ),
                      labelText: 'Contact Number',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      prefixIcon:
                          Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                ListTile(
                  subtitle: TextFormField(
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.words,
                    initialValue: _addresses['home'],
                    onSaved: (value) => _addresses['home'] = value!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelText: 'Home Address',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      prefixIcon:
                          Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                ListTile(
                  subtitle: TextFormField(
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.words,
                    initialValue: _addresses['work'],
                    onSaved: (value) => _addresses['work'] = value!,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      labelText: 'Work Address',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      prefixIcon:
                          Icon(Icons.work, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Map<String, dynamic> newDetails = {
                          'name': _name,
                          'email': _email,
                          'profile_picture': _profilePictureUrl,
                          'contact_no': _contactNo,
                          'user_name': _userName,
                          'is_org': _isOrg,
                          'addresses': _addresses,
                        };
                        await provider.updateUserDetails(widget.userId, newDetails);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
