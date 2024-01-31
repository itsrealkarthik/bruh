// ignore_for_file: unused_import

import 'package:bruh/constants/constants.dart';
import 'package:bruh/helper/SharedPreference.dart';
import 'package:bruh/helper/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'onboarding_page.dart';
import 'homepage_page.dart';
import 'login_page.dart';
import 'pages/Community/CommunityCreatePost.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
      create: ((context) => AuthAPI()), child: const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final value = context.watch<AuthAPI>().status;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: value == AuthStatus.uninitialized
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : value == AuthStatus.authenticated
              ? const OnboardingPage()
              : const HomePage(),
    );
  }
}


// class _AppState extends State<App> {
//   var auth = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     final value = context.watch<AuthAPI>().status;
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return const HomePage();
//             } else {
//               return const OnboardingPage();
//             }
//           },
//         ));
//   }
// }