import 'package:beachy/constants/cleanup.dart';
import 'package:beachy/pages/activeCleanup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class ConsentPage extends StatefulWidget {
  Cleanup cleanup;
  FirebaseUser user;
  ConsentPage(
    this.cleanup,
    this.user
  );

  @override
  _ConsentPageState createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> with TickerProviderStateMixin{
  Cleanup cleanup;
  FirebaseUser user;

  bool gloves;
  bool bag;
  bool doNotPickupHazardousStuff;

  PageController _pageController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    gloves = false;
    bag = false;
    doNotPickupHazardousStuff = false;
    
    this.cleanup = widget.cleanup;
    this.user = widget.user;

    this._pageController = new PageController();
    this._tabController = new TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saftey")),
      body: PageView(
        controller: _pageController,
        allowImplicitScrolling: false,
        children: <Widget>[
          Container(
            child: ListView(
              padding: EdgeInsets.all(15),
              children: <Widget>[
                Image.asset('assets/Beachy.png', height: 125),
                Divider(),
                Text(
                  "Before you start cleaning, we think its important you are safe.",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.5,
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Do you have gloves?",
                      textScaleFactor: 1.5,
                    ),
                    Switch(
                      value: gloves,
                      onChanged: (b) {
                        setState(() {
                          gloves = b;
                          print(gloves);
                        });
                      },
                    )
                  ],
                ),
                Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Do you have a bag?",
                      textScaleFactor: 1.5,
                    ),
                    Switch(
                      value: bag,
                      onChanged: (b) {
                        setState(() {
                          bag = b;
                          print(bag);
                        });
                      },
                    )
                  ],
                ),
                Divider(height: 30),
                Text(
                  "If you see any hazardous materials\nDO NOT TOUCH THEM.\n Immediatly notify the cleanup organizers.",
                  textScaleFactor: 1.6,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Do you understand?", textScaleFactor: 1.5,),
                    Container(
                      width: 65,
                      height: 90,
                      child: Switch(
                        value: doNotPickupHazardousStuff,
                        onChanged: (b){
                          setState(() {
                            doNotPickupHazardousStuff = b;
                          });
                        },
                      ),
                    )
                ],),
                Divider(),
                RaisedButton(
                  elevation: 15,
                  padding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  child: Center(child:Text("I understand", textScaleFactor: 1.5,)),
                  onPressed: bag&&gloves&&doNotPickupHazardousStuff?(){
                    _pageController.nextPage(duration: Duration(milliseconds: 500), curve: ElasticOutCurve());
                    // Navigator.pop(context);
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (c)=>ActiveCleanup(this.cleanup, this.user),
                    //     fullscreenDialog: true
                    //   )
                    // );
                  }:null,
                )
              ],
            ),
          ),
          Container(
            child: ListView(
              padding: EdgeInsets.all(25),
              children: <Widget>[
                Text("How to use", textScaleFactor: 1.5, textAlign: TextAlign.center),
                Divider(
                  height: 35,
                ),
                Text("1. Find a piece of trash", textScaleFactor: 1.5, textAlign: TextAlign.center),
                Divider(
                  height: 35,
                ),
                Text("2. Classify the peice of trash", textAlign: TextAlign.center, textScaleFactor: 1.5),
                Container(height: 30),
                Card(child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black ,
                  tabs: <Widget>[
                    Tab(
                      text: "Plastic",
                      icon: Icon(Mdi.bottleSodaOutline),
                    ),
                    Tab(
                      text: "Metal",
                      icon: Icon(Mdi.paperclip),
                    ),
                    Tab(
                      text: "Paper",
                      icon: Icon(Mdi.cigar),
                    ),
                    Tab(
                      text: "Hazardous",
                      icon: Icon(Mdi.biohazard),
                    ),
                  ],
                )),
                Container(height: 35),
                Divider(),
                Text("3. Take a picture with the photo button", textAlign: TextAlign.center, textScaleFactor: 1.5),
                Divider(height: 35),
                OutlineButton(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Center(child: Text("Let's get started!", textScaleFactor: 1.5,)),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        maintainState: true,
                        builder: (c)=>ActiveCleanup(cleanup, user)
                      )
                    );
                  },
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
