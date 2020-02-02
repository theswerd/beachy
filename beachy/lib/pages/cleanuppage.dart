import 'package:beachy/constants.dart';
import 'package:beachy/constants/cleanup.dart';
import 'package:beachy/pages/activeCleanup.dart';
import 'package:beachy/pages/consentPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mdi/mdi.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class CleanUpPage extends StatefulWidget {
  Cleanup cleanup;
  CleanUpPage(this.cleanup);

  @override
  _CleanUpPageState createState() => _CleanUpPageState();
}

class _CleanUpPageState extends State<CleanUpPage> {
  Cleanup cleanup;

  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    this.cleanup = widget.cleanup;
    this._scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: cleanup.active?FloatingActionButton.extended(onPressed: () async{
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        DocumentSnapshot documentSnapshot = await Firestore.instance.collection('users').document(user.uid).collection('events').document(this.cleanup.id).get();
        if(documentSnapshot.exists){
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (c)=>ConsentPage(
                this.cleanup,
                user
              )
            )
          );
        }else{
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("You need to register first!"),
            )
          );
        }
      }, label:Text("Cleanup is active -- Join Now!"), icon: Icon(Mdi.beach), heroTag: "Enter Cleanup",):Container(),
      appBar: AppBar(
        title: Text(cleanup.name),
      ),
      body: ListView(
        children: <Widget>[
          cleanUpImageMaker(cleanup, context),
          Container(
            padding: EdgeInsets.all(25),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Location", textScaleFactor: 1.25),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(cleanup.locationShort,
                              textScaleFactor: 1.25,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis),
                          Text(cleanup.locationLong,
                              textScaleFactor: 1.1,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.end),
                        ],
                      ),
                    )
                  ],
                ),
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Date", textScaleFactor: 1.25),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(cleanup.startDateStr(),
                              textScaleFactor: 1.25,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis),
                          Text(cleanup.startTimeToEndTimeStr(),
                              textScaleFactor: 1.1,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.end),
                        ],
                      ),
                    )
                  ],
                ),
                Divider(),
                Text(
                  cleanup.currentlyRegisteredPeople(),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.25,
                ),
                Divider(),
                FutureBuilder<FirebaseUser>(
                    future: FirebaseAuth.instance.currentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Container();
                      } else {
                        return FutureBuilder<DocumentSnapshot>(
                            future: Firestore.instance
                                .collection('users')
                                .document(snapshot.data.uid)
                                .collection('events')
                                .document(cleanup.id)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return Container();
                              } else {
                                if (!snapshot.data.exists) {
                                  return registerButton();
                                } else {
                                  return OutlineButton(
                                      child: Container(
                                          height: 50,
                                          child: Center(
                                              child: Text(
                                                  "Registered, see you there!"))),
                                      onPressed: null);
                                }
                              }
                            });
                      }
                    }),
                Divider(),
                add2CalendarButton()
              ],
            ),
          )
        ],
      ),
    );
  }

  OutlineButton add2CalendarButton() {
    return OutlineButton(
      borderSide: BorderSide(color: Constants.lightColors.primaryColor),
      child: Container(
          height: 50, child: Center(child: Text("Add to your calendar"))),
      onPressed: () {
        final Event event = Event(
          title: cleanup.name,
          description: "A beach cleanup at " + cleanup.locationShort,
          location: cleanup.locationLong,
          startDate: cleanup.getStartDate(),
          endDate: cleanup.getEndDate(),
        );
        Add2Calendar.addEvent2Cal(event);
      },
    );
  }

  OutlineButton registerButton() {
    String registerStr = "Register Now!";

    return OutlineButton(
      borderSide: BorderSide(color: Constants.lightColors.primaryColor),
      child: Container(height: 50, child: Center(child: Text(registerStr))),
      onPressed: () async {
        //const event = req.body.eventID;
        //const userToken = req.headers.authorization;
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        IdTokenResult token = await user.getIdToken();
        print("ITS TRYING");
        Response response = await post(
            'https://us-central1-beachy-ee0ed.cloudfunctions.net/joinEvent',
            headers: {
              'authorization': token.token,
            },
            body: {
              'eventID': this.cleanup.id
            });
        print("WE GOTTA RESPONSE");
        print(response.body);
        if(response.statusCode == 200){
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Constants.lightColors.primaryColor,
              content: Text("You have been registered!"),
            )
          );
        }
      },
    );
  }
}

FutureBuilder cleanUpImageMaker(Cleanup cleanup, BuildContext context) {
  return FutureBuilder(
    future:
        FirebaseStorage.instance.ref().child(cleanup.image).getDownloadURL(),
    builder: (c, s) {
      if (s.connectionState != ConnectionState.done) {
        return Container(
          color: Color(0xFFf8c630).withOpacity(.25),
          height: 200,
        );
      } else if (s.hasError) {
        return Container(
          color: Color(0xFFf8c630).withOpacity(.25),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Mdi.alertCircleOutline),
              Text("Sorry, we can't fetch this image right now.",
                  textAlign: TextAlign.center)
            ],
          ),
        );
      } else {
        String downloadLink = s.data;
        return Image.network(
          downloadLink,
          fit: BoxFit.fitWidth,
          height: 200,
          cacheHeight: 200,
          width: MediaQuery.of(context).size.width,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Column(children: <Widget>[
              Container(
                color: Color(0xFFf8c630).withOpacity(.25),
                height: 200,
              ),
              LinearProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              )
            ]);
          },
        );
      }
    },
  );
}
