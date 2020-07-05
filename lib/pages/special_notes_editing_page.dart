import 'package:flutter/material.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/services/database.dart';

class SpecialNotesEditingPage extends StatefulWidget {
  String description;
  String category;
  SpecialNotesEditingPage({Key key,this.description,this.category}) : super(key: key);

  @override
  _SpecialNotesEditingPageState createState() => _SpecialNotesEditingPageState();
}

class _SpecialNotesEditingPageState extends State<SpecialNotesEditingPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String email;
  String noteTitle = "";
  var _value;


  createNotes(){
    if(titleController.text.isNotEmpty && descController.text.isNotEmpty){
      Map<String, dynamic> notesMap = {
        "title":titleController.text,
        "description":descController.text,
        "time":DateTime.now().millisecondsSinceEpoch,
        "category":_value,
        "important":"false"
      };

      databaseMethods.addNotes(notesMap:notesMap, notesRoomId: email, title: titleController.text);
    }
  }

  @override
  void initState() { 
    HelperFunction.getUserEmailFromSharedPreference().then((value){
      setState(() {
        email = value;
      });
    } );
    _value = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    descController.text = widget.description;

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
                    color: Theme.of(context).backgroundColor
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          titleController.text != "" ? noteTitle:"New Note",
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        ),
                        GestureDetector(
                          onTap:(){
                            print("Save Button Pressed");
                            createNotes();
                             Navigator.push(context, MaterialPageRoute(builder: (_)=> NotesDisplayPage(
                               title: titleController.text,
                               description: descController.text,
                               category: _value,
                             )));
                          },
                          child:Icon(
                            Icons.save,
                            color:Theme.of(context).indicatorColor
                          )
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    color:Theme.of(context).backgroundColor,
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
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                        controller: titleController,
                        onChanged: (string){
                          setState(() {
                            noteTitle = string;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "Enter Title",
                            hintStyle: TextStyle(
                                color: Theme.of(context).indicatorColor.withOpacity(0.5), fontSize: 18.0),
                            border: InputBorder.none),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText:'Enter Description',
                          hintStyle: TextStyle(
                            color:Theme.of(context).indicatorColor.withOpacity(0.5),
                            fontSize: 16.0
                          ),
                          border: InputBorder.none
                        ),
                        controller: descController,
                        style: TextStyle(color: Theme.of(context).indicatorColor.withOpacity(0.9), fontSize: 16.0),
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
              style:
                  TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold),
            ),
            value: "normal"),
        DropdownMenuItem(
            child: Text(
              "Work",
              style:
                  TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold),
            ),
            value: "work"),
        DropdownMenuItem(
            child: Text(
              "Special Notes",
              style:
                  TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold),
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
      style: TextStyle(color: Theme.of(context).indicatorColor, fontSize: 16.0),
      hint: Text(
        "Select category",
        style: TextStyle(color: Theme.of(context).indicatorColor),
      ),
      dropdownColor: Theme.of(context).backgroundColor,
    );
  }

}
