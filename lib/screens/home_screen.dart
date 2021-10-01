import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_todo_app/database/note_db.dart';
import 'package:sqlite_todo_app/model/note_model.dart';

import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<NoteModel>> _noteList;

  final DateFormat _dateFormatter = DateFormat('MM dd, yyyy');
  final NoteDB _noteDB = NoteDB.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = NoteDB.instance.getNoteList();
  }

  Widget _buildNote(NoteModel note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              note.title!,
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  decoration: note.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            subtitle: Text(
              '${_dateFormatter.format(note.date!)} - ${note.priority}',
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
                value: note.status == 1 ? true : false,
                onChanged: (value) {
                  // print(value);
                  note.status = value! ? 1 : 0;
                  NoteDB.instance.updateNote(note);
                  _updateNoteList();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                activeColor: Theme.of(context).primaryColor),
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (_) => AddNoteScreen(
                        updateNoteList: _updateNoteList(), note: note))),
          ),
          const Divider(
            height: 5.0,
            color: Colors.deepPurple,
            thickness: 2.0,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (_) => AddNoteScreen(
                          updateNoteList: _updateNoteList(),
                        )));
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
            future: _noteList,
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final int completedNoteCount = snapshot.data!
                  .where((NoteModel note) => note.status == 1)
                  .toList()
                  .length;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 80.0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Notes',
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text('$completedNoteCount of ${snapshot.data.length}',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                              ))
                        ],
                      ),
                    );
                  }
                  return _buildNote(snapshot.data![index - 1]);
                },
                itemCount: int.parse(snapshot.data!.length.toString()) + 1,
              );
            }));
  }
}
