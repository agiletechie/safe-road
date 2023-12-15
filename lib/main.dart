import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_safety/data/data.dart';
import 'package:road_safety/firebase_options.dart';
import 'package:road_safety/provider/auth_notifier.dart';
import 'package:road_safety/screens/auth.dart';
import 'package:road_safety/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Road Safety',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      theme: ThemeData.light(useMaterial3: true),

      /// Made custom notifier instead of auth stream
      /// so that it will build only after getting username
      home: ChangeNotifierProvider(
        create: (context) => AuthNotifier(data: Data())..fetchUser(),
        child: Consumer<AuthNotifier>(
            builder: (context, AuthNotifier value, child) {
          if (value.user?.displayName != null) {
            return Home();
          } else {
            return AuthPage();
          }
        }),
      ),
      // home: ChangeNotifierProvider<AuthNotifier>(
      //   create: (context) => AuthNotifier(data: Data()),
      //   child: StreamBuilder(
      //     stream: FirebaseAuth.instance.authStateChanges(),
      //     builder: (context, snapshot) {
      //       if (snapshot.data?.displayName == null) {
      //         return AuthPage();
      //       }
      //       return Home();
      //     },
      //   ),
      // ),
    );
  }
}
