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
        .collection("Users")
        .where("userEmail", isEqualTo: email)
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

  getNoAdsList({String email}) async {
    return await Firestore.instance
        .collection("NoAds")
        .where("members", arrayContains: email)
        .getDocuments();
  }

  searchNotes({String notesRoomId, String value}) async {
    return await Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .where("searchTerm", arrayContains: value)
        .orderBy("time", descending: false)
        .snapshots();
  }

//  searchNotes({String notesRoomId, String value}) async {
//    return await Firestore.instance
//        .collection("Notes")
//        .document(notesRoomId)
//        .collection("notes").orderBy("time", descending:false).getDocuments();
//  }

//
  createFriendsRoom({String roomId, roomDataMap}) async {
    Firestore.instance
        .collection("Friends")
        .document(roomId)
        .setData(roomDataMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addFriends({String roomId, friendData}) async {
    Firestore.instance
        .collection("Friends")
        .document(roomId)
        .updateData(friendData);
  }

  getFirendList({String roomId}) async {
    return Firestore.instance
        .collection("Friends")
        .where("email", isEqualTo: roomId)
        .getDocuments();
  }

  findFriends({String value, String name}) async {
    return await Firestore.instance
        .collection("Users")
        .where("searchTerm", arrayContains: value)
        .snapshots();
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

  searchSpecialNotes({String notesRoomId, String searchTerm}) {
    return Firestore.instance
        .collection("SpecialNotes")
        .document(notesRoomId)
        .collection("notes")
        .where("searchTerm", arrayContains: searchTerm)
        .snapshots();
  }

  getNotes({String notesRoomId}) async {
    return Firestore.instance
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
    return Firestore.instance
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
    return Firestore.instance
        .collection("Notes")
        .document(notesRoomId)
        .collection("notes")
        .where("important", isEqualTo: "true")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getSpecialImportantNotes({String notesRoomId}) async {
    return Firestore.instance
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

  // createProfileRoom({String profileRoomId, profileRoomMap}) {
  //   Firestore.instance
  //       .collection("Profiles")
  //       .document(profileRoomId)
  //       .setData(profileRoomMap)
  //       .catchError((e) {
  //     print(e.toString());
  //   });
  // }

  updateProfileRoom({String profileRoomId, profileRoomMap}) {
    Firestore.instance
        .collection("Users")
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
        .collection("DeletedNotes")
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
        .collection("DeletedNotes")
        .document(title)
        .setData(deletedNotesMap)
        .catchError((e) {
      print(e.toString());
    });
  }
}
