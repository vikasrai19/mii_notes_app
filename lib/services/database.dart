import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUserEmail({String email}) async {
    return await Firestore.instance
        .collection("Users")
        .where("userEmail", isEqualTo: email)
        .getDocuments();
  }

  checkEmaIlId({String email}) async {
    return await Firestore.instance
        .collection("Users")
        .where("userEmail", isEqualTo: email)
        .getDocuments();
  }

  getProfilePhotoByEmail({String email}) async {
    return await Firestore.instance
        .collection("Profiles")
        .where("email", isEqualTo: email)
        .getDocuments();
  }

  uploadUserInfo({userMap, String email}) {
    Firestore.instance.collection("Users").document(email).setData(userMap);
  }

  updateUserInfo({updateMap, String email}) {
    Firestore.instance
        .collection("Users")
        .document(email)
        .updateData(updateMap);
  }

  addNotes({String notesRoomId, notesMap, String title}) {
    Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .document(title)
        .setData(notesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addSpecialNotes({String notesRoomId, notesMap, String title}) {
    Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .document(title)
        .setData(notesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getNotes({String notesRoomId}) async {
    return await Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getNotesLength({String notesRoomId}) async {
    return await Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .getDocuments();
  }

  getSpecialNotes({String notesRoomId}) async {
    return await Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getSpecialNotesLength({String notesRoomId}) async {
    return await Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .getDocuments();
  }

  updateNotes({String notesRoomId, String documentTitle, updateMap}) async {
    await Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .document(documentTitle)
        .updateData(updateMap);
  }

  updateSpecialNotes(
      {String notesRoomId, String documentTitle, updateMap}) async {
    await Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .document(documentTitle)
        .updateData(updateMap);
  }

  addImportantTag(
      {String notesRoomId, String documentTitle, importantMap}) async {
    await Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .document(documentTitle)
        .updateData(importantMap);
  }

  addSpecialImportantTag(
      {String notesRoomId, String documentTitle, importantMap}) async {
    await Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .document(documentTitle)
        .updateData(importantMap);
  }

  getImportantNotes({String notesRoomId}) async {
    return await Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .where("important", isEqualTo: "true")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getSpecialImportantNotes({String notesRoomId}) async {
    return await Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .where("important", isEqualTo: "true")
        .orderBy("time", descending: false)
        .snapshots();
  }

  createNoteRoom({String notesRoomId, notesMap}) {
    Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .setData(notesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createSpecialNotesRoom({String notesRoomId, notesMap}) async {
    Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .setData(notesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createProfileRoom({String profileRoomId, profileRoomMap}) {
    Firestore.instance
        .collection("Profiles")
        .document(profileRoomId)
        .setData(profileRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  updateProfileRoom({String profileRoomId, profileRoomMap}) {
    Firestore.instance
        .collection("Profiles")
        .document(profileRoomId)
        .updateData(profileRoomMap);
  }

  deleteNote({String notesRoomId, String documentId}) async {
    Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .document(documentId)
        .delete();
  }

  deletSpecialNotes({String notesRoomId, String documentId}) async {
    await Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .document(documentId)
        .delete();
  }

  createDeletedNotesRoom({String deletedRoomId, deletedNotesMap}) {
    Firestore.instance
        .collection("DeletedNotes")
        .document(deletedRoomId)
        .setData(deletedNotesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createSpecialNotesDeleteRoom({String deleteRoomId, deletedNotesMap}) async {
    await Firestore.instance
        .collection("SpecialDeletedNotes")
        .document(deleteRoomId)
        .setData(deletedNotesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addDeletedNotes({String deletedRoomId, deletedNotesMap, String title}) {
    Firestore.instance
        .collection("DeletedNotes")
        .document(deletedRoomId)
        .collection("Deleted Notes")
        .document(title)
        .setData(deletedNotesMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addSpecialDeletedNotes(
      {String deletedRoomId, deletedNotesMap, String title}) async {
    await Firestore.instance
        .collection("SpecialDeletedNotes")
        .document(deletedRoomId)
        .collection("Deleted Notes")
        .document(title)
        .setData(deletedNotesMap)
        .catchError((e) {
      print(e.toString());
    });
  }
}
