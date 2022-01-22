import 'package:flutter/material.dart';
import 'package:mled/screens/bluetooth.dart';

import 'device_manually.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Setup"),
        centerTitle: true,
      ),
      body: Column(children: [
        const SizedBox(height: 20,),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: const Text("Add Device"),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Bluetooth()));
            },
          ),
        ),
        const SizedBox(height: 20,),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: const Text("Enter Device IP"),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Manually()));
            },
          ),
        )
      ]));
}
