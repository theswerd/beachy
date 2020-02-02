import 'dart:typed_data';

import 'package:beachy/constants.dart';
import 'package:beachy/constants/cleanup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class AnalyticsPage extends StatefulWidget {
  Cleanup cleanup;

  AnalyticsPage(this.cleanup);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  Cleanup cleanup;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);
    this.cleanup = widget.cleanup;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analytics")),
      body: Scaffold(
        appBar: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: <Widget>[
            Tab(icon: Icon(Mdi.image), text: "Photos"),
            Tab(icon: Icon(Mdi.chartArc), text: "Amounts"),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            FutureBuilder<QuerySnapshot>(
              future: Firestore.instance
                  .collection('events')
                  .document(cleanup.id)
                  .collection('trash')
                  .orderBy('image', descending: true)
                  .getDocuments(),
              builder: (c, s) {
                if (s.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  List<DocumentSnapshot> documents = s.data.documents;
                  return ListView.separated(
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                      itemBuilder: (c, i) {
                        DocumentSnapshot document = documents[i];
                        return FutureBuilder<Uint8List>(
                          future: FirebaseStorage.instance
                              .ref()
                              .child(document.data['image'])
                              .getData(20000000),
                          builder: (c, s) {
                            if (s.connectionState != ConnectionState.done) {
                              return Container(
                                  height: 250,
                                  color: Constants.lightColors.secondaryColor
                                      .withOpacity(.4),
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            } else if (s.hasError) {
                              return Container();
                            } else {
                              return Image.memory(
                                s.data,
                                height: 250,
                                fit: BoxFit.fitWidth,
                              );
                            }
                          },
                        );
                      },
                      separatorBuilder: (c, i) => Column(
                            children: <Widget>[
                              Text(
                                  documents[i]
                                      .data['type']
                                      .toString()
                                      .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 1.8),
                              Container(height: 30),
                              Divider()
                            ],
                          ),
                      itemCount: documents.length);
                }
              },
            ),
            FutureBuilder<QuerySnapshot>(
              future: Firestore.instance.collection('events')
                                .document(cleanup.id)
                                .collection('analyticsData').getDocuments(),             
              builder: (c, s) {
                if (s.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                } else if(s.hasError){
                  return Text("Error");
                }else {
                  List<DocumentSnapshot> docs = s.data.documents;
                  print(cleanup.id);
                  print(docs.length);
                  print(s.data.documents.isEmpty);

                  return ListView.separated(
                      itemBuilder: (c, i) => FutureBuilder<QuerySnapshot>(
                            future: Firestore.instance
                                .collection('events')
                                .document(cleanup.id)
                                .collection('analyticsData')
                                .document(docs[i].documentID)
                                .collection('amount')
                                .getDocuments(),
                            builder: (c, s) {
                              if (s.connectionState != ConnectionState.done) {
                                return Container();
                              } else {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        height: 34,
                                        width: 35,
                                        color: Colors.black),
                                    Text(docs[i].documentID.toUpperCase()),
                                    Text(s.data.documents.length.toString())
                                  ],
                                );
                              }
                            },
                          ),
                      separatorBuilder: (c, i) => Container(height: 35),
                      itemCount: docs.length);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
