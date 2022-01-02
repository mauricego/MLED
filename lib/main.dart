import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:hive_flutter/hive_flutter.dart";
import 'package:mled/screens/home_screen.dart';
import 'package:mled/screens/setup_screen.dart';
import 'package:mled/tools/color_convert.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() async {
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
  //false for dev
  late bool isFirstLaunch = false;

  Future<bool> _start() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('mledBox');

    box.put("isFirstLaunch", false);

    await SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool("isFirstLaunch") == null) {
        //false for dev
        prefs.setBool("isFirstLaunch", false);
        //false for dev
        isFirstLaunch = false;
      } else {
        isFirstLaunch = prefs.getBool("isFirstLaunch")!;
      }
    });
    //TODO: emulator can't use bluetooth so don't show this screen at startup for development
    return Future.value(isFirstLaunch);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "MLED",

        theme: ThemeData(
          primarySwatch: createMaterialColor(const Color.fromRGBO(27, 28, 39, 1)),
          scaffoldBackgroundColor: createMaterialColor(const Color.fromRGBO(40, 41, 61, 1)),

          buttonTheme: const ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          ),
        ),


        home: FutureBuilder<bool>(
            future: _start(), // async work
            builder: (context, AsyncSnapshot<bool> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: const Center(
                      child: SpinKitSpinningLines(
                        color: Colors.blue,
                        size: 100,
                        lineWidth: 5.0,
                        itemCount: 5,
                      ),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return const Text('Something went wrong. Restart the app');
                  } else {
                    return isFirstLaunch ? const SetupScreen() : const HomeScreen();
                  }
              }
            }));
  }
}
