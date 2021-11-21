import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flash_url_app/models/firebase.dart';
import 'package:flash_url_app/screens/authenticatescreen.dart';
import 'package:flash_url_app/screens/homescreen.dart';

class Wrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    return (user != null) ? HomeScrn(user) : AuthenticateScrn();
  }
}
