import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return ListView.builder(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: (context, index) {
                var org = snapshot.data?.docs[index];
                return ListTile(
                  leading: FutureBuilder<String>(
                    future: Provider.of<OrgsProvider>(context, listen: false)
                        .getImageUrl(org?['orgLogo']),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError) {
                          print('Error getting image URL: ${snapshot.error}');
                          return const Icon(Icons.error);
                        } else {
                          return CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        }
                      }
                    },
                  ),
                  title: Text(org?['orgName']),
                  subtitle: Text(org?['orgMotto']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
