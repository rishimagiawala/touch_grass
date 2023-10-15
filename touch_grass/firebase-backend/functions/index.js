
//  Import function triggers from their respective submodules:

  const {onCall} = require("firebase-functions/v2/https");
  const {onDocumentWritten} = require("firebase-functions/v2/firestore");
  const {onDocumentCreated} = require("firebase-functions/v2/firestore");

//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
 
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getStorage, getDownloadURL } = require("firebase-admin/storage");

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const bucket = getStorage().bucket();

exports.helloworld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});



exports.manimage = onRequest((request, response) => {
    const fileRef = getStorage().bucket().file('anime_bat.png');

    fetch("https://imagerecognize.com/api/v3/", {
        method: "POST",
        body: JSON.stringify({
          apiKey: "ManavHackGT",
          type: "objects",
          file: fileRef,
          max_labels: 5,
          min_confidence: 80,

        }),
        headers: {
          "Content-type": "application/json; charset=UTF-8"
        }
      }) .then((response) => logger.info(response.json))
      .then((json) => logger.info(response.json));


   
    response.send("hee")
});