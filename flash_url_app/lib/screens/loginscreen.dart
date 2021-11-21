import 'package:flutter/material.dart';
import 'package:flash_url_app/models/firebase.dart';
import 'package:flash_url_app/models/shared.dart';

class LogInScrn extends StatefulWidget {
  _LogInScrnState createState() => _LogInScrnState();
}

class _LogInScrnState extends State<LogInScrn> {
  final _formkey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Log In"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 30.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: inputdecoration.copyWith(hintText: 'Email'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (val) {
                  _email = val;
                },
              ),
              SizedBox(height: 30.0),
              TextFormField(
                obscureText: true,
                decoration: inputdecoration.copyWith(hintText: 'Password'),
                validator: (value) {
                  if (value.characters.length <= 6) {
                    return 'Password length should be atleast 6';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _password = val;
                  });
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () async {
                    if (_formkey.currentState.validate()) {
                      await Authenticate().signInWithEmailAndPassword(
                          _email, _password, context);
                    }
                  },
                  child: Text("Sign In"))
            ],
          ),
        ),
      ),
    );
  }
}
