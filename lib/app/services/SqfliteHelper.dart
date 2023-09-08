import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteHelper{
  final sqFileName = "myfanxing.sql";
  final table = "fx_food";
   Database? db;
  open() async {
    String path = "${await getDatabasesPath()}/$sqFileName";
    if(db == null){
      db = await openDatabase(path, version: 1,onCreate: (db,ver) async {
        await db.execute('''
        CREATE TABLE fx_food(
        userId integer,
        id integer PRIMARY KEY,
        title TEXT,
        body TEXT
        );
        ''');
      });
    }
  }

  insert(Map<String, dynamic> m) async{
    //插入冲突策略，新的替换旧的 conflictAlgorithm: ConflictAlgorithm.replace
    return await db?.insert(table, m, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  queryAll() async {
    return await db?.query(table, columns: null);
  }

  queryone(int id) async {
    return await db?.query(table, columns: null, where: "id=$id");
  }

  delete(int id) async{
    return await db?.delete(table,where: "id=$id");
  }

}