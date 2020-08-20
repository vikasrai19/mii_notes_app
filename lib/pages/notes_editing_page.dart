import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/services/database.dart';

class NotesEditingPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;

  NotesEditingPage({
    Key key,
    this.title,
    this.description,
    this.category,
  }) : super(key: key);

  @override
  _NotesEditingPageState createState() => _NotesEditingPageState();
}

class _NotesEditingPageState extends State<NotesEditingPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String email;
  String noteTitle;
  String finalDescription;
  var _value;
  String uid;

  @override
  void dispose() {
    descController.dispose();
    super.dispose();
  }

  updateNotes() {
    if (titleController.text.isNotEmpty) {
      // List<String> searchStringList = List();
      // String temp = "";
      // for (var j = 0; j < titleController.text.length; j++) {
      //   temp = temp + titleController.text[j];
      //   searchStringList.add(temp);
      // }
      Map<String, dynamic> notesMap = {
        "title": titleController.text,
        "description": finalDescription,
        // "time": DateTime.now().millisecondsSinceEpoch,
        "category": _value
        // "searchTerm": searchStringList
      };
      print("Description is " + finalDescription);
      print("My uid is ");
      print(uid);

      databaseMethods.updateNotes(
          notesRoomId: uid,
          updateMap: notesMap,
          documentTitle: titleController.text);
    }
  }

  @override
  void initState() {
    HelperFunction.getUserUidFromSharedPreference().then((value) {
      setState(() {
        // userUid = value;
        uid = value;
      });
    });
    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        email = value;
      });
    });
    _value = widget.category;
    finalDescription = widget.description;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    noteTitle = widget.title != null ? widget.title : " ";
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    titleController.text = widget.title;

    // descController.text = widget.description;

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
                      color:
                          Theme.of(context).backgroundColor.withOpacity(0.8)),
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
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.60),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Text(
                                  titleController.text != ""
                                      ? noteTitle
                                      : "New Note",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.grenze(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              print("Save Button Pressed");
                              updateNotes();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => NotesDisplayPage(
                                            title: titleController.text,
                                            description: finalDescription,
                                            category: _value,
                                          )));
                            },
                            child: Container(
                              height: 40.0,
                              width: 40.0,
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
                            titleController.text = string;
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
                      TextFormField(
                        initialValue: widget.description,
                        toolbarOptions:
                            ToolbarOptions(copy: true, cut: true, paste: true),
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (string) {
                          setState(() {
                            finalDescription = string;
                          });
                          print(finalDescription);
                        },
                        decoration: InputDecoration(
                            hintText: 'Enter Description',
                            hintStyle: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.5),
                                fontSize: 16.0),
                            border: InputBorder.none),
                        // controller: descController,
                        style: GoogleFonts.montserrat(
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
        DropdownMenuItem(
            child: Text(
              "Special Notes",
              style: GoogleFonts.montserrat(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.bold),
            ),
            value: "special_notes"),
      ],
      onChanged: (value) {
        setState(() {
          _value = value;
          print(_value);
        });
      },
      value: _value,
      style: GoogleFonts.montserrat(
          color: Theme.of(context).backgroundColor, fontSize: 14.0),
      hint: Text(
        "Select category",
        style: GoogleFonts.montserrat(
            color: Theme.of(context).indicatorColor.withOpacity(0.7)),
      ),
      dropdownColor: Theme.of(context).backgroundColor,
    );
  }
}
