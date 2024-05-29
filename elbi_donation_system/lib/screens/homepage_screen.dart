import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/custom_widgets/eds_drawer.dart';
import 'package:elbi_donation_system/custom_widgets/eds_listtile.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrgsProvider(),
      child: Scaffold(
        drawer: const EdsDrawer(),
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Builder(
              builder: (context) => InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Builder(
                  builder: (context) {
                    final initials = Provider.of<UserAuthProvider>(context, listen: false)
                        .getUserInitials();
                    return InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: CircleAvatar(
                        child: Text(initials),
                      ),
                    );
                  },
                ),
              ),
            ),
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
          stream: Provider.of<OrgsProvider>(context).orgsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
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
                          future: Provider.of<OrgsProvider>(context, listen: false)
                              .getImageUrl(org?['orgLogo']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Shimmer.fromColors(
                                baseColor: Theme.of(context).primaryColor,
                                highlightColor:
                                    Theme.of(context).primaryColor.withOpacity(0.5),
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  color: Colors.white,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(child: Text('Error loading image'));
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
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
