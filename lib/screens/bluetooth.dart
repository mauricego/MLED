import 'dart:convert';

import 'package:mled/tools/edge_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mled/screens/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

//ignore: must_be_immutable
class Bluetooth extends StatefulWidget {
  Bluetooth({Key? key}) : super(key: key);
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  late BluetoothDevice connectedDevice;
  late String ipAddress;

  @override
  _Bluetooth createState() => _Bluetooth();
}

class _Bluetooth extends State<Bluetooth> {
  @override
  void initState() {
    super.initState();
    _requestPermissionAndScan();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        widget.flutterBlue.stopScan();

        try {
          await widget.connectedDevice.disconnect();
        } catch (e) {
          //do nothing. connectedDevice not initialized
        }

        //clear the list
        widget.devicesList.clear();
        //clear the state
        setState(() {});
        // pop to get back to home
        Navigator.pop(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Find devices"),
            centerTitle: true,
          ),
          body: _buildListViewOfDevices()));

  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name.contains("LED-Strip-")) {
        containers.add(
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(child: Center(child: Text(device.name == '' ? '(unknown device)' : device.name))),
                FlatButton(
                  color: Colors.blue,
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    widget.flutterBlue.stopScan();
                    try {
                      device.connect().onError((error, stackTrace) => {device.disconnect(), device.connect()});
                      setState(() {
                        widget.connectedDevice = device;
                      });
                      _showDialog();
                    } catch (e) {
                      if (e != 'already_connected') {
                        rethrow;
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  _showDialog() async {
    String ssid = "";
    String password = "";
    final text = await showTextInputDialog(
      context: context,
      textFields: const [
        DialogTextField(
          hintText: 'SSID/WLAN name',
        ),
        DialogTextField(
          hintText: 'Password',
          obscureText: true,
        ),
      ],
      title: 'Connection Setup',
      message: 'Input your SSID/WLAN name and password',
    );
    ssid = text!.elementAt(0);
    password = text.elementAt(1);
    String jsonString = '{"ssid":"' + ssid + '",' + '"password":"' + password + '"}';
    //send data to esp32
    _sendData(jsonString);
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  _requestPermissionAndScan() async {
    //location is needed in order to use bluetooth
    await Permission.location.request().then((value) => _searchDevices(value));
    var status = await Permission.location.status;
  }

  _searchDevices(PermissionStatus permission) {
    if (permission.isGranted) {
      widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
        for (BluetoothDevice device in devices) {
          _addDeviceTolist(device);
        }
      });
      widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          if (result.device.name != "") {
            _addDeviceTolist(result.device);
          }
        }
      });
      widget.flutterBlue.startScan();
    }
  }

  _sendData(String data) async {
    late BluetoothCharacteristic characteristic;
    List<BluetoothService> deviceServices = await widget.connectedDevice.discoverServices();
    for (BluetoothService service in deviceServices) {
      if (service.uuid.toString() == "f9c521f6-0f14-4499-8f76-43116b40007d") {
        for (BluetoothCharacteristic blCharateristic in service.characteristics) {
          if (blCharateristic.uuid.toString() == "23456f8d-4aa7-4a61-956b-39c9bce0ff00") {
            characteristic = blCharateristic;
          }
        }
      }
    }
    //write data to characteristic
    await characteristic.write(utf8.encode(data)).then((value) => characteristic.read().then((value) => widget.ipAddress = (utf8.decode(value))));

    //regular expression all valid ip address
    RegExp regExp = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

    // check if the ip address is valid
    if (regExp.hasMatch(widget.ipAddress)) {
      EdgeAlert.show(context,
          title: 'Connection successfully',
          description: 'You are good to go',
          gravity: EdgeAlert.TOP,
          backgroundColor: const Color.fromRGBO(46, 204, 113, 1.0),
          duration: EdgeAlert.LENGTH_SHORT,
          icon: Icons.done);
      //go back to home screen
      Navigator.pop(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      EdgeAlert.show(context,
          title: 'Connection failed',
          description: 'Your SSID or Password is invalid',
          gravity: EdgeAlert.TOP,
          backgroundColor: const Color.fromRGBO(237, 66, 69, 1.0),
          duration: EdgeAlert.LENGTH_VERY_LONG,
          icon: Icons.warning);
    }
  }
}
