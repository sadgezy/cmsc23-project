import 'package:elbi_donation_system/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EdsDrawer extends StatelessWidget {
  const EdsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return getDrawer(context);
  }

  Drawer getDrawer(BuildContext context) {
    final displayName =
        Provider.of<UserAuthProvider>(context, listen: false).getUserDisplayName();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(child: Text('Hello, $displayName')),
          ListTile(
            title: const Text('Homepage'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != "/home") {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/home");
              }
            },
          ),
          ListTile(
            title: const Text('Donations'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != "/donations") {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/donations",
                    arguments: context.read<UserAuthProvider>().user!.uid);
              }
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
}
