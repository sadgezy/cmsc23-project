import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/providers/auth_provider.dart';
import 'package:elbi_donation_system/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class EdsDrawer extends StatelessWidget {
  const EdsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return getDrawer(context);
  }

  Drawer getDrawer(BuildContext context) {
    final userAuthProvider = Provider.of<UserAuthProvider>(context, listen: false);
    final displayName = userAuthProvider.getUserDisplayName();
    final userId = userAuthProvider.user!.uid;
    final provider = Provider.of<UserProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<DocumentSnapshot<Object?>>(
            future: provider.getUserDetailsById(userId),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const DrawerHeader(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return DrawerHeader(child: Container());
              }

              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              return FutureBuilder<String>(
                future: provider.getImageUrl(data['profile_picture']),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return const DrawerHeader(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DrawerHeader(child: Container());
                  }

                  return Column(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        accountName: Text(data['name']),
                        accountEmail: Text(data['email']),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!),
                        ),
                      ),
                      FilledButton(
                          onPressed: () {
                            if (ModalRoute.of(context)?.settings.name !=
                                "/edit_profile") {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, "/edit_profile",
                                  arguments: userId);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Edit Profile'))
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Homepage'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != "/home") {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/home");
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: const Text('My Donations'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != "/donations") {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/donations",
                    arguments: context.read<UserAuthProvider>().user!.uid);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              context.read<UserAuthProvider>().signOut();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
