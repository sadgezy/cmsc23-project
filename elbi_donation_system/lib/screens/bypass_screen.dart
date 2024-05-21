import 'package:elbi_donation_system/screens/homepage_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './signinpage_screen.dart';

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
        // snapshot.connectionState == ConnectionState.waiting;
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

        // if user is logged in, display the scaffold containing the streambuilder for the todos
        print("===============");
        print(context);
        print("===============");
        print(userStream);
        print("Home Screen agad");
        print(snapshot);
        print("Bat ganono");
        return const HomeScreen();
      },
    );
  }
}
