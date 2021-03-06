import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_todo_app/database/note_db.dart';
import 'package:sqlite_todo_app/model/note_model.dart';
import 'package:sqlite_todo_app/screens/home_screen.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;
  final Function? updateNoteList;

  AddNoteScreen({Key? key, this.note, this.updateNoteList});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  String _title = '';
  String _priority = 'Low';
  DateTime _date = DateTime.now();
  String btnText = 'Add Note';
  String titleText = 'Add Note';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;

      setState(() {
        btnText = 'Update Note';
        titleText = 'Update Note';
      });
    } else {
      setState(() {
        btnText = 'Add Note';
        titleText = 'Add Note';
      });
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handlerDatePicker() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('$_title, $_date, $_priority');

      NoteModel note =
          NoteModel(title: _title, date: _date, priority: _priority);

      if (widget.note == null) {
        note.status = 0;
        NoteDB.instance.insertNote(note);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        NoteDB.instance.updateNote(note);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }

      widget.updateNoteList!();
    }
  }

  _delete() {
    NoteDB.instance.deleteNote(widget.note!.id!);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    widget.updateNoteList!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: GestureDetector(
        onTap: () {
          // to remove keyboard when click on screen
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      )),
                  child: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          child: TextFormField(
                            style: const TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              labelText: 'Add Note',
                              labelStyle: const TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            validator: (input) => input!.trim().isEmpty
                                ? 'Please enter a Note title'
                                : null,
                            onSaved: (input) => _title = input!,
                            initialValue: _title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            style: const TextStyle(fontSize: 18.0),
                            onTap: _handlerDatePicker,
                            decoration: InputDecoration(
                                labelText: 'Date',
                                labelStyle: const TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: DropdownButtonFormField(
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 20.0,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                  value: priority,
                                  child: Text(
                                    priority,
                                    style: const TextStyle(
                                        fontSize: 18.0, color: Colors.black),
                                  ));
                            }).toList(),
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: const TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            validator: (input) => _priority == null
                                ? 'Please select a Priority level'
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _priority = value.toString();
                              });
                            },
                            value: _priority,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                btnText,
                                style: const TextStyle(
                                    fontSize: 20.0, color: Colors.white),
                              )),
                        ),
                        widget.note != null
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 20.0),
                                height: 60.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: _delete,
                                  child: const Text(
                                    'Delete Note',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
