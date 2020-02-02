import 'package:beachy/constants/cleanup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class _ActiveCleanupState extends State<ActiveCleanup> {
  Cleanup cleanup;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    this.cleanup = widget.cleanup;
    this.user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cleanup.name)),
    );
  }
}