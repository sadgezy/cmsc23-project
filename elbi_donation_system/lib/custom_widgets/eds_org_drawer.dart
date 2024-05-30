import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:elbi_donation_system/providers/auth_provider.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrgDrawer extends StatelessWidget {
  const OrgDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return getDrawer(context);
  }

  Drawer getDrawer(BuildContext context) {
    final orgsProvider = Provider.of<OrgsProvider>(context, listen: false);
    final userAuthProvider = Provider.of<UserAuthProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<Organization>(
            stream: orgsProvider.getOrgDetailsStream(),
            builder: (BuildContext context, AsyncSnapshot<Organization> snapshot) {
              if (snapshot.hasError) {
                return const DrawerHeader(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return DrawerHeader(child: Container());
              }

              Organization org = snapshot.data!;
              return Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    accountName: Text(org.name),
                    accountEmail: Text(org.motto),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(org.logoUrl),
                    ),
                  ),
                  FutureBuilder<String>(
                    future: Provider.of<OrgsProvider>(context, listen: false)
                        .getOrganizationId(org.name),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      return FilledButton(
                          onPressed: () {
                            if (ModalRoute.of(context)?.settings.name !=
                                "/edit_org_profile") {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, "/edit_org_profile",
                                  arguments: snapshot.data);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Edit Org Profile'));
                    },
                  ),
                ],
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              userAuthProvider.signOut();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
