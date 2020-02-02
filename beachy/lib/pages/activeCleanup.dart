import 'package:beachy/constants/cleanup.dart';
import 'package:beachy/pages/AnalyticsPage.dart';
import 'package:beachy/pages/myTrash.dart';
import 'package:beachy/pages/trashCollectionRankings.dart';
import 'package:beachy/pages/uploadTrash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class ActiveCleanup extends StatefulWidget {
  Cleanup cleanup;
  FirebaseUser user;
  ActiveCleanup(
    this.cleanup,
    this.user,
  );
  @override
  _ActiveCleanupState createState() => _ActiveCleanupState();
}

class _ActiveCleanupState extends State<ActiveCleanup>
    with TickerProviderStateMixin {
  Cleanup cleanup;
  FirebaseUser user;

  TabController _tabController;

  @override
  void initState() {
    super.initState();

    this.cleanup = widget.cleanup;
    this.user = widget.user;

    this._tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cleanup.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Mdi.menu),
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (c) => CupertinoActionSheet(
                        cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel")),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (c)=>AnalyticsPage(cleanup)
                                  )
                                );
                              }, child: Text("View Analytics"))
                        ],
                      ));
            },
          )
        ],
      ),
      body: Scaffold(
        appBar: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: <Widget>[
            Tab(
              text: "Upload Trash",
              icon: Icon(Mdi.trashCanOutline),
            ),
            Tab(
              text: "My Trash",
              icon: Icon(Mdi.faceProfile),
            ),
            Tab(
              text: "Rankings",
              icon: Icon(Mdi.trophy),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            UploadTrash(cleanup, user),
            MyTrash(cleanup, user),
            TrashCollectionRatings(cleanup)
          ],
        ),
      ),
    );
  }
}
