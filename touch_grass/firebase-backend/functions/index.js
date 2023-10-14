
//  Import function triggers from their respective submodules:

  const {onCall} = require("firebase-functions/v2/https");
  const {onDocumentWritten} = require("firebase-functions/v2/firestore");
  const {onDocumentCreated} = require("firebase-functions/v2/firestore");

//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
 
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");


initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.helloworld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});


