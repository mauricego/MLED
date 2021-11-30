import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceCard extends StatefulWidget {
  final String ipAddress;

  const DeviceCard({Key? key, required this.ipAddress}) : super(key: key);

  @override
  _DeviceCard createState() => _DeviceCard();
}

class _DeviceCard extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50,
        height: 100,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 10,
            child: Center(
                child: Row(
                  children:
                  <Widget>[
                    IconButton(
                      icon: const Icon(Icons.power_settings_new),
                      onPressed: () {
                        //TODO API call to device and trigger on/off
                    
                      },
                    ),
                    
  

                    Text(widget.ipAddress),
                  ],

                )


            )
        )
    );
  }
}
