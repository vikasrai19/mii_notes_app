import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/profile_page.dart';
import 'package:notes_app/services/database.dart';

class ProfilePhotoDisplay extends StatefulWidget {
  String imageUrl;
  String name;
  String email;
  int notesLength;
  int specialNotesLength;

  ProfilePhotoDisplay(
      {this.imageUrl,
      this.name,
      this.email,
      this.notesLength,
      this.specialNotesLength});

  @override
  _ProfilePhotoDisplayState createState() => _ProfilePhotoDisplayState();
}

class _ProfilePhotoDisplayState extends State<ProfilePhotoDisplay> {
  File image;
  String uploadFileUrl;
  ImagePicker picker = ImagePicker();
  DatabaseMethods databaseMethods = DatabaseMethods();
  String email;
  String imageUrl;

  Future choseImage() async {
    await picker.getImage(source: ImageSource.gallery).then((value) {
      setState(() {
        image = File(value.path);
      });
    });
    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      email = value;
    });
    uploadImage(email: email);
  }

  Future uploadImage({String email}) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("${email}/${image.path}");
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print("File successfully uploaded");
    storageReference.getDownloadURL().then((value) {
      setState(() {
        uploadFileUrl = value;
        HelperFunction.saveUserProfileImageInSharedPreference(uploadFileUrl);
        Map<String, dynamic> profileRoomMap = {
          "imageUrl": uploadFileUrl,
          "email": widget.email
        };
        databaseMethods.createProfileRoom(
            profileRoomId: widget.email, profileRoomMap: profileRoomMap);
        HelperFunction.getUserProfileImageInSharedPreference().then((value) {
          setState(() {
            imageUrl = value;
          });
        });
      });
    });

    Future.delayed(Duration(milliseconds: 500),(){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ProfilePage(
                name: widget.name,
                userEmail: widget.email,
                notesLength: widget.notesLength,
                specialNotesLength: widget.specialNotesLength,
              )));
    });
  }

  deleteProfilePic() {
    HelperFunction.saveUserProfileImageInSharedPreference(null);
    Map<String, dynamic> profileRoomMap = {"imageUrl": null, "email": widget.email};
    databaseMethods.updateProfileRoom(
        profileRoomId: widget.email, profileRoomMap: profileRoomMap);

  }

  profileDeleteAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('"Alert !!"'),
            content: Text('Do you want to remove your profile pic'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              FlatButton(
                onPressed: () {
                  deleteProfilePic();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(
                                name: widget.name,
                                userEmail: widget.email,
                                notesLength: widget.notesLength,
                                specialNotesLength: widget.specialNotesLength,
                              )));
                },
                child: Text(
                  "Yes",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Image',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            choseImage();
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                          )),
                      SizedBox(width: 20),
                      GestureDetector(
                          onTap: () {
                            profileDeleteAlertBox();
                          },
                          child: Icon(Icons.delete, color: Colors.red))
                    ],
                  )
                ],
              ),
            ),
            widget.imageUrl != null
                ? SizedBox(
                    height: 0,
                  )
                : SizedBox(
                    height: screenHeight * 0.28,
                  ),
            widget.imageUrl != null
                ? Expanded(
                    child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ))
                : Container(
                    alignment: Alignment.center,
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Icon(Icons.person, size: 60)),
          ],
        ),
      ),
    );
  }
}
