import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

class MyUser {
  String uid;

  MyUser(User user) {
    this.uid = user.uid;
  }
}

class Authenticate {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //auth change user change
  Stream<MyUser> get user {
    return _auth.authStateChanges().map((User user) {
      return (user == null) ? null : MyUser(user);
    });
  }

  //register with email and password
  Future<void> registerWithEmailAndPassword(String email, String password,
      String username, BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      final DocumentReference myDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await myDoc.set({"name": username, "email": email, "urls": []});
      Navigator.pop(context);
    } catch (e) {
      Toast.show(e.message.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }

  //sign in with email and password
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.pop(context);
      print(result);
    } catch (e) {
      print(e.toString());
      Toast.show(e.message.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }

  Future<MyUser> anonymousSignIn(BuildContext context) async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return MyUser(result.user);
    } catch (e) {
      print(e.toString());
      Toast.show(e.message.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      return null;
    }
  }

  //signout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}

class DatabaseService {
  static Stream<Map> userdata(String uid) {
    final DocumentReference myDoc =
        FirebaseFirestore.instance.collection("users").doc(uid);
    return myDoc.snapshots().map((snapshot) => snapshot.data());
  }

  static Stream<Map> urlData(String url) {
    String collection = (int.tryParse(url[0]) != null) ? "general" : "custom";
    final DocumentReference myDoc =
        FirebaseFirestore.instance.collection(collection).doc(url);
    return myDoc.snapshots().map((snapshot) => snapshot.data());
  }

  static Future<Map> getUserDetails(MyUser user) async {
    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot snap = await ref.get();
    return snap.data();
  }

  static Future<bool> urlExists(String url) async {
    final DocumentReference ref =
        FirebaseFirestore.instance.collection('custom').doc(url);
    DocumentSnapshot doc = await ref.get();
    return doc.exists;
  }

  static Future<void> addURL(
      {BuildContext context,
      String userID,
      String shortURL,
      String longURL,
      bool custom,
      Function done}) async {
    String collection = custom ? "custom" : "general";
    final CollectionReference colRef =
        FirebaseFirestore.instance.collection(collection);
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(userID);

    try {
      DocumentSnapshot snap = await docRef.get();
      if (snap.data() == null) {
        await colRef.doc(shortURL).set({"url": longURL});
      } else {
        List<dynamic> urls = snap.data()["urls"];
        urls.add(shortURL);
        await colRef.doc(shortURL).set({
          "url": longURL,
          "count": 0,
          "platform": {
            "windows": 0,
            "linux": 0,
            "ubuntu": 0,
            "mac": 0,
            "iphone": 0,
            "ipad": 0,
            "android": 0,
            "others": 0
          },
          "country": {"IN": 0},
          "browser": {
            "chrome": 0,
            "edge": 0,
            "safari": 0,
            "firefox": 0,
            "opera": 0,
            "others": 0
          },
          "device": {"mobile": 0, "others": 0}
        });
        await docRef.update({"urls": urls});
      }
      done();
    } catch (e) {
      print(e.toString());
      Toast.show(e.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }
}
