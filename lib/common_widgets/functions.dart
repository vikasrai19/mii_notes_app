import 'package:flutter/material.dart';
import 'package:notes_app/class/user.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';

DatabaseMethods databaseMethods = new DatabaseMethods();
User user = new User();

createNotes({
  String title,
  String desc,
  String uid,
  var value,
}) {
  if (title.isNotEmpty && desc.isNotEmpty) {
    List<String> searchStringList = List();
    String temp = "";
    for (var j = 0; j < title.length; j++) {
      temp = temp + title[j];
      searchStringList.add(temp);
    }
    Map<String, dynamic> notesMap = {
      "title": title,
      "description": desc,
      "time": DateTime.now().millisecondsSinceEpoch,
      "category": value,
      "important": "false",
      "searchTerm": searchStringList,
      "uid": uid
    };

    databaseMethods.addNotes(
        notesMap: notesMap, notesRoomId: uid, title: title);
  }
}

createSpecialNotes({String title, String desc, var value,String uid}) {
  if (title.isNotEmpty) {
    List<String> searchStringList = List();
    String temp = "";
    for (var j = 0; j < title.length; j++) {
      temp = temp + title[j];
      searchStringList.add(temp);
    }
    Map<String, dynamic> notesMap = {
      "title": title,
      "description": desc,
      "time": DateTime.now().millisecondsSinceEpoch,
      "category": value,
      "searchTerm": searchStringList,
      "important": "false",
      "uid": uid
    };

    databaseMethods.addSpecialNotes(
        notesMap: notesMap, notesRoomId: uid, title: title);
  }
}

updateSpecialNotes({String title, String desc, var value, String uid}) {
  if (title.isNotEmpty && desc.isNotEmpty) {
    List<String> searchStringList = List();
    String temp = "";
    for (var j = 0; j < title.length; j++) {
      temp = temp + title[j];
      searchStringList.add(temp);
    }
    Map<String, dynamic> notesMap = {
      "title": title,
      "description": desc,
      // "time": DateTime.now().millisecondsSinceEpoch,
      "category": value,
      "searchTerm": searchStringList
      // "important": "false"
    };

    databaseMethods.updateSpecialNotes(
        updateMap: notesMap,
        notesRoomId: user.getUserUid,
        documentTitle: title);
  }
}
