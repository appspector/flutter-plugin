import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'record.dart';

abstract class RecordStorage {
  void save(Record record);
}

class RecordStorageImpl implements RecordStorage {
  static Database _db;
  static const _tableName = "records";
  static const _columnId = "id";
  static const _columnName = "name";
  static const _columnAddress = "address";
  static const _columnPhone = "phone";

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, "test.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE $_tableName ($_columnId INTEGER PRIMARY KEY, $_columnName TEXT, $_columnAddress TEXT, $_columnPhone TEXT)");
    debugPrint("Created tables");
  }

  @override
  void save(Record record) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return txn.insert(_tableName, _recordToMap(record));
    });
    debugPrint("Record is written: $record");
  }

  _recordToMap(Record record) {
    final dict = Map<String, dynamic>();
    dict[_columnName] = record.name;
    dict[_columnAddress] = record.address;
    dict[_columnPhone] = record.phone;
    return dict;
  }
}
