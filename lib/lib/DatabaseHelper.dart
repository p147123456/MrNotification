


import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

abstract class DatabaseHelper {
  final String _databaseName = "app.db";
  sqlite.Database _database;

  String get localdbName ;

  String _dbPath ;

  //region 設定類
   _initDBPath() async
   {
     var dbDir = await sqlite.getDatabasesPath();
     _dbPath = join(dbDir, _databaseName);
   }

  Future<bool>_copyDB({bool isCheckFileExist = false }) async
  {
    try {
      //是否要檢查檔案存在,如果存在就不copy
      if( isCheckFileExist ){
        if( await File(_dbPath).exists()) return false  ;
      }

      await sqlite.deleteDatabase(_dbPath);

      ByteData data = await rootBundle.load(localdbName);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(_dbPath).writeAsBytes(bytes);
      return true ;
    }
    catch(e)
    {
      print(e.toString()) ;
      return false ;
    }
  }

  initDB(int dbversion) async
  {
    try {
      await _initDBPath() ;

      //如果DB不存在,那就Copy
      await _openDB(dbversion,newDbFile:await _copyDB(isCheckFileExist: true));
      if( _database == null ) return ;

      //檢查版本設定
      if( await _checkVersion(dbversion) ) return ;
      await closeDB();

      await _openDB(dbversion,newDbFile : await _copyDB());


    }
    catch(e)
    {

    }
  }

  _openDB(int dbversion,{bool newDbFile=false}) async
  {
    try {

      _database = await sqlite.openDatabase(_dbPath,version: 1,
        onCreate: (sqlite.Database db, int version) async {
          // 表格建立等初始化操作
          //_copyDB() ;
        },
        onUpgrade: (sqlite.Database db, int oldVersion, int newVersion) async {
          // 資料庫升級
          //_copyDB() ;
        },);

      if( newDbFile ) {
        //入寫版本資訊
        _database.execute('CREATE TABLE version (ver INTEGER)');
        insertRecord("version", {
          'ver': dbversion,
        }) ;
      }
    }
    catch(e)
    {
      print("Exception:" + e.toString()) ;

    }
  }

  closeDB() async
  {
    closeDB();
  }

  Future<bool> _checkVersion( int v) async
  {
    try{
      List<Map<String, dynamic>> lst = await this.queryAll("version") ;
      if( lst == null || lst.length == 0 ) return false ;
      int vv = lst[0]["ver"] ;
      if( vv != v ) return false ;
      return true ;
    }
    catch(e){
      return false ;
    }

  }
  //endregion

  // Future<int> insertRecord(String table,Map<String, dynamic> row) async
  // {
  //   if( _database == null ) return 0 ;
  //
  //   return await _database.insert(table, row);
  // }

  //查某個表有多少紀錄
  Future<int> queryCount(String table) async {

     try {
       if (_database == null) return 0;

       return sqlite.Sqflite.firstIntValue(
           await _database.rawQuery('SELECT COUNT(*) FROM $table'));
     }
     catch(e)
    {
      print("queryCount:" + e.toString()) ;
      return 0 ;
    }

  }

  //查某個表的全部記錄
  Future<List<Map<String, dynamic>>> queryAll(String table) async
  {
    if( _database == null ) return null ;

    return _queryRecord(table);
  }

  //根據條件查某個表的記錄
  Future<List<Map<String, dynamic>>> query(String table,String where,List<dynamic> whereArgs) async
  {
    if( _database == null ) return null ;

    return _queryRecord(table,where: where,whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> _queryRecord(String table,{String where,List<dynamic> whereArgs}) async
  {
    try {
      if (_database == null) return null;

      if (where == null || where.isNotEmpty|| whereArgs==null ) {
        return await _database.query(table);
      }

      return _database.query(table,where:where,whereArgs: whereArgs); ;
    }
    catch(e)
    {
      print("_queryRecord:" + e.toString()) ;
      return null ;
    }
  }

  Future<int> insertRecord(String table,Map<String, dynamic> row,{String where,List<dynamic> whereArgs}) async
  {
    try {
      if (_database == null) return 0;

      if (where != null && where.isNotEmpty && whereArgs != null) {
        //比對是否存在,
        List<Map<String, dynamic>> lst = await query(table, where, whereArgs) ;
        if ( lst != null && lst.length > 0 ) {
          return updateRecord(table, row, where, whereArgs);
        }
      }

      return await _database.insert(table, row);
    }
    catch(e)
    {
      print("insertRecord:" + e.toString()) ;
      return 0 ;
    }
  }


  Future<int> updateRecord(String table,Map<String, dynamic> row,String where,List<dynamic> whereArgs) async
  {
    try {
      if (_database == null) return 0;

      return await _database.update(
          table, row, where: where, whereArgs: whereArgs);
    }
    catch(e)
    {
      print("updateRecord:" + e.toString()) ;
      return 0 ;
    }
  }

  //根據條件查某個表的記錄
  Future<int> deleteRecord(String table,String where,List<dynamic> whereArgs) async
  {
    try {
      if (_database == null) return 0;

      return _database.delete(table, where: where, whereArgs: whereArgs);
    }
    catch(e)
    {
      print('deleteRecord : ' + e.toString()) ;
      return 0 ;
    }
  }


  Future<int> deleteAll(String table) async
  {
    if( _database == null ) return 0 ;

    return await _database.delete(table);
  }
  // Future<int> insert(String table,Map<String, dynamic> row) async
  // {
  //   if( _database == null ) return 0 ;
  //
  //   return await _database.insert(table, row);
  // }
  //
  //
  //
  // Future<int> update(String table,Map<String, dynamic> row) async
  // {
  //   if( _database == null ) return 0 ;
  //
  //   int id = row['id'];
  //   return await _database.update(table, row, where: 'id = ?', whereArgs: [id]);
  // }
  //
  // Future<int> delete(String table,int id) async
  // {
  //   if( _database == null ) return 0 ;
  //
  //   return await _database.delete(table, where: 'id = ?', whereArgs: [id]);
  // }
  //
  //
  // Future<List<Map<String, dynamic>>> queryAllRows(String table) async
  // {
  //   if( _database == null ) return null ;
  //
  //   return await _database.query(table);
  // }
  //
  //
  // Future<int> queryRowCount(String table) async {
  //   if( _database == null ) return 0 ;
  //
  //   return sqlite.Sqflite.firstIntValue(
  //       await _database.rawQuery('SELECT COUNT(*) FROM $table'));
  // }
}


