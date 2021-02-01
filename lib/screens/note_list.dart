import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

// ignore: must_be_immutable
class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToPage(Note('', '', 2), "Add Note");
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    gerPriorityColor(this.noteList[position].priority),
                child: gerPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
              ),
              subtitle: Text(
                this.noteList[position].date,
              ),
              trailing: GestureDetector(
                onTap: () {
                  _delete(context, noteList[position]);
                },
                child: Icon(
                  Icons.delete,
                  //color: Colors.red[400],
                ),
              ),
              onTap: () {
                navigateToPage(this.noteList[position], "Edit Note");
              },
            ),
          );
        });
  }

  Color gerPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon gerPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.keyboard_arrow_right, color: Colors.white);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right, color: Colors.black);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right, color: Colors.black);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted");
      updateListView();
    }
  }

  void navigateToPage(Note note, String title) async {
    bool res = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (res == true) {
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.blue[400],
      content: Text(
        message,
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
