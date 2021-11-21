import 'package:flash_url_app/models/shared.dart';
import 'package:flutter/material.dart';
import 'package:flash_url_app/models/firebase.dart';

class RegisterScrn extends StatefulWidget {
  _RegisterScrnState createState() => _RegisterScrnState();
}

class _RegisterScrnState extends State<RegisterScrn> {
  final _formkey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Register",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber[600],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 30.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: inputdecoration.copyWith(hintText: 'Username'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (val) {
                  _username = val;
                },
              ),
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.amber[600]),
                      foregroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () async {
                    if (_formkey.currentState.validate()) {
                      await Authenticate().registerWithEmailAndPassword(
                          _email, _password, _username, context);
                    }
                  },
                  child: Text("Sign Up"))
            ],
          ),
        ),
      ),
    );
  }
}
