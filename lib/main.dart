import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'screens/sign_up_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';

var kLightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 0, 194, 203),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 0, 130, 140),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading
        }

        // Ensure user is not null before navigating to home
        if (snapshot.hasData && snapshot.data?.uid != null) {
          // print(snapshot.data);
          return HomeScreen(); // User is logged in
        }

        return SignInScreen(); // User is NOT logged in
      },
    );
  }
}
