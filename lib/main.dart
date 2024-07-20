import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/spals.dart'; // Ganti dengan nama file Anda jika berbeda

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnboardingPage1(),
    );
  }
}
