import 'dart:io';

import 'package:db/model/businessModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'map_list.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE BUSINESS('
          'id INTEGER PRIMARY KEY,'
          'businessStatus TEXT,'
          'name TEXT,'
          'icon TEXT,'
          'place_id TEXT,'
          'scope TEXT,'
          'vicinity TEXT,'
          'lat DOUBLE,'
          'long DOUBLE'
          ')');
    });
  }

  createBusiness(BusinessModel business) async {
    print(business);
    final db = await database;
    final res = await db.insert('BUSINESS', business.toJson());
    return res;
  }

  Future<List<BusinessModel>> getAllBusiness() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM BUSINESS");

    List<BusinessModel> list =
        res.isNotEmpty ? res.map((c) => BusinessModel.fromJson(c)).toList() : [];

    return list;
  }
}
