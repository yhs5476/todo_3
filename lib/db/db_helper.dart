import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('db not null');
      return;
    }
    try {
      String path = '${await getDatabasesPath()}/task.db';
      debugPrint('Database path: $path');
      _db = await openDatabase(path, version: _version,
          onCreate: (Database db, int version) async {
        debugPrint('Creating new one');
        // When creating the db, create the table
        return db.execute('CREATE TABLE $_tableName ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, note TEXT, date STRING, '
            'startTime STRING, endTime STRING, '
            'remind INTEGER, repeat STRING, '
            'color INTEGER, '
            'isCompleted INTEGER)');
      });
      print('DB Created');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  static Future<int> insert(Task? task) async {
    print('insert function called');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
        
        // 초기화 후에도 데이터베이스가 null인지 확인
        if (_db == null) {
          print('Database initialization failed');
          return -1;
        }
      }
      
      // 태스크가 null인지 확인
      if (task == null) {
        print('Task is null');
        return -1;
      }
      
      // 데이터베이스에 삽입
      int result = await _db!.insert(_tableName, task.toJson());
      print('Task inserted successfully with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting task: $e');
      return -1; // 오류 발생 시 -1 반환
    }
  }

  static Future<int> delete(Task task) async {
    print('delete function called');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
        
        // 초기화 후에도 데이터베이스가 null인지 확인
        if (_db == null) {
          print('Database initialization failed');
          return -1;
        }
      }
      
      return await _db!.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print('Error deleting task: $e');
      return -1;
    }
  }

  static Future<int> deleteAll() async {
    print('deleteAll function called');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
        
        // 초기화 후에도 데이터베이스가 null인지 확인
        if (_db == null) {
          print('Database initialization failed');
          return -1;
        }
      }
      
      return await _db!.delete(_tableName);
    } catch (e) {
      print('Error deleting all tasks: $e');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print('Query Called!!!!!!!!!!!!!!!!!!!');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
        
        // 초기화 후에도 데이터베이스가 null인지 확인
        if (_db == null) {
          print('Database initialization failed');
          return [];
        }
      }
      
      return await _db!.query(_tableName);
    } catch (e) {
      print('Error querying database: $e');
      return [];
    }
  }
  
  // 특정 날짜의 할일만 쿼리하는 메소드
  static Future<List<Map<String, dynamic>>> queryByDate(String date) async {
    print('Query by date: $date');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
        
        // 초기화 후에도 데이터베이스가 null인지 확인
        if (_db == null) {
          print('Database initialization failed');
          return [];
        }
      }
      
      return await _db!.query(
        _tableName,
        where: 'date = ?',
        whereArgs: [date],
      );
    } catch (e) {
      print('Error querying by date: $e');
      return [];
    }
  }

  static Future<int> update(int id) async {
    print('update function called');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
        
        // 초기화 후에도 데이터베이스가 null인지 확인
        if (_db == null) {
          print('Database initialization failed');
          return -1;
        }
      }
      
      return await _db!.rawUpdate('''
      UPDATE tasks
      SET isCompleted = ?
      WHERE id = ?
      ''', [1, id]);
    } catch (e) {
      print('Error updating task: $e');
      return -1;
    }
  }
}
