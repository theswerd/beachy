import 'package:beachy/constants/cleanup.dart';
import 'package:beachy/pages/cleanuppage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mdi/mdi.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  Container seperator() => Container(height: 30);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("events")
          .orderBy('date', descending: false)
          .limit(50)
          .getDocuments()
          .asStream(),
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }else if(s.hasError){
          return Center(child: Text(s.error.toString()));
        }
        List<DocumentSnapshot> documents = s.data.documents;

        return ListView.separated(
            padding: EdgeInsets.all(30),
            itemBuilder: (c, i) {
              DocumentSnapshot document = documents[i];
              Cleanup cleanup = Cleanup(
                  document['name'],
                  document['date'],
                  document['endtime'],
                  document['image'],
                  int.parse(document['inAttendance']),
                  document['locationShort'],
                  document['locationLong'],
                  document['active'] == true
                  );
              return RaisedButton(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    cleanUpImageMaker(cleanup, context),
                    cleanUpMetaDataMaker(cleanup, document)
                  ],
                ),
                onPressed: ()=>Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog:true,
                    maintainState: true,
                    builder:(c)=>CleanUpPage(cleanup)
                  )
                ),
              );
            },
            separatorBuilder: (c, i) => seperator(),
            itemCount: documents.length);
      },
    );
  }

  Padding cleanUpMetaDataMaker(Cleanup cleanup, DocumentSnapshot document) {
    return Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(cleanup.name, textScaleFactor: 1.45),
                            Text(
                                cleanup.getStartDate().month.toString() +
                                    "/" +
                                    cleanup.getStartDate().day.toString(),
                                textScaleFactor: 1.3)
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(cleanup.locationShort,
                                textScaleFactor: 1.25),
                            Text(
                                cleanup.getStartDate().hour.toString() +
                                    ":" +
                                    cleanup
                                        .getStartDate()
                                        .minute
                                        .toStringAsPrecision(2)
                                        .replaceAll(".", ""),
                                textScaleFactor: 1.3)
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(child: Text(document['locationLong'], textScaleFactor: 1.25), width: MediaQuery.of(context).size.width/1.6),
                            cleanup.active?FloatingActionButton(
                              mini: true,
                              child: Icon(Mdi.starOutline),
                              heroTag: document.toString()+cleanup.toString(),
                              onPressed: (){},
                            ):Container()
                          ],
                        )
                      ],
                    ),
                  );
  }

  FutureBuilder cleanUpImageMaker(Cleanup cleanup, BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseStorage.instance.ref().child(cleanup.image).getDownloadURL(),
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done) {
          return Container(
            color: Color(0xFFf8c630).withOpacity(.25),
            height: 125,
          );
        } else if (s.hasError) {
          return Container(
            color: Color(0xFFf8c630).withOpacity(.25),
            height: 125,
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
            height: 125,
            cacheHeight: 125,
            width: MediaQuery.of(context).size.width,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Column(children: <Widget>[
                Container(
                  color: Color(0xFFf8c630).withOpacity(.25),
                  height: 125,
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
}
