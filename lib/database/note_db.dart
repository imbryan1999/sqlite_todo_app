import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_todo_app/model/note_model.dart';

class NoteDB {
  static final NoteDB instance = NoteDB._instance();

  static Database? _db;

  NoteDB._instance();

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    final todoListDB =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDB;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(noteTable);
    return result;
  }

  Future<List<NoteModel>> getNoteList() async {
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();
    final List<NoteModel> noteList = [];
    noteMapList.forEach((noteMap) {
      noteList.add(NoteModel.fromMap(noteMap));
    });
    noteList.sort((noteA, noteB) => noteA.date!.compareTo(noteB.date!));
    return noteList;
  }

  Future<int> insertNote(NoteModel note) async {
    Database? db = await this.db;
    final int result = await db!.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(NoteModel note) async {
    Database? db = await this.db;
    final int result = await db!.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    final int result =
        await db!.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }
}

/* 
  
  This is how our note table will looks
  Id | Title | Date | Priority | Status
  0     ''      ''      ''          0
  1     ''      ''      ''          1 

  */
