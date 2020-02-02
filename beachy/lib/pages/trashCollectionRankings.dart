import 'package:beachy/constants/cleanup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrashCollectionRatings extends StatefulWidget {
  Cleanup cleanup;
  TrashCollectionRatings(
    this.cleanup
  );

  @override
  _TrashCollectionRatingsState createState() => _TrashCollectionRatingsState();
}

class _TrashCollectionRatingsState extends State<TrashCollectionRatings> {
  Cleanup cleanup;
  
  @override
  void initState() {
    super.initState();

    this.cleanup = widget.cleanup;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance.collection('events').document(cleanup.id).collection('participants').orderBy('points').limit(25).getDocuments(),
      builder: (c,s){
        if(s.connectionState!=ConnectionState.done){
          return Center(child: CircularProgressIndicator());
        }else{
          QuerySnapshot snapshot = s.data;
          List<DocumentSnapshot> documents = snapshot.documents;
          return ListView.separated(
            separatorBuilder: (c,s)=>Container(height: 20),
            itemBuilder: (c,i){
              DocumentSnapshot doc = documents[i];
              return ListTile(
                title: Text(doc.data['name']),
                subtitle: Text(doc.data['points'].toString()+" points"),
                trailing: Text("#"+(i+1).toString(), textScaleFactor: 1.5,),
              );
            },
            itemCount: documents.length
          );
        }
      },
    );
  }
}