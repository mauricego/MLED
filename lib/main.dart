import 'package:flutter/material.dart';
import 'package:mled/screens/bluetooth.dart';
import 'package:mled/screens/home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: HomeScreen(),
  );
}



