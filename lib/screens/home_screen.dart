import 'package:flutter/material.dart';

import 'package:mled/screens/bluetooth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Homescreen"),
        centerTitle: true,
      ),
      body: Center(
          child: ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
        child: const Text("Add Device"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Bluetooth()));
        },
      )));
}
