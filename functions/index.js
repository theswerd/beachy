const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Imports the Google Cloud client libraries
const vision = require('@google-cloud/vision');

exports.onUpload = functions.storage.object().onFinalize(async (object) => {
    // Creates a client
    const client = new vision.ImageAnnotatorClient();

    /**
     * TODO(developer): Uncomment the following line before running the sample.
     */
    const gcsUri = `gs://bucket/${object.name}`;

    const [result] = await client.objectLocalization(gcsUri);
    const objects = result.localizedObjectAnnotations;
    objects.forEach(object => {
      console.log(`Name: ${object.name}`);
      console.log(`Confidence: ${object.score}`);
      const veritices = object.boundingPoly.normalizedVertices;
      veritices.forEach(v => console.log(`x: ${v.x}, y:${v.y}`));
    });
});

exports.signUpNewUser = functions.auth.user().onCreate((user) => {

});

exports.joinEvent = functions.https.onRequest(async (req, res) => {
  // Grab the text parameter.
  const event = req.body.eventID;
  const userToken = req.headers.authorization;

  // Push the new message into the Realtime Database using the Firebase Admin SDK.
  const snapshot = await admin.database().ref('/messages').push({original: original});
  // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
  res.redirect(303, snapshot.ref.toString());
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
