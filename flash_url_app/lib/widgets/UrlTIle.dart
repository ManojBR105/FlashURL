import 'package:flash_url_app/models/firebase.dart';
import 'package:flash_url_app/screens/dashboardscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class UrlTile extends StatelessWidget {
  final String url;
  final String baseURL = "https://flashurl.web.app/";
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
                  subtitle: data["url"] != null
                      ? Text(
                          data["url"],
                          maxLines: 2,
                        )
                      : Text("NaN"),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: "$baseURL$url"));
                    Toast.show("link copied to clipboard", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                  },
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardScrn(url)));
                  },
                );
        });
  }
}
