import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/custom_widgets/eds_listtile.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Drawer getDrawer(BuildContext context) {
  //   return Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: [
  //         const DrawerHeader(child: Text("Test_Donation")),
  //         ListTile(
  //           title: const Text('Donations'),
  //           onTap: () {
  //             Navigator.pop(context);
  //             Navigator.pushNamed(context, "/");
  //           },
  //         ),
  //         ListTile(
  //           title: const Text('Logout'),
  //           onTap: () {
  //             context.read<UserAuthProvider>().signOut();
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: getDrawer(context),
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: CircleAvatar(),
        ),
        title: const Text("Organizations"),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.search),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<OrgsProvider>(context).orgs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      var org = snapshot.data?.docs[index];
                      return FutureBuilder<String>(
                        future:
                            Provider.of<OrgsProvider>(context, listen: false)
                                .getImageUrl(org?['orgLogo']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error loading image'));
                          } else {
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/donate',
                                  arguments: org?.id,
                                );
                              },
                              child: EDSListTile(
                                logoUrl: snapshot.data!,
                                title: org?['orgName'],
                                subtitle: org?['orgMotto'],
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () {
                    context.read<UserAuthProvider>().signOut();
                    // Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
