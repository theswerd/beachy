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
    // objects.forEach(object => {
    //   console.log(`Name: ${object.name}`);
    //   console.log(`Confidence: ${object.score}`);
    //   const veritices = object.boundingPoly.normalizedVertices;
    //   veritices.forEach(v => console.log(`x: ${v.x}, y:${v.y}`));
    // });
  });
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
