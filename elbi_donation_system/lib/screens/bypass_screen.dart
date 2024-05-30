import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/providers/user_provider.dart';
import 'package:elbi_donation_system/screens/homepage_screen.dart';
import 'package:elbi_donation_system/screens/org_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './signinpage_screen.dart';
import './adminpage_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Stream<User?> userStream = context.watch<UserAuthProvider>().userStream;

    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error encountered! ${snapshot.error}"),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const SignInPage();
        }
        User? user = snapshot.data;
        Future<DocumentSnapshot?> userData =
            Provider.of<UserProvider>(context, listen: false)
                .getUserDetailsById(user!.uid);
        print("The email: ${user.email}");

        return FutureBuilder<DocumentSnapshot?>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, dynamic> userData =
                  (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

              if (userData['user_type'] == 'admin') {
                return const AdminScreen();
              } else if (userData['user_type'] == 'org') {
                return const OrganizationHomepage();
              } else {
                return const HomeScreen();
              }
            }
          },
        );
      },
    );
  }
}
