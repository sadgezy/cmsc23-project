import 'package:cloud_firestore/cloud_firestore.dart';
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
          DrawerHeader(child: Text('Hello, ADMIN')),
          ListTile(
            title: const Text('Donations'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/");
            },
          ),
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
                  final initials =
                      Provider.of<UserAuthProvider>(context, listen: false)
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
            // Section for viewing organizations and donations
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Organizations",
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Provider.of<OrgsProvider>(context).orgs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                // Navigator.pushNamed(
                                //   context,
                                //   '/donate',
                                //   arguments: org?.id,
                                // );
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
                  );
                }
              },
            ),
            // Section for approving organization sign up
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Pending Organizations",
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donor_view')
                  .where('is_org', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      var org = snapshot.data?.docs[index];
                      return ListTile(
                        title: Text(org?['name']),
                        subtitle: Text(org?['email']),
                        // title: Text(org?['orgName']),
                        // subtitle: Text(org?['orgMotto']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () async {
                                Provider.of<OrgsProvider>(context,
                                    listen: false);
                                // .approveOrganization(org?.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () async {
                                Provider.of<OrgsProvider>(context,
                                    listen: false);
                                // .rejectOrganization(org?.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
            // Section for viewing all donors
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Donors",
                  style: Theme.of(context).textTheme.headlineLarge),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donor_view')
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