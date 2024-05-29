import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_donation_system/providers/donations_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class DonationDetailsScreen extends StatefulWidget {
  final String documentId;

  const DonationDetailsScreen({super.key, required this.documentId});

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    Future<DocumentSnapshot<Object?>> data =
        Provider.of<MyDonationsProvider>(context, listen: false)
            .getDonationDetailsById(widget.documentId);
    return FutureBuilder<DocumentSnapshot>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          List<String> trueCategories = [];
          Map<String, dynamic> itemCategory = data['item_category'];
          itemCategory.forEach((key, value) {
            if (value == true) {
              trueCategories.add(key);
            }
          });
          return Scaffold(
            appBar: AppBar(
              title: const Text('Donation Details'),
            ),
            body: ListView(
              children: <Widget>[
                ListTile(
                    subtitle: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['image'],
                    width: 100,
                  ),
                )),
                ListTile(
                  title: const Text('Item Category'),
                  subtitle: Text(trueCategories.join(', ')),
                ),
                ListTile(
                  title: const Text('Weight'),
                  subtitle: Text(data['weight'].toString()),
                ),
                ListTile(
                  title: const Text('Donor Contact Number'),
                  subtitle: Text(data['contact_number']),
                ),
                ListTile(
                  title: const Text('Pickup/Dropoff Date'),
                  subtitle: Text(DateFormat('MMMM dd, yyyy')
                      .format((data['date_time'] as Timestamp).toDate())),
                ),
                ListTile(
                  title: const Text('Delivery Method'),
                  subtitle: Text(data['delivery_method']),
                ),
                ListTile(
                  title: const Text('Organization Name'),
                  subtitle: FutureBuilder<String>(
                    future: Provider.of<MyDonationsProvider>(context, listen: false)
                        .getOrgNameFromId(data['org_id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        return Text(snapshot.data.toString());
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Status'),
                  subtitle: Text(data['status']),
                ),
                ListTile(
                  title: const Text('Selected Address'),
                  subtitle: Text(data['selected_address'].toString().toUpperCase()),
                ),
                data['status'] != 'Cancelled' && data['delivery_method'] == 'Drop-off'
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: FilledButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 60,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(2.0),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.symmetric(vertical: 8.0),
                                              child: Text(
                                                'Show this QR code to the organization to confirm your donation.',
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                              height: MediaQuery.of(context).size.height *
                                                  0.3,
                                              child: Center(
                                                child: Screenshot(
                                                  controller: screenshotController,
                                                  child: QrImageView(
                                                    data: widget.documentId.toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            FilledButton(
                                              onPressed: () {
                                                Provider.of<MyDonationsProvider>(context,
                                                        listen: false)
                                                    .captureAndSaveQRCode(
                                                        screenshotController);
                                              },
                                              child: const Text('Save QR Code'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text('Dropoff'),
                              ),
                            ),
                            ElevatedButton(
                              child: const Text('Cancel Donation'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CancelDialog(
                                      document: snapshot.data!,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : data['status'] != 'Cancelled' && data['delivery_method'] == 'Pickup'
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CancelDialog(document: snapshot.data!);
                                        },
                                      );
                                    },
                                    child: const Text('Cancel Donation'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container()
              ],
            ),
          );
        }
      },
    );
  }
}

class CancelDialog extends StatelessWidget {
  final DocumentSnapshot document;
  const CancelDialog({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure you want to cancel?'),
      content: const Text('Your donation can really help someone in need. '),
      actions: <Widget>[
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Yes, let them suffer.'),
          onPressed: () {
            Provider.of<MyDonationsProvider>(context, listen: false)
                .updateStatus(document.id, 'Cancelled');
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
