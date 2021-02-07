import 'package:appspector/appspector.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';

class MetadataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MetadataPageState();
}

class MetadataPageState extends State<MetadataPage> {

  var _deviceNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Metadata"),
        ),
        drawer: SampleAppDrawer(),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
                children: [
                  TextField(
                    controller: _deviceNameController,
                    decoration: InputDecoration(labelText: "Device Name"),
                    keyboardType: TextInputType.text,
                    maxLength: 50,
                    onEditingComplete: _deviceNameChanged,
                    autofocus: true,
                  )
                ]
            )
        )
    );
  }

  void _deviceNameChanged() {
    var newDeviceName = _deviceNameController.text;
    if (newDeviceName.isNotEmpty) {
      AppSpectorPlugin.shared().setMetadataValue(MetadataKeys.deviceName, newDeviceName);
    } else {
      AppSpectorPlugin.shared().removeMetadataValue(MetadataKeys.deviceName);
    }
  }
}
