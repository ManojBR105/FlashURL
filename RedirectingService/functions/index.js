const functions = require("firebase-functions");
const admin= require("firebase-admin");
admin.initializeApp();
exports.redirectToLongURL = functions.https.onRequest((request, response) => {
  const shortUrl = request.headers["x-forwarded-url"].substr(1);
  const userAgent = request.headers["user-agent"];
  const countryCode = request.headers["x-country-code"];
  const secchua = request.headers["sec-ch-ua"];
  const secchuamobile = request.headers["sec-ch-ua-mobile"];
  const secchuaplatform = request.headers["sec-ch-ua-platform"];

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
      response.redirect(redirectURL);
    }
  });
  Ref.doc(shortUrl).update({
    count: admin.firestore.FieldValue.increment(1),
  });
  if (typeof countryCode != "undefined" && countryCode == "IN") {
    Ref.doc(shortUrl).update({
      ["country.india"]: admin.firestore.FieldValue.increment(1),
    });
  } else {
    Ref.doc(shortUrl).update({
      ["country.others"]: admin.firestore.FieldValue.increment(1),
    });
  }
  if (typeof secchua != "undefined") {
    if (secchua.includes("Google Chrome")) {
      Ref.doc(shortUrl).update({
        ["browser.chrome"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (secchua.includes("Microsoft Edge")) {
      Ref.doc(shortUrl).update({
        ["browser.edge"]: admin.firestore.FieldValue.increment(1),
      });
    } else {
      Ref.doc(shortUrl).update({
        ["browser.unknown"]: admin.firestore.FieldValue.increment(1),
      });
    }
  } else {
    Ref.doc(shortUrl).update({
      ["browser.unknown"]: admin.firestore.FieldValue.increment(1),
    });
  }
  if (typeof secchuamobile != "undefined" && secchuamobile.includes("1")) {
    Ref.doc(shortUrl).update({
      ["device.mobile"]: admin.firestore.FieldValue.increment(1),
    });
  } else {
    Ref.doc(shortUrl).update({
      ["device.unknown"]: admin.firestore.FieldValue.increment(1),
    });
  }
  if (typeof secchuaplatform != "undefined") {
    if (secchuaplatform.includes("Android")) {
      Ref.doc(shortUrl).update({
        ["platform.android"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (secchuaplatform.includes("Windows")) {
      Ref.doc(shortUrl).update({
        ["platform.windows"]: admin.firestore.FieldValue.increment(1),
      });
    } else {
      if (typeof userAgent != "undefined") {
        if (userAgent.includes("iPhone")) {
          Ref.doc(shortUrl).update({
            ["platform.ios"]: admin.firestore.FieldValue.increment(1),
          });
        } else {
          Ref.doc(shortUrl).update({
            ["platform.others"]: admin.firestore.FieldValue.increment(1),
          });
        }
      }
    }
  } else {
    Ref.doc(shortUrl).update({
      ["platform.others"]: admin.firestore.FieldValue.increment(1),
    });
  }
});
