import 'package:flash_url_app/models/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flash_url_app/screens/loginscreen.dart';
import 'package:flash_url_app/screens/registerscreen.dart';

class AuthenticateScrn extends StatefulWidget {
  @override
  _AuthenticateScrnState createState() => _AuthenticateScrnState();
}

class _AuthenticateScrnState extends State<AuthenticateScrn> {
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.redAccent[700],
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image(
                width: 300,
                image: AssetImage("images/logo.png"),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Flash URL",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontSize: 40,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "url shortening in a flash",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await Authenticate().anonymousSignIn(context);
                  },
                  child: Text("Use As Guest"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.black))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScrn()));
                  },
                  child: Text("Register"),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.amber[600]),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.grey[900]))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LogInScrn()));
                  },
                  child: Text("Log In"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.grey[100])))
            ],
          ),
        ));
  }
}
