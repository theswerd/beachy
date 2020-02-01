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

exports.joinEvent = functions.https.onRequest(async (req, res) => {
  // Grab the text parameter.
  const event = req.body.eventID;
  const userToken = req.headers.authorization;

  const user = await admin.auth().verifyIdToken(userToken);
  if(user != null){
    const eventDoc = await db.collection('events').doc(event).get();
    if(eventDoc.exists){
      if(eventDoc.data()['happened'] != true){
        //Event hasn't happened yet, and they are a user
        db.collection('events').doc(event).collection('participants').doc(user.uid).create(
          {
            signedUp: Date.now()
          }
        );
        res.status(200).send("success");
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

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
