import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Cleanup {
  String name;
  Timestamp date;
  Timestamp endTime;
  String image;
  int inAttendance;
  String locationShort;
  String locationLong;
  bool active;
  Cleanup(
    this.name,
    this.date,
    this.endTime,
    this.image,
    this.inAttendance,
    this.locationShort,
    this.locationLong,
    this.active
  );
  DateTime getStartDate()=>date.toDate();
  DateTime getEndDate()=>endTime.toDate();

  String startDateStr(){
    DateTime startDate = getStartDate();
    DateFormat formatter = new DateFormat('EEEE, MMMM dd');
    String formatted = formatter.format(startDate);
    return formatted; // something like 2013-04-20
  }
  String startTimeToEndTimeStr(){
    DateTime startDate = getStartDate();
    DateTime endDate = getEndDate();
    DateFormat formatter = new DateFormat('jm');

    String formatted = formatter.format(startDate) + ' - ' + formatter.format(endDate);
    return formatted;
  }

  String currentlyRegisteredPeople(){
    return this.inAttendance.toString()+" people are currently registered to come!";
  }
}