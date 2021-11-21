const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.redirectToLongURL = functions.https.onRequest((request, response) => {
  const shortUrl = request.headers["x-forwarded-url"].substr(1);
  const userAgent = request.headers["user-agent"];
  const countryCode = request.headers["x-country-code"];
  const secchua = request.headers["sec-ch-ua"];
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
  functions.logger.info(userAgent);
  functions.logger.info(secchua);
  // country details
  if (typeof countryCode != "undefined") {
    Ref.doc(shortUrl).update({
      ["country."+countryCode]: admin.firestore.FieldValue.increment(1),
    });
  } else {
    Ref.doc(shortUrl).update({
      ["country.others"]: admin.firestore.FieldValue.increment(1),
    });
  }
  if (typeof userAgent != "undefined") {
    // Device details
    if (userAgent.includes("Mobile")) {
      Ref.doc(shortUrl).update({
        ["device.mobile"]: admin.firestore.FieldValue.increment(1),
      });
    } else {
      Ref.doc(shortUrl).update({
        ["device.others"]: admin.firestore.FieldValue.increment(1),
      });
    }
    // Browser Details
    if (userAgent.includes("Edg/")) {
      Ref.doc(shortUrl).update({
        ["browser.edge"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("OPR/")) {
      Ref.doc(shortUrl).update({
        ["browser.opera"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("Firefox/")) {
      Ref.doc(shortUrl).update({
        ["browser.firefox"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("Safari/") &&
    !userAgent.includes("Chrome/")) {
      Ref.doc(shortUrl).update({
        ["browser.safari"]: admin.firestore.FieldValue.increment(1),
      });
    } else {
      if (typeof secchua != "undefined" &&
      secchua.includes("Google Chrome")) {
        Ref.doc(shortUrl).update({
          ["browser.chrome"]: admin.firestore.FieldValue.increment(1),
        });
      } else {
        Ref.doc(shortUrl).update({
          ["browser.others"]: admin.firestore.FieldValue.increment(1),
        });
      }
    }
    // platform details
    if (userAgent.includes("Android")) {
      Ref.doc(shortUrl).update({
        ["platform.android"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("Ubuntu")) {
      Ref.doc(shortUrl).update({
        ["platform.ubuntu"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("Linux")) {
      Ref.doc(shortUrl).update({
        ["platform.linux"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("Windows")) {
      Ref.doc(shortUrl).update({
        ["platform.windows"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("Macintosh")) {
      Ref.doc(shortUrl).update({
        ["platform.mac"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("iPhone")) {
      Ref.doc(shortUrl).update({
        ["platform.iphone"]: admin.firestore.FieldValue.increment(1),
      });
    } else if (userAgent.includes("iPad")) {
      Ref.doc(shortUrl).update({
        ["platform.ipad"]: admin.firestore.FieldValue.increment(1),
      });
    } else {
      Ref.doc(shortUrl).update({
        ["platform.others"]: admin.firestore.FieldValue.increment(1),
      });
    }
  } else {
    Ref.doc(shortUrl).update({
      ["device.others"]: admin.firestore.FieldValue.increment(1),
      ["browser.others"]: admin.firestore.FieldValue.increment(1),
      ["platform.others"]: admin.firestore.FieldValue.increment(1),
    });
  }
});
