import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/appcolors.dart';
import 'package:elbi_donation_system/custom_widgets/eds_drawer.dart';
import 'package:elbi_donation_system/providers/donations_provider.dart';
import 'package:elbi_donation_system/screens/donation_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyDonationsScreen extends StatelessWidget {
  final String currentUserId;

  const MyDonationsScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EdsDrawer(),
      appBar: AppBar(
        title: const Text('My Donations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<MyDonationsProvider>(context).getUserDonations(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DonationDetailsScreen(documentId: document.id),
                          ),
                        );
                      },
                      title: FutureBuilder<String>(
                        future: Provider.of<MyDonationsProvider>(context, listen: false)
                            .getOrgNameFromId(data['org_id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text('Error');
                          } else {
                            DateTime createdAt =
                                (data['create_time'] as Timestamp).toDate();
                            String formattedTime =
                                DateFormat('MMMM dd yyyy \'at\' h:mm a')
                                    .format(createdAt);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Donation to ${snapshot.data.toString()} on $formattedTime'),
                                Row(
                                  children: [
                                    const Text('Status: '),
                                    Text(
                                      data['status'],
                                      style: TextStyle(
                                        color: () {
                                          switch (data['status']) {
                                            case 'Confirmed':
                                              return AppColors.statusConfirmed;
                                            case 'Pending':
                                              return AppColors.statusPending;
                                            case 'Closed':
                                              return AppColors.statusClosed;
                                            case 'Cancelled':
                                              return AppColors.statusCancelled;
                                            default:
                                              return Colors.black;
                                          }
                                        }(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      subtitle: const Text('Tap to view details'),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
