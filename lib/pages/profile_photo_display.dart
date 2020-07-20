import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/profile_page.dart';
import 'package:notes_app/services/database.dart';

class ProfilePhotoDisplay extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String email;
  final int notesLength;
  final int specialNotesLength;

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
  File croppedImage;
  String imageUrl;
  bool isClicked;

  double _width = 50;
  double _height = 50;
  double _width2 = 50;
  double _height2 = 50;
  double _rightPosition = 20;
  double _topPosition = 18;
  BorderRadius _borderRadius = BorderRadius.circular(25);

  @override
  void initState() {
    super.initState();
    isClicked = false;
  }

  Future choseImage() async {
    await picker.getImage(source: ImageSource.gallery).then((value) {
      setState(() {
        image = File(value.path);
      });
    });

    croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: AndroidUiSettings(
            showCropGrid: false,
            hideBottomControls: true,
            lockAspectRatio: true,
            toolbarTitle: 'Crop Image'));

    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      email = value;
    });
    uploadImage(email: email);
  }

  Future uploadImage({String email}) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(email + "/${image.path}");
    StorageUploadTask uploadTask = storageReference.putFile(croppedImage);
    await uploadTask.onComplete;
    print("File successfully uploaded");
    storageReference.getDownloadURL().then((value) {
      setState(() {
        uploadFileUrl = value;
        HelperFunction.saveUserProfileImageInSharedPreference(uploadFileUrl);
        Map<String, dynamic> profileRoomMap = {
          "imageUrl": uploadFileUrl,
        };

        databaseMethods.updateProfileRoom(
            profileRoomId: email, profileRoomMap: profileRoomMap);

        HelperFunction.getUserProfileImageInSharedPreference().then((value) {
          setState(() {
            imageUrl = value;
          });
        });
      });
    });

    Future.delayed(Duration(milliseconds: 500), () {
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
    Map<String, dynamic> profileRoomMap = {
      "imageUrl": null,
      "email": widget.email
    };
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
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 40.0,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 0.0),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                  offset: Offset(2, 2),
                                  blurRadius: 20.0,
                                  spreadRadius: 1.0)
                            ],
                            borderRadius: BorderRadius.circular(20.0),
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
                                child: Hero(
                                  tag: 'back',
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.5),
                                            offset: Offset(2, 2),
                                            blurRadius: 8.0,
                                            spreadRadius: 2.0)
                                      ],
                                      gradient: LinearGradient(
//                                        colors:[Color(0xff1f5cfc), Colors.blue],
                                          colors: [Colors.white, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight),
                                    ),
                                    child: Icon(Icons.arrow_back,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.9)),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: 4.0,
                                    left: 8.0,
                                    bottom: 4.0,
                                    right: 28),
                                child: Text(
                                  'Profile Image',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     GestureDetector(
                        //         onTap: () {
                        //           choseImage();
                        //         },
                        //         child: Icon(
                        //           Icons.edit,
                        //           color: Colors.black,
                        //         )),
                        //     SizedBox(width: 20),
                        //     GestureDetector(
                        //         onTap: () {
                        //           profileDeleteAlertBox();
                        //         },
                        //         child: Icon(Icons.delete, color: Colors.red))
                        //   ],
                        // )
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
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Hero(
                            tag: 'imageUrl',
                            child: Image.network(
                              widget.imageUrl,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ))
                      : Container(
                          alignment: Alignment.center,
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                          child: Icon(Icons.person, size: 60)),
                ],
              ),
              Stack(
                children: [
                  Positioned(
                      right: 20.0,
                      top: 18.0,
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: _width,
                          height: _height,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                  offset: Offset(2, 2),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0)
                            ],
                            gradient: LinearGradient(
                                colors: [Color(0xff1f5cfc), Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: _borderRadius,
                          ),
                          child: isClicked
                              ? Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            choseImage();
                                          },
                                          child: Icon(
                                            Icons.brush,
                                            color: Colors.white,
                                          )),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                          onTap: () {
                                            profileDeleteAlertBox();
                                          },
                                          child: Icon(Icons.delete,
                                              color: Colors.red))
                                    ],
                                  ))
                              : Container())),
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 100),
                      top: _topPosition,
                      right: _rightPosition,
                      child: AnimatedContainer(
//                        alignment: isClicked
//                            ? Alignment.centerRight
//                            : Alignment.centerRight,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          duration: Duration(milliseconds: 100),
                          height: _height2,
                          width: _width2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: isClicked
                                    ? [Colors.white, Colors.white]
                                    : [Color(0xff1f5cfc), Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: _borderRadius,
                          ),
                          child: isClicked
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _width = 50;
                                      _height2 = 50;
                                      _width2 = 50;
                                      _rightPosition = 20;
                                      _topPosition = 18;
                                      _borderRadius = BorderRadius.circular(25);
                                    });

                                    Future.delayed(Duration(milliseconds: 75),
                                        () {
                                      setState(() {
                                        isClicked = false;
                                      });
                                    });
                                  },
                                  child: Icon(Icons.close,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9),
                                      size: 18
//                                  color:Theme.of(context).primaryColor
                                      ))
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _width2 = 40;
                                      _height2 = 40;
                                      _width = 125;
                                      _rightPosition = 24;
                                      _topPosition = 23;
                                    });
                                    Future.delayed(Duration(milliseconds: 250),
                                        () {
                                      setState(() {
                                        isClicked = true;
                                      });
                                    });
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                )))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
