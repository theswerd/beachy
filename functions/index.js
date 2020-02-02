const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Imports the Google Cloud client libraries
const vision = require('@google-cloud/vision');

const db = admin.firestore();


exports.onUpload = functions.storage.object().onFinalize(async (object) => {
    // Creates a client
    const client = new vision.ImageAnnotatorClient();

    const gcsUri = `gs://beachy-ee0ed.appspot.com/${object.name}`;
    console.log(gcsUri)
    console.log("Starting #1");
    const [result] = await client.objectLocalization(gcsUri);
    console.log("Starting #2");
    const objects = result.localizedObjectAnnotations;
    console.log("OK IT WORKED");
  
    console.log(objects);
    return db.collection("trashPeices").doc(object.name).create({
      types: objects
    });
});

exports.signUpNewUser = functions.auth.user().onCreate((user) => {
  return db.collection("users").doc(user.uid).create(
    {
      isOrganization: false,
      points: 0
    }
  );
});

exports.userOrganizationStatus = functions.firestore.document('users/{userID}').onUpdate(async (snapshot, context) => {
  let data = snapshot.after.data();
  let isOrganization = data.isOrganization;
  if(isOrganization){
    let userID = context.params.userID;
    let user = await admin.auth().getUser(userID);
    let email = user.email;
    return db.collection('organizations').doc(email).create({});
  }else{
    return db.collection('organizations').doc(email).delete();
  }
});
exports.createEvent = functions.https.onRequest(async (req,res)=>{
  let userToken = req.headers.authorization;
  let userTokenResult = await admin.auth().verifyIdToken(userToken);
  let user = await admin.auth().getUser(user.uid);
  let email = user.email;
  let adminListObject = await db.collection('organizations').doc(email).get();
  if(adminListObject.exists){
    //IS Organization
    let image = req.body.image;
    let date = req.body.date;
    let endtime = req.body.endtime;
    let locationShort = req.body.locationShort;
    let locationLong = req.body.locationLong;
    let orgName = req.body.orgName;
    let inAttendance = 0;
    return db.collection('events').add(
      {
        image: image,
        date: date,
        endtime: endtime,
        locationShort: locationShort,
        locationLong: locationLong,
        orgName: orgName,
        inAttendance: inAttendance,
        happening: false,
        active: false
      }
    );
  }else{
    //NOT Organization
    return res.status(400).send('You aren\'t an organization!');
  }
});

exports.joinEvent = functions.https.onRequest(async (req, res) => {
  // Grab the text parameter.
  const event = req.body.eventID;
  const userToken = req.headers.authorization;

  const user = await admin.auth().verifyIdToken(userToken);
  const userInfo = await admin.auth().getUser(user.uid);
  if(user !== undefined){
    const eventDoc = await db.collection('events').doc(event).get();
    if(eventDoc.exists){
      if(eventDoc.data()['happened'] !== true){
        //Event hasn't happened yet, and they are a user
        db.collection('events').doc(event).collection('participants').doc(user.uid).create(
          {
            signedUp: Date.now(),
            points: 0,
            name: userInfo.displayName
          }
        );
        res.status(200).send("Success!");
      }else{
        res.status(401).send("Event already happened");
      }
    }else{
      res.status(401).send("Event doesn't exist");
    }
  }else{
    res.status(401).send("You aren't loggged in");
  }
  // Push the new message into the Realtime Database using the Firebase Admin SDK.
  // const snapshot = await admin.database().ref('/messages').push({original: original});
  // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
});

exports.addEventToUserDoc = functions.firestore.document("events/{eventID}/participants/{userID}").onCreate((snapshot,context)=>{
  db.collection('users').doc(
    context.params.userID
  ).collection('events').doc(
    context.params.eventID
  ).set(
    {
      time: Date.now()
    }
  )
});
exports.updateEventRegistrationAmount = functions.firestore.document("events/{eventID}/participants/{userID}").onCreate(async(snapshot,context)=>{
  let participants = await db.collection('events').doc(context.params.eventID).collection('participants').listDocuments();
  db.collection('events').doc(
    context.params.eventID
  ).update(
    {
      inAttendance: participants.length
    }
  )
});

exports.postPeiceOfTrashToEvent = functions.https.onRequest(async (req, res) => {
  const eventName = req.body.eventID;
  const typeOfTrash = req.body.type;
  const image = req.body.image;

  const userToken = req.headers.authorization;

  const user = await admin.auth().verifyIdToken(userToken);
  if(user !== undefined){
    const event = await db.collection("events").doc(eventName).get();
    if(event.exists){
      const eventParticipant = await db.collection("events").doc(eventName).collection('participants').doc(user.uid).get();
      if(eventParticipant.exists){
        const imageData = await db.collection('trashPeices').doc(image).get();
          db.collection("events").doc(eventName).collection('trash').add(
            {
              type: typeOfTrash,
              image: image,
              user: user.uid,
              imageData:imageData.id
            }
          )
          return res.status(200).send("Recieved");
       
      }
    }else{
      return res.status(400).send("Event doesn't exist");
    }
  }else{
    return res.status(400).send("You aren't logged in");
  }
});
exports.givePointToUserInEvent = functions.firestore.document('events/{eventID}/trash/{trashID}').onCreate(async(snapshot, context)=>{
  let userDoc = await db.collection('events').doc(context.params.eventID).collection('participants').doc(snapshot.data().user).get();
  let points = userDoc.data()['points'];
   return db.collection('events').doc(context.params.eventID).collection('participants').doc(snapshot.data().user).update({
     points: points+1
   });
 });
exports.registerPeiceOfTrashInAnalyticsData = functions.firestore.document('events/{eventID}/trash/{trashID}').onCreate((snapshot, context)=>{

  const eventID = context.params.eventID;
  const type = snapshot.data().type;
  const imageData = snapshot.data().imageData;
  
  return db.collection('events').doc(eventID).collection('analyticsData').doc(type).collection('amount').add({trash:imageData});
});
exports.registerPeiceOfTrashInAnalytics = functions.firestore.document('events/{eventID}/analyticsData/{typeID}/amount/{trashObject}').onCreate(async (snapshot, context)=>{
  const eventID = context.params.eventID;
  const typeID = context.params.typeID;
  const amountData = await db.collection('events').doc(eventID).collection('analyticsData').doc(typeID).collection('amount').listDocuments();
  const amount = amountData.length;

  return db.collection('events').doc(eventID).update({
    typeID: amount
  })
});
