import 'package:flash_url_app/models/firebase.dart';
import 'package:flutter/material.dart';

class UrlTile extends StatelessWidget {
  final String url;
  UrlTile(this.url);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: DatabaseService.urlData(url),
        builder: (context, snapshot) {
          Map<dynamic, dynamic> data = snapshot.data;
          return data == null
              ? Container()
              : ListTile(
                  title: Text(url),
                  trailing: data["count"] != null
                      ? Text(data["count"].toString())
                      : Text("NaN"),
                  subtitle:
                      data["url"] != null ? Text(data["url"]) : Text("NaN"),
                );
        });
  }
}
