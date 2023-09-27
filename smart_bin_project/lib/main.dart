import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_bin_project/pages/login_page.dart';
import 'package:smart_bin_project/pages/admin_home_page.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    Widget build(BuildContext context) {
      return  MaterialApp(

        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      );
    }

  }

