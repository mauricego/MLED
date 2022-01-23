import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mled/screens/home_screen.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/tools/edge_alert.dart';
import 'package:permission_handler/permission_handler.dart';

//ignore: must_be_immutable
class Manually extends StatefulWidget {
  const Manually({Key? key}) : super(key: key);

  @override
  _Manually createState() => _Manually();
}

class _Manually extends State<Manually> {
  List<String> deviceList = <String>[];
  bool gotMatchingIpAddressNotify = true;
  String ipAddress = "0.0.0.0";
  late Box box;
  RegExp regExIp = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    box.close();
    super.dispose();
  }

  showDialog() async {
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'Device IP address',
          validator: (ipAddress) {
            if (ipAddress != null) {
              if (!regExIp.hasMatch(ipAddress)) {
                return "Not a valid IP address";
              }
            } else {
              return "No Input";
            }

          },
        ),
      ],
      title: 'Connection Setup',
      message: 'Input your devices IP address',
    );
    ipAddress = text!.elementAt(0);
    await _checkConnection();
  }

  _storeDevices() async {
    await Hive.initFlutter();
    box = await Hive.openBox("mled");
    box.put("devices", deviceList);
  }

  Future<void> _checkConnection() async {
    await getRequest(ipAddress + "/information").timeout(const Duration(seconds: 2)).catchError((error, stackTrace) {
      gotMatchingIpAddressNotify = false;
      return Future.value("Timeout");
    });

    if (gotMatchingIpAddressNotify) {
      EdgeAlert.show(context,
          title: 'Connection successfully',
          description: 'You are good to go',
          gravity: EdgeAlert.TOP,
          backgroundColor: const Color.fromRGBO(46, 204, 113, 1.0),
          duration: EdgeAlert.LENGTH_SHORT,
          icon: Icons.done);
      //go back to home screen
      deviceList.add(ipAddress);
      await _storeDevices();
      await box.put("isFirstLaunch", false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      gotMatchingIpAddressNotify = true;
      EdgeAlert.show(context,
          title: 'Connection failed',
          description: 'Your IP address is wrong or the device is not connected',
          gravity: EdgeAlert.TOP,
          backgroundColor: const Color.fromRGBO(237, 66, 69, 1.0),
          duration: EdgeAlert.LENGTH_VERY_LONG,
          icon: Icons.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
