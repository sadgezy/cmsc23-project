import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './signuppage_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? errorMsg;
  bool showSignInErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading,
                emailField,
                passwordField,
                showSignInErrorMessage ? signInErrorMessage : Container(),
                submitButton,
                signUpButton
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
          "Sign In",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      );

  Widget get emailField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
              hintText: "Enter your email"),
          onSaved: (value) => setState(() => email = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your email";
            }
            return null;
          },
        ),
      );

  Widget get passwordField => Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), label: Text("Password"), hintText: "******"),
          obscureText: true,
          onSaved: (value) => setState(() => password = value),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return "Password must be atleast 6 characters long.";
            }
            return null;
          },
        ),
      );

  // Widget get signInErrorMessage => const Padding(
  //       padding: EdgeInsets.only(bottom: 30),
  //       child: Text(
  //         "Invalid email or password",
  //         style: TextStyle(color: Colors.red),
  //       ),
  //     );

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
            "Password must be atleast 6 characters",
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

      case 'user-disabled':
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "The user is disabled",
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
        return const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            "An error occurred",
            style: TextStyle(color: Colors.red),
          ),
        );
    }
  }

  Widget get submitButton => ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            String? test1 = await context
                .read<UserAuthProvider>()
                .authService
                .signIn(email!, password!);
            setState(
              () {
                if (test1 != null && test1.isNotEmpty) {
                  showSignInErrorMessage = true;
                  errorMsg = test1;
                } else {
                  showSignInErrorMessage = false;
                }
              },
            );
          }
        },
        child: const Text("Sign In"),
      );

  Widget get signUpButton => Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No account yet?"),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
              child: const Text("Sign Up"),
            )
          ],
        ),
      );
}
