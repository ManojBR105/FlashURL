import 'package:flash_url_app/models/firebase.dart';
import 'package:flutter/material.dart';

class DashboardScrn extends StatefulWidget {
  final String url;
  DashboardScrn(this.url);
  @override
  _DashboardScrnState createState() => _DashboardScrnState();
}

class _DashboardScrnState extends State<DashboardScrn> {
  bool toggle = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        title:
            Text(widget.url), // : " + (toggle ? "Plain" : "Graph") + " View"),
      ),
      body: toggle ? PlainView(widget.url) : Container(),
      //floatingActionButton: FloatingActionButton(
      // backgroundColor: Colors.redAccent[700],
      // child: toggle ? Icon(Icons.grain_sharp) : Icon(Icons.filter_1_sharp),
      // onPressed: () {
      //   toggle = !toggle;
      //   setState(() {});
      // },
      //),
    );
  }
}

class PlainView extends StatefulWidget {
  final String url;
  PlainView(this.url);
  @override
  _PlainViewState createState() => _PlainViewState();
}

class _PlainViewState extends State<PlainView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: DatabaseService.urlData(widget.url),
        builder: (context, snapshot) {
          Map<dynamic, dynamic> data = snapshot.data;
          return data == null
              ? Container()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Total Count",
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Text(data["count"].toString(),
                            style: TextStyle(color: Colors.white)),
                        tileColor: Colors.black,
                      ),
                      dashboardCell(data, "device"),
                      dashboardCell(data, "country"),
                      dashboardCell(data, "platform"),
                      dashboardCell(data, "browser"),
                    ],
                  ),
                );
        });
  }

  Widget dashboardCell(Map<dynamic, dynamic> urlData, String key) {
    Map<dynamic, dynamic> _data = urlData["$key"];
    List<Widget> rows = [];
    TextStyle myStyle = TextStyle(
        fontSize: 16, letterSpacing: 1.25, fontWeight: FontWeight.bold);
    _data.forEach((key, value) {
      rows.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key.toString(),
              style: myStyle,
            ),
            Text(
              value.toString(),
              style: myStyle,
            )
          ],
        ),
      ));
    });
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
              ListTile(
                  tileColor: Colors.amber,
                  title: Text(
                    key[0].toUpperCase() + key.substring(1),
                  ))
            ] +
            rows +
            [
              SizedBox(
                height: 5,
                child: Container(
                  color: Colors.amber,
                ),
              )
            ],
      ),
    );
  }
}
