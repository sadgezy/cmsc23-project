import 'package:elbi_donation_system/providers/auth_provider.dart';
import 'package:elbi_donation_system/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrgRejectedScreen extends StatelessWidget {
  const OrgRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outlined, color: Colors.red, size: 100),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                "Your application was rejected.",
                style: TextStyle(
                    color: Colors.black, fontSize: 24, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Once you confirm, your account will be deleted and you will be redirected to the sign-in page. You can sign up again if you wish to reapply.",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  try {
                    await Provider.of<UserProvider>(context, listen: false)
                        .deleteUserAndAccount();
                    await context.read<UserAuthProvider>().signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  } catch (e) {
                    print('Failed to delete user and account: $e');
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
