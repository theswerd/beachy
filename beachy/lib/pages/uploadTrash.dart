import 'dart:async';
import 'dart:io';

import 'package:beachy/constants/cleanup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mdi/mdi.dart';

class UploadTrash extends StatefulWidget {
  Cleanup cleanup;
  FirebaseUser user;
  UploadTrash(this.cleanup, this.user);
  @override
  _UploadTrashState createState() => _UploadTrashState();
}

class _UploadTrashState extends State<UploadTrash>
    with TickerProviderStateMixin {
  Cleanup cleanup;
  FirebaseUser user;

  GlobalKey<ScaffoldState> _scaffoldKey;
  TabController _tabController;
  String type;
  final List types = ['Plastic', 'Metal', 'Paper', 'Hazardous'];

  @override
  void initState() {
    super.initState();

    this.cleanup = widget.cleanup;
    this.user = widget.user;
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    _tabController = new TabController(length: 4, vsync: this);
    type = types.first;
    _tabController.addListener(() {
      setState(() {
        type = types[_tabController.index];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Text(
            "Set trash type",
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
          ),
          Divider(),
          Card(
            clipBehavior: Clip.hardEdge,
            elevation: 5,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
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
            ),
          ),
          Container(height: 10),
          Card(
            elevation: 5,
            margin: EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                this.type + " Waste",
                textScaleFactor: 1.4,
              )),
            ),
          ),
          Divider(),
          Text(
            "If you are ready, please take a photo of the trash.",
            textAlign: TextAlign.center,
            textScaleFactor: 1.5,
          ),
          Divider(),
          OutlineButton.icon(
              padding: EdgeInsets.all(15),
              onPressed: sendDataToServer,
              icon: Icon(Mdi.cameraOutline),
              label: Text("Take Photo"))
        ],
      ),
    );
  }

  void sendDataToServer() async {
              try {
                File image = await ImagePicker.pickImage(
                    source: ImageSource.camera, imageQuality: 90);
                print(image);
                print("AGDSGSDG");
                bool imageExists = await image.exists();
                print(imageExists);
                if (imageExists) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    elevation: 10,
                    content: Text("Started upload"),
                  ));
                  final StorageReference storageReference = FirebaseStorage()
                      .ref()
                      .child(
                          DateTime.now().microsecondsSinceEpoch.toString());
  
                  final StorageUploadTask uploadTask =
                      storageReference.putFile(image);
                  print("Checkpoint #1");
                  final StreamSubscription<StorageTaskEvent>
                      streamSubscription =
                      uploadTask.events.listen((event) async {
                    if (event.type == StorageTaskEventType.success) {
                      IdTokenResult token = await this.user.getIdToken();
                      sleep(Duration(seconds: 1));
                      Response r = await post(
                          'https://us-central1-beachy-ee0ed.cloudfunctions.net/postPeiceOfTrashToEvent',
                          body: {
                            "eventID": cleanup.id,
                            "type": type.toLowerCase(),
                            "image": storageReference.path,
                          },
                          headers: {
                            "authorization": token.token
                          });
                      print("Checkpoint #4");
                      print("WE GOTTA RESPONSEEE");
                      print(r.body);
                      print(r.statusCode);
                      _scaffoldKey.currentState.hideCurrentSnackBar();
                      if (r.statusCode == 200) {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          elevation: 10,
                          content: Text("Trash uploaded!"),
                        ));
                      } else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          elevation: 10,
                          backgroundColor: Colors.redAccent,
                          content: Text("Trash failed to upload"),
                        ));
                      }
                    }
                  });
                  print("Checkpoint #2");
                }
                // if (image != null) {
                //   _scaffoldKey.currentState.showSnackBar(SnackBar(
                //     elevation: 10,
                //     content: Text("Started upload"),
                //   ));
                //   StorageUploadTask uploadTask =
                //       FirebaseStorage.instance.ref().putData(image.readAsBytesSync());
                //   uploadTask.onComplete.then((onValue) async {
                //     IdTokenResult token = await this.user.getIdToken();
                //     print(onValue.ref.path);
                //     print(onValue);
  
                //   });
                // } else {
                //   _scaffoldKey.currentState.showSnackBar(SnackBar(
                //     elevation: 10,
                //     content: Text("NO IMAGE"),
                //   ));
                //   print("NO IMAGE");
                // }
              } catch (e) {
                print("NO IMAGE");
                print(e);
              }
            }
}
