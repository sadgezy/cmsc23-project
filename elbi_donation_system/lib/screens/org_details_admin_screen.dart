import 'package:elbi_donation_system/api/firebase_orgs_api.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrganizationDetailScreen extends StatelessWidget {
  final String orgId;
  final String regId;
  final String regName;
  final String orgEmail;

  const OrganizationDetailScreen(
      {super.key,
      required this.orgId,
      required this.regName,
      required this.orgEmail,
      required this.regId});

  @override
  Widget build(BuildContext context) {
    String orgName = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: StreamBuilder<Organization>(
        stream: Provider.of<OrgsProvider>(context).getOrgDetailsStreamById(orgId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            Organization org = snapshot.data!;
            orgName = org.name;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(org.logoUrl),
                    ),
                    const SizedBox(height: 16.0),
                    buildDetailBox("Organization Name: ", org.name),
                    buildDetailBox("Email", orgEmail),
                    buildDetailBox("Application Requestor", regName),
                    const Text('Proof of Registration: ', style: TextStyle(fontSize: 16)),
                    Card(
                      child: FutureBuilder<List<String>>(
                        future: FirebaseOrgsAPI().getProofPhotos(org.proofImages),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error'));
                          } else {
                            List<String> photos = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.18,
                                child: Center(
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 1),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: photos.length,
                                    itemBuilder: (context, index) {
                                      return Image.network(photos[index]);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // circular border
                ),
              ),
              onPressed: () async {
                await Provider.of<OrgsProvider>(context, listen: false)
                    .updateVerification(orgId, regId);
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // circular border
                ),
              ),
              onPressed: () async {
                await Provider.of<OrgsProvider>(context, listen: false)
                    .deleteOrganization(orgId, regId, orgName);
                Navigator.of(context).pop();
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailBox(String titletext, String text) {
    return ListTile(
      title: Center(
        child: Text(
          titletext,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      subtitle: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
