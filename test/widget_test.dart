// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mled/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('setup_screen click add device and go to find devices', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); //set values here
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool firstTimeOpen = true;
    pref.setBool("isFirstLaunch", firstTimeOpen);
    expect(pref.getBool("isFirstLaunch"), true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    await tester.pumpAndSettle();

    // Verify that add device button is visible
    expect(find.text('Add Device'), findsWidgets);

    // Tap the add device button
    await tester.tap(find.text('Add Device'));

    await tester.pumpAndSettle();
    // Verify that bluetooth screen is visible
    expect(find.text('Find devices'), findsWidgets);
    expect(pref.getBool("isFirstLaunch"), true);
  });
}
