const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Imports the Google Cloud client libraries
const vision = require('@google-cloud/vision');
const fs = require('fs');

// Creates a client
const client = new vision.ImageAnnotatorClient();

exports.onUpload = functions.storage.object().onFinalize(async (object) => {
    /**
     * TODO(developer): Uncomment the following line before running the sample.
     */
    const fileName = object.name;
    const request = {
      image: {content: fs.readFileSync(fileName)},
    };

    const [result] = await client.objectLocalization(request);
    const objects = result.localizedObjectAnnotations;
    objects.forEach(object => {
      if(object.name === `Packaged goods`) {
        console.log(`yes`);
      } else {
        console.log(`${object.name}`);
      }
      console.log(`Confidence: ${object.score}`);
      const vertices = object.boundingPoly.normalizedVertices;
      vertices.forEach(v => console.log(`x: ${v.x}, y:${v.y}`));
    });
  });
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
