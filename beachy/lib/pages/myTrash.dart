import 'dart:typed_data';

import 'package:beachy/constants/cleanup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTrash extends StatefulWidget {
  FirebaseUser user;
  Cleanup cleanup;

  MyTrash(
    this.cleanup,
    this.user
  );
  
  @override
  _MyTrashState createState() => _MyTrashState();
}

class _MyTrashState extends State<MyTrash> {
  MyTrashBody myTrashBody;

  FirebaseUser user;
  Cleanup cleanup;
  
  @override
  void initState() {
    super.initState();

    this.user = widget.user;
    this.cleanup = widget.cleanup;

    myTrashBody = new MyTrashBody(user, cleanup);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myTrashBody,
    );
  }
}

class MyTrashBody extends StatefulWidget {

  FirebaseUser user;
  Cleanup cleanup;

  MyTrashBody(
    this.user,
    this.cleanup
  );
  
  @override
  _MyTrashBodyState createState() => _MyTrashBodyState();
}

class _MyTrashBodyState extends State<MyTrashBody> {
 
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance.collection('events').document(this.widget.cleanup.id).collection('trash').where('user', isEqualTo: widget.user.uid).getDocuments(),
      builder: (c,s){
        if(s.connectionState!=ConnectionState.done){
          return Center(child: CircularProgressIndicator());
        }else{
          List<DocumentSnapshot> documents = s.data.documents;
          if(documents.isEmpty){
            return Center(child: Text("You haven't picked up any trash yet", textScaleFactor: 1.5, textAlign: TextAlign.center,));
          }else{
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (c,i){
              DocumentSnapshot documentSnapshot = documents[i];
              return ListTile(
                title: Text(documentSnapshot.data['type']),
                subtitle: FutureBuilder<DocumentSnapshot>(
                  future: Firestore.instance.collection('trashPeices').document(documentSnapshot.data['image']).get(),
                  
                  builder: (context, snapshot) {
                    if(s.connectionState!=ConnectionState.done){
                      return Container();
                    }
                    if(s.hasError){
                      return Text("WE GOTTA ERROR");
                    }
                    return snapshot.hasData?Text("Using Google Cloud Vision AI, we recognized \""+snapshot.data.data['types'][0]['name'].toString()+"\""):Text("Google Cloud Vision API Loading -- Check back in soon");
                  }
                ),
                trailing: FutureBuilder<Uint8List>(
                  future: FirebaseStorage.instance.ref().child(documentSnapshot['image']).getData(10000000000),
                  builder: (c,s){
                    if(s.connectionState!=ConnectionState.done){
                      return CircularProgressIndicator(
                        
                      );
                    }
                    return Image.memory(s.data);
                  }
                )
              );
            });
          }
        }
      },
    );
  }
}