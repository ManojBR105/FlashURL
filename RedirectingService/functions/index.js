const functions = require("firebase-functions");
const admin= require("firebase-admin");
admin.initializeApp();
exports.redirectToLongURL = functions.https.onRequest((request, response) => {
  // functions.logger.info(request.headers["x-country-code"]);
  // functions.logger.info(request.headers["sec-ch-ua"]);
  // functions.logger.info(request.headers["sec-ch-ua-mobile"]);
  // functions.logger.info(request.headers["sec-ch-ua-platform"]);
  // functions.logger.info(request.headers["x-forwarded-url"]);
  const shortUrl = request.headers["x-forwarded-url"].substr(1);
  let redirectURL;
  let Ref;
  if (shortUrl.charAt(0) >= "0" && shortUrl.charAt(0) <= "9") {
    Ref = admin.firestore().collection("general");
  } else {
    Ref = admin.firestore().collection("custom");
  }
  Ref.doc(shortUrl).get().then((doc) => {
    if (!doc.exists) {
      redirectURL = "https://flashurl.web.app/";
    } else {
      redirectURL = doc.data().url;
      Ref.doc(shortUrl).update({
        count: admin.firestore.FieldValue.increment(1),
      });
    }
    response.redirect(redirectURL);
  });
  // functions.logger.info(request.headers["x-forwarded-host"]);
  functions.logger.info(request);
});

