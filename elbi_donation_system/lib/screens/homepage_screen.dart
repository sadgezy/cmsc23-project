import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/custom_widgets/eds_drawer.dart';
import 'package:elbi_donation_system/custom_widgets/eds_listtile.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:elbi_donation_system/screens/org_rejected_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else {
              final userId =
                  Provider.of<UserAuthProvider>(context, listen: false).user!.uid;
              return Column(
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: Provider.of<OrgsProvider>(context, listen: false)
                        .getUserStatus(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error here: ${snapshot.error}');
                      }
                      if (snapshot.data != null &&
                          snapshot.data!.containsKey('is_org') &&
                          snapshot.data!['is_org'] == true &&
                          snapshot.data!.containsKey('user_type') &&
                          snapshot.data!['user_type'] == 'donor') {
                        if (snapshot.data != null &&
                            snapshot.data!.containsKey('org_id') &&
                            snapshot.data!['org_id'] == 'rejected') {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const OrgRejectedScreen(),
                              ),
                            );
                          });
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Theme.of(context).colorScheme.secondary,
                              child: const ListTile(
                                leading: Icon(Icons.warning, color: Colors.black),
                                textColor: Colors.black,
                                title: Text(
                                    'Your organization\'s application is under review',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                          );
                        }
                      }
                      return Container();
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data?.docs
                              .where((org) => org['is_verified'] == true)
                              .length ??
                          0,
                      itemBuilder: (context, index) {
                        var org = snapshot.data?.docs
                            .where((org) => org['is_verified'] == true)
                            .elementAt(index);
                        if (org!['is_verified'] == true) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/donate',
                                    arguments: org.id,
                                  );
                                },
                                child: EDSListTile(
                                  logoUrl: org['orgLogo'],
                                  title: org['orgName'],
                                  subtitle: org['orgMotto'],
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
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
