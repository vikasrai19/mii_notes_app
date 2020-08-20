import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/common_widgets/functions.dart';
import 'package:notes_app/common_widgets/widgtes.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/services/database.dart';

class SpecialNotesCreationPage extends StatefulWidget {
  final String description;
  final String category;
  final String uid;
  SpecialNotesCreationPage({Key key, this.description, this.category, this.uid})
      : super(key: key);

  @override
  _SpecialNotesCreationPageState createState() =>
      _SpecialNotesCreationPageState();
}

class _SpecialNotesCreationPageState extends State<SpecialNotesCreationPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String email;
  String noteTitle = "";
  var _value;
  String finalDescription;
  bool isEdited = true;

  @override
  void initState() {
    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        email = value;
      });
    });
    _value = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // descController.text = widget.description;
    finalDescription = widget.description;

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
                  decoration:
                      BoxDecoration(color: Theme.of(context).backgroundColor),
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
                                  backNotifierAlert(
                                    context,
                                    isEdited: isEdited,
                                    title: titleController.text,
                                    desc: finalDescription,
                                    value: _value,
                                    index: 2,
                                    uid:widget.uid,
                                    // createNotes: createNotes()
                                  );
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
                                      fontSize: 22.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              print("Save Button Pressed");
                              createSpecialNotes(
                                  title: titleController.text,
                                  desc: finalDescription,
                                  uid: widget.uid,
                                  value: _value);
                              Navigator.push(
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
                                child: Icon(Icons.save, color: Colors.white)))
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
                      TextFormField(
                        initialValue: widget.description,
                        onChanged: (string) {
                          setState(() {
                            finalDescription = string;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: 'Enter Description',
                            hintStyle: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.5),
                                fontSize: 16.0),
                            border: InputBorder.none),
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
        // DropdownMenuItem(
        //     child: Text(
        //       "Normal",
        //       style: TextStyle(
        //           color: Theme.of(context).indicatorColor,
        //           fontWeight: FontWeight.bold),
        //     ),
        //     value: "normal"),
        // DropdownMenuItem(
        //     child: Text(
        //       "Work",
        //       style: TextStyle(
        //           color: Theme.of(context).indicatorColor,
        //           fontWeight: FontWeight.bold),
        //     ),
        //     value: "work"),
        DropdownMenuItem(
            child: Text("Special Notes",
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).indicatorColor,
                  fontWeight: FontWeight.bold,
                )),
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
          color: Theme.of(context).indicatorColor, fontSize: 14.0),
      hint: Text(
        "Select category",
        style: GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
      ),
      dropdownColor: Theme.of(context).backgroundColor,
    );
  }
}
