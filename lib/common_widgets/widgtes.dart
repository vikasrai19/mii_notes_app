import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/common_widgets/functions.dart';
import 'package:notes_app/pages/homepage.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/pages/special_notes_display.dart';

Future backNotifierAlert(BuildContext context,
    {String title,
    String desc,
    var value,
    int index,
    bool isEdited,
    String uid}) {
  if (isEdited) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Warning",
              style: GoogleFonts.montserrat(color: Colors.black),
            ),
            content: Text(
              'You have some unsved changes',
              style: GoogleFonts.montserrat(color: Colors.black),
            ),
            actions: [
              FlatButton(
                child: Text('quit',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Save',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
                onPressed: () {
                  if (value != null) {
                    if (index == 1) {
                      createNotes(
                          title: title, desc: desc, value: value, uid: uid);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => HomePage(index:1)));
                    } else if (index == 2) {
                      createSpecialNotes(
                          title: title, desc: desc, value: value, uid: uid);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => HomePage(index:1)));
                    }
                  }
                },
              ),
            ],
            elevation: 10.0,
            backgroundColor: Colors.white,
          );
        });
  } else {
    Navigator.pop(context);
  }
}
