import 'package:beachy/constants.dart';
import 'package:beachy/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beachy',
      theme: ThemeData(
        primaryColor: Constants.lightColors.primaryColor,
        accentColor: Constants.lightColors.secondaryColor,
        buttonColor: Colors.white,
        brightness: Brightness.light
      ),
      
      home: HomePage(),
    );
  }
}
