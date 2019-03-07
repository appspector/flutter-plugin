import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'sqlite/storage.dart';
import 'sqlite/record.dart';

class SQLitePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => SQLitePageState();

}

class SQLitePageState extends State<SQLitePage> {

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storage = RecordStorageImpl();

  var _nameIsValid = false;
  var _addressIsValid = false;
  var _phoneIsValid = false;
  var _saveButtonEnable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("SQLite Monitor"),
        ),
        drawer: SampleAppDrawer(),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    keyboardType: TextInputType.text,
                    onChanged: _onNameChanged,
                    autofocus: true,
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: "Address"),
                    keyboardType: TextInputType.text,
                    onChanged: _onAddressChanged,
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                    onChanged: _onPhoneChanged,
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 24.0),
                      child: RaisedButton(
                          child: Text("Add"),
                          onPressed: _saveButtonEnable ? _onSave : null
                      )
                  ),
                ]
            )
        )
    );
  }

  _onNameChanged(String text) {
    _nameIsValid = text.isNotEmpty;
    _changeButtonState();
  }

  _onAddressChanged(String text) {
    _addressIsValid = text.isNotEmpty;
    _changeButtonState();
  }

  _onPhoneChanged(String text) {
    _phoneIsValid = text.isNotEmpty;
    _changeButtonState();
  }

  _changeButtonState() {
    setState(() {
      _saveButtonEnable = _nameIsValid && _addressIsValid && _phoneIsValid;
    });
  }

  _onSave() {
    final name = _nameController.text;
    final address = _addressController.text;
    final phone = _phoneController.text;
    _storage.save(Record(name, address, phone));
    setState(() {
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
    });
    debugPrint("Saving record");
  }
}
