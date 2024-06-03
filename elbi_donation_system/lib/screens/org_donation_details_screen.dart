import 'package:elbi_donation_system/appcolors.dart';
import 'package:elbi_donation_system/models/donation_model.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:elbi_donation_system/providers/donations_provider.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

class OrgDonationDetailsScreen extends StatefulWidget {
  final Donation donation;
  final Organization org;

  const OrgDonationDetailsScreen(
      {super.key, required this.donation, required this.org});

  @override
  State<OrgDonationDetailsScreen> createState() =>
      _OrgDonationDetailsScreenState();
}

class _OrgDonationDetailsScreenState extends State<OrgDonationDetailsScreen> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;
  String dropdownValue = 'Pending';

  @override
  void initState() {
    super.initState();
    code = widget.donation.id;
    dropdownValue = widget.donation.status;
  }

  void changeStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String dropdownValue = 'Confirmed';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Change Status'),
              content: DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>[
                  'Confirmed',
                  'Pending',
                  'Completed',
                  'Scheduled for Pick-up',
                  'Cancelled'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () async {
                    if (widget.donation.id != null) {
                      await Provider.of<MyDonationsProvider>(context,
                              listen: false)
                          .updateStatus(widget.donation.id!, dropdownValue);
                      Navigator.of(context).pop();
                    } else {
                      print('Donation ID is null');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> chooseDrive(
      BuildContext context, String currentDrive, Organization org) async {
    // Ensure the list of donation drives is unique
    final drives = org.drives?.toSet().toList();

    if (drives!.isEmpty) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose Drive'),
            content: const Text('No donation drives available.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    String? selectedDrive =
        currentDrive.isNotEmpty && drives.contains(currentDrive)
            ? currentDrive
            : drives.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Choose Drive'),
              content: DropdownButton<String>(
                value: selectedDrive,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDrive = newValue!;
                  });
                },
                items: drives.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () async {
                    if (widget.donation.id != null) {
                      await Provider.of<MyDonationsProvider>(context,
                              listen: false)
                          .updateDrive(widget.donation.id!, selectedDrive!);
                      Navigator.of(context).pop();
                    } else {
                      print('Donation ID is null');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteDonation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this donation?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await Provider.of<MyDonationsProvider>(context, listen: false)
                    .deleteDonation(context, widget.donation.id!);
              },
            ),
          ],
        );
      },
    );
  }

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
                  height: MediaQuery.of(context).size.height * 0.35,
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
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
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
                          title: const Text('Donation Drive'),
                          subtitle: StreamBuilder<String>(
                            stream: Provider.of<MyDonationsProvider>(context)
                                .getDriveStream(widget.donation.id!),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(snapshot.data!.isNotEmpty
                                    ? snapshot.data!
                                    : 'Not in a Donation Drive');
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: const Text('Status'),
                          subtitle: StreamBuilder<String>(
                            stream: code != null
                                ? Provider.of<MyDonationsProvider>(context,
                                        listen: false)
                                    .getStatusStream(code!)
                                : Stream.value(widget.donation.status),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              String status = snapshot.data!;
                              return Text(
                                status,
                                style: TextStyle(
                                  color: () {
                                    switch (status) {
                                      case 'Confirmed':
                                        return AppColors.statusConfirmed;
                                      case 'Pending':
                                        return AppColors.statusPending;
                                      case 'Closed':
                                        return AppColors.statusClosed;
                                      case 'Completed':
                                        return AppColors.statusCompleted;
                                      case 'Scheduled for Pick-up':
                                        return AppColors
                                            .statusScheduledForPickup;
                                      case 'Cancelled':
                                        return AppColors.statusCancelled;
                                      default:
                                        return Colors.black;
                                    }
                                  }(),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (widget.donation.deliveryMethod == 'Pickup' &&
                      widget.donation.status != 'Cancelled')
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          changeStatus(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.update, color: Colors.white),
                              SizedBox(height: 2),
                              Text('Change Status',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.donation.deliveryMethod == 'Drop-off' &&
                      widget.donation.status != 'Cancelled')
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                              context: context,
                              onCode: (code) async {
                                setState(() {
                                  this.code = code;
                                });
                                print(code);
                                await Provider.of<MyDonationsProvider>(context,
                                        listen: false)
                                    .confirmStatus(context, code!);
                              });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.qr_code, color: Colors.white),
                              SizedBox(height: 2),
                              Text('Scan QR Code',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.donation.status != 'Cancelled')
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          chooseDrive(context, widget.donation.drive,
                              widget.org); // Pass org here
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.recycling, color: Colors.white),
                              SizedBox(height: 2),
                              Text('Choose Drive',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.donation.status !=
                      'Completed') // Check if the status is not completed
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          deleteDonation(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(height: 2),
                              Text('Delete Donation',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
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
