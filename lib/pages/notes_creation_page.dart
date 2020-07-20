import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/services/database.dart';

class NotesCreatorPage extends StatefulWidget {
  NotesCreatorPage({Key key}) : super(key: key);

  @override
  _NotesCreatorPageState createState() => _NotesCreatorPageState();
}

class _NotesCreatorPageState extends State<NotesCreatorPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String noteTitle = "";
  String email;
  var _value;

  createNotes() {
    if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
      List<String> searchStringList = List();
      String temp = "";
      for (var j = 0; j < titleController.text.length; j++) {
        temp = temp + titleController.text[j];
        searchStringList.add(temp);
      }
      Map<String, dynamic> notesMap = {
        "title": titleController.text,
        "description": descController.text,
        "time": DateTime.now().millisecondsSinceEpoch,
        "category": _value,
        "important": "false",
        "searchTerm": searchStringList
      };

      databaseMethods.addNotes(
          notesMap: notesMap, notesRoomId: email, title: titleController.text);
    }
  }

  @override
  void initState() {
    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        email = value;
      });
    });
    super.initState();
    print(_value);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          height: screenHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.08,
                  width: screenWidth,
                  decoration: BoxDecoration(
//                    color: Color(0xFFF5F7FB),
                      color: Theme.of(context).indicatorColor.withAlpha(2)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 50.0,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 0.0),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                  offset: Offset(2, 2),
                                  blurRadius: 2.0,
                                  spreadRadius: 1.0)
                            ],
                            borderRadius: BorderRadius.circular(25.0),
                            gradient: LinearGradient(
                                colors: [Color(0xff1f5cfc), Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.arrow_back,
                                        color: Theme.of(context).primaryColor)),
                              ),
                              Container(
                                constraints:
                                    BoxConstraints(maxWidth: screenWidth * 0.6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Text(
                                  titleController.text != ""
                                      ? noteTitle
                                      : "New Note",
                                  style: GoogleFonts.grenze(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              print("Save Button Pressed");
                              if (_value != null) {
                                createNotes();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => NotesDisplayPage(
                                              title: titleController.text,
                                              description: descController.text,
                                              category: _value,
                                            )));
                              } else {
                                alertDialog();
                              }
                            },
                            child: Container(
                              height: 40.0,
                              width: 40,
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.5),
                                      offset: Offset(2, 2),
                                      blurRadius: 2.0,
                                      spreadRadius: 1.0)
                                ],
                                borderRadius: BorderRadius.circular(20.0),
                                gradient: LinearGradient(
                                    colors: [Color(0xff1f5cfc), Colors.blue],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                              ),
                              child: Icon(Icons.save, color: Colors.white),
                            ))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    height: 50.0,
                    width: screenWidth * 0.40,
                    child: dropDownButton(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                        controller: titleController,
                        onChanged: (string) {
                          setState(() {
                            noteTitle = string;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "Enter Title",
                            hintStyle: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.5),
                                fontSize: 18.0),
                            border: InputBorder.none),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                            hintText: 'Enter Description',
                            hintStyle: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.5),
                                fontSize: 16.0),
                            border: InputBorder.none),
                        controller: descController,
                        style: TextStyle(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.9),
                            fontSize: 16.0),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dropDownButton() {
    return DropdownButton(
      items: [
        DropdownMenuItem(
            child: Text(
              "Normal",
              style: GoogleFonts.montserrat(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.bold),
            ),
            value: "normal"),
        DropdownMenuItem(
            child: Text(
              "Work",
              style: GoogleFonts.montserrat(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.bold),
            ),
            value: "work"),
        // DropdownMenuItem(
        //     child: Text(
        //       "Special Notes",
        //       style: TextStyle(
        //           color: Theme.of(context).indicatorColor,
        //           fontWeight: FontWeight.bold),
        //     ),
        //     value: "special_notes"),
      ],
      onChanged: (value) {
        setState(() {
          _value = value;
          print(_value);
        });
      },
      value: _value,
      style: GoogleFonts.montserrat(
          color: Theme.of(context).indicatorColor, fontSize: 14.0),
      hint: Text(
        "Select category",
        style: GoogleFonts.montserrat(
            color: Theme.of(context).indicatorColor.withOpacity(0.5)),
      ),
      dropdownColor: Theme.of(context).backgroundColor,
    );
  }

  alertDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Warning",
              style: GoogleFonts.montserrat(color: Colors.black),
            ),
            content: Text(
              'Select a category type',
              style: GoogleFonts.montserrat(color: Colors.black),
            ),
            actions: [
              FlatButton(
                child: Text('Ok',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            elevation: 10.0,
            backgroundColor: Colors.white,
          );
        });
  }
}
