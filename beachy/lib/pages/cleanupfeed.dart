import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("events").orderBy('date', descending: false).limit(50).snapshots(),
      builder: (c,s){
        if(s.connectionState!=ConnectionState.done){
          return Center(child: CircularProgressIndicator());
        }else{
          return Text(s.data.documents.toString());
        }
      },
    );
  }
}