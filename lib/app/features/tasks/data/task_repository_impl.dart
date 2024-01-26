import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do/app/core/models/task.dart';

class TaskRepositoryImpl {
  late Database _database;
  final String _tableName = 'tasks';

  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo_database1.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
    debugPrint('Database path: $path');
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableName (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT,
      is_completed INTEGER,
      due_date TEXT
    )
  ''');
  }

  Future<List<Task>> getAllTasks() async {
    final List<Map<String, dynamic>> taskMaps =
        await _database.query(_tableName);
    return List.generate(taskMaps.length, (i) {
      return Task(
        id: taskMaps[i]['id'],
        title: taskMaps[i]['title'],
        description: taskMaps[i]['description'],
        isCompleted: taskMaps[i]['is_completed'] == 1,
        dueDate: DateTime.parse(taskMaps[i]['due_date']),
      );
    });
  }

  Future<Task?> getTaskById(int id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> map = maps.first;
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1,
      dueDate: DateTime.parse(map['due_date']),
    );
  }

  Future<void> addTask(Task newTask) async {
    final List<Map<String, dynamic>> result =
        await _database.rawQuery('SELECT MAX(id) as max_id FROM $_tableName');

    int newId = (result.first['max_id'] ?? 0) + 1;
    newTask = newTask.copyWith(id: newId);

    await _database.insert(
      _tableName,
      newTask.toJson(),
    );
  }

  Future<void> editTask(Task task) async {
    await _database.update(
      _tableName,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int taskId) async {
    await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> markTaskAsCompleted(int taskId) async {
    await _database.update(
      _tableName,
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> unmarkTaskAsCompleted(int taskId) async {
    await _database.update(
      _tableName,
      {'is_completed': 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}
