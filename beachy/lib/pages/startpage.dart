import 'package:beachy/constants.dart';
import 'package:beachy/constants/signIn.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/Constants/Helpers.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:mdi/mdi.dart';
class IntroPages extends StatefulWidget {
  @override
  _IntroPagesState createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages>{
  List<Container> pages;

  @override
  void initState() {
    super.initState();
    pages = [
    Container(
      color: Color(0xff36D1DC),      
      padding: EdgeInsets.all(35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(height: 100, width: 100, color: Colors.black),
          Container(height: 70,),
          Text("Welcome to Beachy, the beach cleanup app!", textScaleFactor: 1.5, textAlign: TextAlign.center,),
          Container(height: 50,),
          Text("To continue, please swipe left", textScaleFactor: 1.25, textAlign: TextAlign.center,),
        ],
      ),
    ),
    Container(
      color: Constants.lightColors.secondaryColor,
      padding: EdgeInsets.all(35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("We help bring coastal communities together through beach cleanups.", textAlign: TextAlign.center, textScaleFactor: 1.5,),
          Container(height: 50,),
          Text("We help environmental organizations analyze the data from beach cleanups.", textScaleFactor: 1.5, textAlign: TextAlign.center,),
          Container(height: 50,),
          Text("And most importantly we help you help the beach!", textScaleFactor: 1.5, textAlign: TextAlign.center,),
          Container(height: 50),
          RaisedButton(
            padding: EdgeInsets.symmetric(horizontal:30, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            splashColor: Constants.lightColors.primaryColor,
            child: Text("To get started please sign in!", textScaleFactor: 1.25,),
            color: Colors.white,
            onPressed: () async{
              bool loggedIn = await signInWithGoogle();
              loggedIn?Navigator.pop(context):null;
            },

          )
        ],
      ),
    ),
  ];
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidSwipe(
        waveType: WaveType.liquidReveal,
        pages: pages,
        enableSlideIcon: true,
        enableLoop: true,
        slideIconWidget: Icon(Mdi.arrowRight),
      )
    );
  }
}