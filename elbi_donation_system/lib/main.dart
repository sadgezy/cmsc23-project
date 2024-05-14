import 'package:elbi_donation_system/providers/donatepage_provider.dart';
import 'package:elbi_donation_system/providers/orgs_provider.dart';
import 'package:elbi_donation_system/screens/donatepage_screen.dart';
import 'package:elbi_donation_system/screens/homepage_screen.dart';
import 'package:elbi_donation_system/screens/signuppage_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => OrgsProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ImageSelect(),
      ),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<OrgsProvider>(context, listen: false).fetchOrgs();

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUpPageScreen(),
        '/homepage': (context) =>
            HomeScreen(),
        '/donate': (context) =>
            DonatePage(orgId: ModalRoute.of(context)!.settings.arguments as String),
      },
    );
  }
}
