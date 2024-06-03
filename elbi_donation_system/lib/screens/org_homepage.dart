import 'package:elbi_donation_system/custom_widgets/eds_org_drawer.dart';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:elbi_donation_system/screens/org_donation_details_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class OrganizationHomepage extends StatelessWidget {
  const OrganizationHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Organization>(
      stream: Provider.of<OrgsProvider>(context).getOrgDetailsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final org = snapshot.data;
          return Scaffold(
            drawer: const OrgDrawer(),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Builder(
                  builder: (context) => InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Builder(
                      builder: (context) {
                        return InkWell(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(org!.logoUrl),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              title: const Text("Organization Homepage"),
            ),
            body: FutureBuilder<String>(
              future: Provider.of<OrgsProvider>(context)
                  .getOrganizationId(org!.name),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error here: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final orgId = snapshot.data;
                  return StreamBuilder<List<Donation>>(
                    stream: Provider.of<OrgsProvider>(context)
                        .getOrgDonationsStream(orgId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error dito: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        final donations = snapshot.data;
                        final pickupDonations = donations!
                            .where((donation) =>
                                donation.deliveryMethod == 'Pickup')
                            .toList();
                        final dropOffDonations = donations
                            .where((donation) =>
                                donation.deliveryMethod == 'Drop-off')
                            .toList();

                        return ListView.builder(
                          itemCount: pickupDonations.length +
                              dropOffDonations.length +
                              2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Pickup Donations:'),
                              );
                            } else if (index <= pickupDonations.length) {
                              final donation = pickupDonations[index - 1];
                              return FutureBuilder<String>(
                                future: Provider.of<OrgsProvider>(context)
                                    .getUserName(donation.orgDonor),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                              'Donation from ${snapshot.data}'),
                                          subtitle: Text(
                                              'Status: ${donation.status}'),
                                          trailing: IconButton(
                                            icon:
                                                const Icon(Icons.arrow_forward),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrgDonationDetailsScreen(
                                                    donation: donation,
                                                    org: org,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            } else if (index == pickupDonations.length + 1) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Drop off Donations:'),
                              );
                            } else {
                              final donation = dropOffDonations[
                                  index - pickupDonations.length - 2];
                              return FutureBuilder<String>(
                                future: Provider.of<OrgsProvider>(context)
                                    .getUserName(donation.orgDonor),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                              'Donation from ${snapshot.data}'),
                                          subtitle: Text(
                                              'Status: ${donation.status}'),
                                          trailing: IconButton(
                                            icon:
                                                const Icon(Icons.arrow_forward),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrgDonationDetailsScreen(
                                                    donation: donation,
                                                    org: org,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        );
                      } else {
                        return const Text('No donations found');
                      }
                    },
                  );
                } else {
                  return const Text('No organization ID found');
                }
              },
            ),
          );
        }
      },
    );
  }
}
