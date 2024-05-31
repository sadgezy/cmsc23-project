import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrganizationDetailScreen extends StatelessWidget {
  final String? orgId;
  final String? orgName;
  final String? orgEmail;
  final List<String>? proofImages;

  OrganizationDetailScreen(
      {this.orgId, this.orgName, this.orgEmail, this.proofImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orgName ?? 'Organization Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDetailBox('Name: $orgName'),
              const SizedBox(height: 16.0),
              buildDetailBox('Email: $orgEmail'),
              const SizedBox(height: 16.0),
              proofImages != null && proofImages!.isNotEmpty
                  ? Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: proofImages?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(proofImages![index]),
                            ),
                          );
                        },
                      ),
                    )
                  : buildDetailBox('No proof images available'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailBox(String text) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
