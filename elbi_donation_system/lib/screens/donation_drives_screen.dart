import 'package:flutter/material.dart';
import 'package:elbi_donation_system/models/organization_model.dart';
import 'package:provider/provider.dart';
import 'package:elbi_donation_system/providers/donations_provider.dart';

class DonationDrivesScreen extends StatefulWidget {
  final Organization org;

  const DonationDrivesScreen({super.key, required this.org});

  @override
  _DonationDrivesScreenState createState() => _DonationDrivesScreenState();
}

class _DonationDrivesScreenState extends State<DonationDrivesScreen> {
  late List<String> drives;

  @override
  void initState() {
    super.initState();
    drives = widget.org.drives ??
        []; // Provide a default empty list if drives is null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Donation Drives')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddDriveDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: drives.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                String? editedDriveName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDriveScreen(
                      driveName: drives[index],
                      orgName: widget.org.name,
                    ),
                  ),
                );
                if (editedDriveName != null) {
                  setState(() {
                    drives[index] = editedDriveName;
                  });
                }
              },
            ),
            title: Text(drives[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, drives[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddDriveDialog(BuildContext context) {
    final TextEditingController driveNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Donation Drive'),
          content: TextField(
            controller: driveNameController,
            decoration: const InputDecoration(
              labelText: 'Drive Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                String newDriveName = driveNameController.text.trim();
                if (newDriveName.isNotEmpty) {
                  Navigator.of(context).pop();
                  _addDrive(context, newDriveName);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addDrive(BuildContext context, String driveName) async {
    try {
      await Provider.of<MyDonationsProvider>(context, listen: false)
          .addDonationDrive(widget.org.name, driveName); // Use org.name here
      setState(() {
        drives.add(driveName); // Update the local state
      });
      print('Donation drive added successfully.');
    } catch (e) {
      print('Error adding donation drive: $e');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String driveName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete the drive "$driveName"?'),
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
                Navigator.of(context).pop();
                _deleteDrive(context, driveName);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDrive(BuildContext context, String driveName) async {
    try {
      await Provider.of<MyDonationsProvider>(context, listen: false)
          .deleteDonationDriveByName(
              widget.org.name, driveName); // Use org.name here
      setState(() {
        drives.remove(driveName);
      });
      print('Donation drive deleted successfully.');
    } catch (e) {
      print('Error deleting donation drive: $e');
    }
  }
}

class EditDriveScreen extends StatefulWidget {
  final String driveName;
  final String orgName;

  const EditDriveScreen(
      {super.key, required this.driveName, required this.orgName});

  @override
  _EditDriveScreenState createState() => _EditDriveScreenState();
}

class _EditDriveScreenState extends State<EditDriveScreen> {
  final TextEditingController driveNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    driveNameController.text = widget.driveName;
  }

  @override
  void dispose() {
    driveNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donation Drive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: driveNameController,
              decoration: const InputDecoration(
                labelText: 'Drive Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newDriveName = driveNameController.text.trim();
                if (newDriveName.isNotEmpty &&
                    newDriveName != widget.driveName) {
                  try {
                    await Provider.of<MyDonationsProvider>(context,
                            listen: false)
                        .updateDonationDrive(
                            widget.orgName, widget.driveName, newDriveName);
                    Navigator.of(context)
                        .pop(newDriveName); // Pass the new name back
                  } catch (e) {
                    print('Error editing donation drive: $e');
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
