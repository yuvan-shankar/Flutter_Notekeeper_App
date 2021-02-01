import 'package:flutter/material.dart';

import 'package:notekeeper/models/note.dart';

import 'package:notekeeper/utils/database_helper.dart';

import 'package:intl/intl.dart';

// ignore: must_be_immutable
class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() =>
      _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  _NoteDetailState(this.note, this.appBarTitle);

  static var _priorities = ["High", "Low"];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController titleContol = TextEditingController();
  TextEditingController descriptionContol = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleContol.text = note.title;
    descriptionContol.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            top: 15.0,
            left: 10.0,
            right: 10.0,
          ),
          child: ListView(
            children: [
              SizedBox(height: 30.0),
              TextFormField(
                controller: titleContol,
                validator: (value) {
                  if (value.length == 0) {
                    return "Title must have at least one character";
                  } else if (value.length > 255) {
                    return "Title should be with in 255 character";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              TextFormField(
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value.length == 0) {
                    return "Description must have at least one character";
                  } else if (value.length > 255) {
                    return "Description should be with in 255 character";
                  } else {
                    return null;
                  }
                },
                maxLines: null,
                controller: descriptionContol,
                onChanged: (value) {
                  updateDescription();
                },
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              ListTile(
                title: DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.0),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  items: _priorities.map((String dropDownItem) {
                    return DropdownMenuItem(
                      value: dropDownItem,
                      child: Text(dropDownItem),
                    );
                  }).toList(),
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelected) {
                    setState(() {
                      updatePriorityAsInt(valueSelected);
                    });
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        _save();
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 19.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 5.0),
                  Expanded(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.red,
                      onPressed: () {
                        _delete();
                      },
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 19.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleContol.text;
  }

  void updateDescription() {
    note.description = descriptionContol.text;
  }

  void _save() async {
    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      Navigator.pop(context, true);
      _showAlertDialog('Status', 'Note Saved');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    if (note.id == null) {
      _showAlertDialog("Status", "No Note Created Yet");
      return;
    }
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      Navigator.pop(context, true);
      _showAlertDialog('Status', 'Note Deleted.');
    } else {
      _showAlertDialog('Status', 'Problem Deleting Note');
    }
  }

  void _showAlertDialog(String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
