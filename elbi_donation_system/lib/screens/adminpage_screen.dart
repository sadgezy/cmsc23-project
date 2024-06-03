import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/screens/org_details_admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_donation_system/custom_widgets/eds_listtile.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:elbi_donation_system/providers/auth_provider.dart';
import 'package:elbi_donation_system/api/firebase_donors_api.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Drawer getDrawer(BuildContext context) {
    // final displayName = Provider.of<UserAuthProvider>(context, listen: false)
    //     .getUserDisplayName();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('Hello, ADMIN')),
          // ListTile(
          //   title: const Text('Donations'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, "/");
          //   },
          // ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              context.read<UserAuthProvider>().signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseDonorsAPI = FirebaseDonorsAPI();

    return Scaffold(
      drawer: getDrawer(context),
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
        title: const Text("Admin Dashboard"),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.search),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text("Organizations", style: Theme.of(context).textTheme.headlineLarge),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder<QuerySnapshot>(
                stream: Provider.of<OrgsProvider>(context).orgs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error'));
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
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
                                    // Future.delayed(
                                    //   const Duration(milliseconds: 200),
                                    //   () {
                                    //     Navigator.pushNamed(
                                    //       context,
                                    //       '/donate',
                                    //       arguments: org.id,
                                    //     );
                                    //   },
                                    // );
                                    print("This is Admin View");
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
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Pending Organizations",
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('is_org', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error'));
                } else {
                  var docs = snapshot.data?.docs
                          .where(
                              (doc) => doc['org_id'] != "" && doc['org_id'] != "rejected")
                          .toList() ??
                      [];

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var org = docs[index];
                      return FutureBuilder<bool>(
                        future: org['org_id'] != null
                            ? Provider.of<OrgsProvider>(context)
                                .getIsVerified(org['org_id'])
                            : Future.value(false),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            if (snapshot.data == false) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrganizationDetailScreen(
                                        orgId: org['org_id'],
                                        regId: org.id,
                                        regName: org['name'],
                                        orgEmail: org['email'],
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Text(org['name']),
                                  subtitle: Text(org['email']),
                                  // trailing: Row(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     IconButton(
                                  //       icon: const Icon(Icons.check),
                                  //       onPressed: () async {
                                  //         Provider.of<OrgsProvider>(context,
                                  //             listen: false);
                                  //         // .approveOrganization(org?.id);
                                  //       },
                                  //     ),
                                  //     IconButton(
                                  //       icon: const Icon(Icons.close),
                                  //       onPressed: () async {
                                  //         Provider.of<OrgsProvider>(context,
                                  //             listen: false);
                                  //         // .rejectOrganization(org?.id);
                                  //       },
                                  //     ),
                                  //   ],
                                  // ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                ),
                              );
                            }
                          }
                          return Container();
                        },
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Donors", style: Theme.of(context).textTheme.headlineLarge),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('is_org', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    // physics: ScrollPhysics(),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      var donor = snapshot.data?.docs[index];
                      return ListTile(
                        title: Text(donor?['name']),
                        subtitle: Text(donor?['email']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            firebaseDonorsAPI.deleteDonor(donor?.id);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
