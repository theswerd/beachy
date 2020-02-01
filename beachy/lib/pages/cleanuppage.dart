import 'package:beachy/constants.dart';
import 'package:beachy/constants/cleanup.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class CleanUpPage extends StatefulWidget {
  Cleanup cleanup;
  CleanUpPage(
    this.cleanup
  );

  @override
  _CleanUpPageState createState() => _CleanUpPageState();
}

class _CleanUpPageState extends State<CleanUpPage> {
  Cleanup cleanup;

  @override
  void initState() {
    super.initState();
    this.cleanup = widget.cleanup;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      width: MediaQuery.of(context).size.width/1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(cleanup.locationShort, textScaleFactor: 1.25, softWrap: true, overflow: TextOverflow.ellipsis),
                          Text(cleanup.locationLong, textScaleFactor: 1.1, softWrap: true, overflow: TextOverflow.fade, textAlign: TextAlign.end),  
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
                      width: MediaQuery.of(context).size.width/1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(cleanup.startDateStr(), textScaleFactor: 1.25, softWrap: true, overflow: TextOverflow.ellipsis),
                          Text(cleanup.startTimeToEndTimeStr(), textScaleFactor: 1.1, softWrap: true, overflow: TextOverflow.fade, textAlign: TextAlign.end),  
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
                OutlineButton(
                  borderSide:BorderSide(color: Constants.lightColors.primaryColor),
                  child: Container(
                    height: 50,
                    child: Center(child: Text("Register Now!"))
                  ),
                  
                  onPressed: (){},
                )
              ],
            ),
          )
        ],
      ),
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
