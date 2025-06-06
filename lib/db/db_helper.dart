import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'database.dart'; // Your Drift database
import '../models/task.dart' as legacy_task_model; // Legacy Task model

class DBHelper {
  // Static instance of the Drift database
  static final AppDatabase _db = AppDatabase();

  // Helper to convert legacy Task to TasksCompanion for insert/update
  static TasksCompanion _toCompanion(legacy_task_model.Task task) {
    return TasksCompanion(
      id: task.id == null ? const Value.absent() : Value(task.id!),
      title: Value(task.title),
      note: Value(task.note),
      isCompleted: Value(task.isCompleted == 1),
      date: Value(task.date),
      startTime: Value(task.startTime),
      endTime: Value(task.endTime),
      color: Value(task.color),
      remind: Value(task.remind),
      repeat: Value(task.repeat),
    );
  }

  // Helper to convert Drift's Task to legacy Task model
  static legacy_task_model.Task _fromDriftTask(Task driftTask) { // Changed TaskData to Task
    return legacy_task_model.Task(
      id: driftTask.id,
      title: driftTask.title,
      note: driftTask.note,
      isCompleted: driftTask.isCompleted == true ? 1 : 0,
      date: driftTask.date,
      startTime: driftTask.startTime,
      endTime: driftTask.endTime,
      color: driftTask.color,
      remind: driftTask.remind,
      repeat: driftTask.repeat,
    );
  }

  static Future<int> insert(legacy_task_model.Task? task) async {
    if (task == null) {
      debugPrint('Task is null');
      return -1;
    }
    debugPrint('insert function called - Drift');
    try {
      final companion = _toCompanion(task);
      final insertedTask = await _db.into(_db.tasks).insertReturning(companion, mode: InsertMode.insertOrReplace);
      return insertedTask.id; // Return the id of the inserted row
    } catch (e) {
      debugPrint('Error inserting task with Drift: $e');
      return -1;
    }
  }

  static Future<int> delete(legacy_task_model.Task task) async {
    debugPrint('delete function called - Drift');
    if (task.id == null) return -1;
    try {
      return await (_db.delete(_db.tasks)..where((tbl) => tbl.id.equals(task.id!))).go();
    } catch (e) {
      debugPrint('Error deleting task with Drift: $e');
      return -1;
    }
  }

  static Future<int> deleteAll() async {
    debugPrint('deleteAll function called - Drift');
    try {
      return await _db.delete(_db.tasks).go();
    } catch (e) {
      debugPrint('Error deleting all tasks with Drift: $e');
      return -1;
    }
  }

  // Returns List<Map<String, dynamic>> to maintain compatibility for now
  // Ideally, TaskController would be updated to expect List<legacy_task_model.Task>
  static Future<List<Map<String, dynamic>>> query() async {
    debugPrint('Query Called - Drift');
    try {
      final driftTasks = await _db.select(_db.tasks).get();
      // Convert Drift TaskData to Map<String, dynamic> for compatibility
      return driftTasks.map((dt) => _fromDriftTask(dt).toJson()).toList();
    } catch (e) {
      debugPrint('Error querying database with Drift: $e');
      return [];
    }
  }

  // Returns List<Map<String, dynamic>> for compatibility
  static Future<List<Map<String, dynamic>>> queryByDate(String date) async {
    debugPrint('Query by date: $date - Drift');
    try {
      final driftTasks = await (_db.select(_db.tasks)..where((tbl) => tbl.date.equals(date))).get();
      return driftTasks.map((dt) => _fromDriftTask(dt).toJson()).toList();
    } catch (e) {
      debugPrint('Error querying by date with Drift: $e');
      return [];
    }
  }

  static Future<int> update(int id) async {
    debugPrint('update function called (mark as complete) - Drift');
    try {
      return await (_db.update(_db.tasks)..where((tbl) => tbl.id.equals(id)))
          .write(const TasksCompanion(isCompleted: Value(true)));
    } catch (e) {
      debugPrint('Error updating task with Drift: $e');
      return -1;
    }
  }
}

