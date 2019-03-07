import 'package:flutter/material.dart';
import 'routes.dart';

class SampleAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text(""),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        ),
        ListTile(
          title: Text("Main Screen"),
          onTap: () => Navigator.pushReplacementNamed(context, Routes.MainPage),
        ),
        ListTile(
          title: Text("SQLite Monitor"),
          onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.SQLiteMonitorPage),
        ),
        ListTile(
          title: Text("Http Monitor"),
          onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.HttpMonitorPage),
        ),
      ],
    ));
  }
}
