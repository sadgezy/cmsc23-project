import 'package:elbi_donation_system/screens/homepage_screen.dart';
import 'package:flutter/material.dart';

class DonationSuccessScreen extends StatelessWidget {
  final String orgName;
  final String donorID;

  const DonationSuccessScreen(
      {super.key, required this.orgName, required this.donorID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Thank you for your donation to $orgName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Your generous contribution will make a difference.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const HomeScreen(),
                //   ),
                // );
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'Go back to Homepage',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
