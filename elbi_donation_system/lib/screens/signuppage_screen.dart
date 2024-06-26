import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signuporg_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? fname;
  String? lname;
  String? errorMsg;
  String? contactNo;
  String profilePic =
      'gs://elbi-donation-system-37957.appspot.com/profile_pictures/Windows_10_Default_Profile_Picture.svg.png';
  String userType = 'donor';
  Map<String, String> addresses = {
    'home': '',
    'work': '',
  };
  bool isOrg = false;
  bool showErrorMsg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading,
                emailField,
                passwordField,
                name,
                username,
                contactNum,
                addressField('Home Address', 'home'),
                addressField('Work Address', 'work'),
                orgSwitch,
                showErrorMsg ? signInErrorMessage : Container(),
                submitButton
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get heading => const Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Text(
          "Sign Up",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      );

  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
              hintText: "Enter a valid email"),
          onSaved: (value) => setState(() => email = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter an email";
            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return "Please enter valid email format (user@email.com)";
            }
            return null;
          },
        ),
      );

  Widget get name => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Name"),
              hintText: "Enter your Name"),
          onSaved: (value) => setState(() => fname = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a valid Name";
            }
            return null;
          },
        ),
      );

  Widget get username => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("User Name"),
              hintText: "Enter a username"),
          onSaved: (value) => setState(() => lname = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your username";
            }
            return null;
          },
        ),
      );

  Widget get passwordField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Password"),
              hintText: "At least 6 characters"),
          obscureText: true,
          onSaved: (value) => setState(() => password = value),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return "Password must be at least 6 characters long.";
            }
            return null;
          },
        ),
      );

  Widget get contactNum => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Contact Number"),
              hintText: "09XXXXXXXXX"),
          obscureText: true,
          onSaved: (value) => setState(() => contactNo = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Input a contact Number";
            }
            return null;
          },
        ),
      );

  Widget addressField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextFormField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        onSaved: (value) => setState(() => addresses[key] = value!),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty.";
          }
          return null;
        },
      ),
    );
  }

  Widget get orgSwitch => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Apply for Org?'),
            Switch(
              value: isOrg,
              onChanged: (value) {
                setState(() {
                  isOrg = value;
                });
              },
            ),
          ],
        ),
      );

  Widget get signInErrorMessage {
    switch (errorMsg) {
      case 'invalid-credential':
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "Invalid email or password",
            style: TextStyle(color: Colors.red),
          ),
        );

      case 'weak-password':
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "Password must be at least 6 characters",
            style: TextStyle(color: Colors.red),
          ),
        );

      case 'invalid-email':
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "Invalid email",
            style: TextStyle(color: Colors.red),
          ),
        );

      case 'email-already-in-use':
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "Email is already used",
            style: TextStyle(color: Colors.red),
          ),
        );

      case 'too-many-requests':
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "Too many requests. Please try again later.",
            style: TextStyle(color: Colors.red),
          ),
        );

      default:
        return Container();
    }
  }

  Widget get submitButton => ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            String? userID = await context.read<UserAuthProvider>().authService.signUp(
                fname!,
                lname!,
                email!,
                password!,
                contactNo!,
                profilePic,
                userType,
                addresses,
                isOrg);

            print(userID);
            print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");

            // check if the widget hasn't been disposed of after an asynchronous action
            if (!showErrorMsg) {
              if (isOrg) {
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
                print(isOrg);
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpOrgScreen(userId: userID),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            }
          }
        },
        child: const Text("Sign Up"),
      );
}
