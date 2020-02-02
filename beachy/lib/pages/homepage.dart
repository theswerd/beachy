import 'package:beachy/pages/cleanupfeed.dart';
import 'package:beachy/pages/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child:ListView(
          children: <Widget>[
            ListTile(
              title: Text("Logout"),
              onTap:()=>FirebaseAuth.instance.signOut()
            ),
            
          ],
        )
      ),
      appBar: AppBar(
        title: Text("Beachy"),
      ),
      body: Feed(),
    );
  }

  void checkLogin() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if(user == null){
      //NOT LOGGED IN
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (c)=>IntroPages(),
          fullscreenDialog: true,
          maintainState: false
        )
      );
    }else{
      //LOGGED IN
    }
  }
}