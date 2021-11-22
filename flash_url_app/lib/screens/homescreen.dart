import 'dart:math';

import 'package:flash_url_app/models/shared.dart';
import 'package:flash_url_app/widgets/UrlTIle.dart';
import 'package:flutter/material.dart';
import 'package:flash_url_app/models/firebase.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum Status { AUTO, CUSTOM, DONE }

class HomeScrn extends StatefulWidget {
  final MyUser user;
  HomeScrn(this.user);
  @override
  _HomeScrnState createState() => _HomeScrnState(user);
}

class _HomeScrnState extends State<HomeScrn> {
  final MyUser user;
  final _longformkey = GlobalKey<FormState>();
  final _shortformkey = GlobalKey<FormState>();
  bool loading = true;
  Status currState = Status.AUTO;
  Map userData;
  String longURL = "";
  String shortURL = "";
  final String baseURL = "https://flashurl.web.app/";
  _HomeScrnState(this.user);
  TextEditingController longURLController = TextEditingController();
  TextEditingController shortURLController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    userData = await DatabaseService.getUserDetails(user);
    print(userData);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: DatabaseService.userdata(user.uid),
        builder: (context, snapshot) {
          userData = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.red[50],
            appBar: AppBar(
              leading: IconButton(
                onPressed: () async {
                  await Authenticate().signOut();
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: Text(
                  loading
                      ? "Loading"
                      : userData != null
                          ? userData["name"].toString()
                          : "Guest",
                  style: TextStyle(fontSize: 25.0, fontFamily: 'Rubik')),
              backgroundColor: Colors.redAccent[700],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: dynamicUI(),
                ),
                Divider(),
                userData == null
                    ? Container()
                    : ListTile(
                        tileColor: Colors.redAccent[700],
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Your URLs",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Count",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                Divider(),
                snapshot.data == null
                    ? Container()
                    : Expanded(
                        child: ListView.builder(
                            controller: new ScrollController(),
                            itemCount: userData["urls"].length,
                            itemBuilder: (BuildContext context, int index) {
                              return UrlTile(userData["urls"][index]);
                            }),
                      ),
              ],
            ),
          );
        });
  }

  Widget dynamicUI() {
    Widget res;
    switch (currState) {
      case Status.AUTO:
        res = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _longformkey,
              child: TextFormField(
                validator: (value) {
                  if (!Uri.parse(value).isAbsolute)
                    return "Please enter a valid link";
                  else
                    return null;
                },
                controller: longURLController,
                maxLines: 2,
                decoration: inputdecoration.copyWith(
                    hintText: "Enter The Long URL to be shortened"),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                autoShorten();
              },
              child: Text("Auto Shorten"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.redAccent[700])),
            ),
            ElevatedButton(
              onPressed: () {
                if (userData != null)
                  currState = Status.CUSTOM;
                else
                  Toast.show(
                      "This feature is only for registered users, please register and try again",
                      context,
                      duration: Toast.LENGTH_LONG,
                      gravity: Toast.CENTER);
                setState(() {});
              },
              child: Text("Try Custom Shorten"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber[600]),
                  foregroundColor: MaterialStateProperty.all(Colors.black)),
            )
          ],
        );
        break;
      case Status.CUSTOM:
        res = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _longformkey,
              child: TextFormField(
                validator: (value) {
                  if (!Uri.parse(value).isAbsolute)
                    return "Please enter a valid link";
                  else
                    return null;
                },
                controller: longURLController,
                maxLines: 2,
                decoration: inputdecoration.copyWith(
                    hintText: "Enter The Long URL to be shortened"),
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: _shortformkey,
              child: TextFormField(
                validator: (value) {
                  if (int.tryParse(value[0]) != null)
                    return "Custom URL should start with a numeric character";
                  else if (isNotValid(shortURL))
                    return "Short URL must only contain Alphabets and Numbers";
                  else
                    return null;
                },
                controller: shortURLController,
                maxLines: 1,
                decoration: inputdecoration.copyWith(
                    hintText: "Enter custom URL to shorten to"),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                customShorten();
              },
              child: Text("Custom Shorten"),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.redAccent[700])),
            ),
            ElevatedButton(
              onPressed: () {
                currState = Status.AUTO;
                setState(() {});
              },
              child: Text("Use Auto Shorten"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber[600]),
                  foregroundColor: MaterialStateProperty.all(Colors.black)),
            )
          ],
        );
        break;
      case Status.DONE:
        res = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          GestureDetector(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Original URL:  $longURL",
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Shortened URL:  $baseURL$shortURL",
                      style: TextStyle(color: Colors.blue[500]),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              var url = "$baseURL$shortURL";
              if (await canLaunch(url))
                await launch(url);
              else
                // can't launch url, there is some error
                throw "Could not launch $url";
            },
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "$baseURL$shortURL"));
            },
            child: Text("Copy Shortened URL"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.redAccent[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              currState = Status.AUTO;
              setState(() {});
            },
            child: Text("Shorten Another Link"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber[600]),
                foregroundColor: MaterialStateProperty.all(Colors.black)),
          )
        ]);
        break;
    }
    return res;
  }

  Future<void> autoShorten() async {
    const String base62Chars =
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const startTime = 162114882782;
    longURL = longURLController.text;
    if (_longformkey.currentState.validate()) {
      var generator = (DateTime.now().millisecondsSinceEpoch ~/ 10) - startTime;
      print(generator);
      String firstChar = base62Chars[new Random().nextInt(9)];
      String mainChars = "";
      while (generator > 0) {
        mainChars += base62Chars[generator % 62];
        generator ~/= 62;
      }
      String randomChar = base62Chars[new Random().nextInt(61)];
      shortURL = firstChar + mainChars + randomChar;
      DatabaseService.addURL(
          context: context,
          longURL: longURL,
          shortURL: shortURL,
          custom: false,
          userID: user.uid,
          done: setStatusDone);
    }
  }

  setStatusDone() {
    currState = Status.DONE;
    setState(() {});
    Toast.show("URL Successfully Shortened", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
  }

  Future<void> customShorten() async {
    longURL = longURLController.text;
    if (_longformkey.currentState.validate() &&
        _shortformkey.currentState.validate()) {
      shortURL = shortURLController.text;
      if (await DatabaseService.urlExists(shortURL))
        Toast.show(
            "This URL is already in use, please try a different one", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      else {
        DatabaseService.addURL(
            context: context,
            longURL: longURL,
            shortURL: shortURL,
            custom: true,
            userID: user.uid,
            done: setStatusDone);
      }
    }
  }

  bool isNotValid(String url) {
    for (int i = 0; i < url.length; i++) {
      if (!url[i].contains(RegExp(r'[0-9A-Za-z]'))) return true;
    }
    return false;
  }
}
