import 'package:elbi_donation_system/appcolors.dart';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

class OrgDonationDetailsScreen extends StatefulWidget {
  final Donation donation;

  const OrgDonationDetailsScreen({super.key, required this.donation});

  @override
  State<OrgDonationDetailsScreen> createState() => _OrgDonationDetailsScreenState();
}

class _OrgDonationDetailsScreenState extends State<OrgDonationDetailsScreen> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fit: BoxFit.cover,
                  widget.donation.image,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              ),
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Donor Name'),
                          subtitle: FutureBuilder<String>(
                            future: Provider.of<OrgsProvider>(context)
                                .getUserName(widget.donation.orgDonor),
                            builder:
                                (BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return Text(snapshot.data ?? 'No data');
                              } else if (snapshot.connectionState ==
                                  ConnectionState.none) {
                                return const Text("No data");
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Donation Weight'),
                          subtitle: Text(widget.donation.weight.toString()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Donation Date'),
                          subtitle: Text(DateFormat('MMMM dd, yyyy')
                              .format(widget.donation.dateTime)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Category'),
                          subtitle: Text(
                            widget.donation.itemCategory.clothes
                                ? 'Clothes'
                                : widget.donation.itemCategory.food
                                    ? 'Food'
                                    : widget.donation.itemCategory.necessities
                                        ? 'Necessities'
                                        : 'Others',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Contact Number'),
                          subtitle: Text(widget.donation.contactNumber ??
                              'No contact number provided'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Status'),
                          subtitle: Text(
                            widget.donation.status,
                            style: TextStyle(
                              color: () {
                                switch (widget.donation.status) {
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (widget.donation.deliveryMethod == 'Pickup')
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          // Handle status change
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.update, color: Colors.white),
                              SizedBox(height: 4),
                              Text('Change Status',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.donation.deliveryMethod == 'Drop-off')
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                              context: context,
                              onCode: (code) {
                                setState(() {
                                  this.code = code;
                                });
                                print(code);
                              });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.qr_code, color: Colors.white),
                              SizedBox(height: 4),
                              Text('Scan QR Code', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: InkWell(
                      onTap: () {
                        // Handle donation drive selection
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.recycling, color: Colors.white),
                            SizedBox(height: 4),
                            Text('Choose Drive', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
