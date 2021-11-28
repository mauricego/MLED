import 'package:flutter/material.dart';
import 'package:mled/screens/home_screen.dart';
import 'package:mled/screens/setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  _navigateToHomeScreen() {
    //push replacement to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  _navigateToSetupScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetupScreen()),
    );
  }

  _start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTimeOpen = prefs.getBool("firstTimeOpen");

    if (firstTimeOpen != null && !firstTimeOpen) {
      _navigateToHomeScreen();
    } else {
      prefs.setBool("firstTimeOpen", false);
      _navigateToSetupScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
