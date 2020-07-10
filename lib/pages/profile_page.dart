import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/helper/authenticate.dart';
import 'package:notes_app/helper/dark_theme_shared_preference.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/app_settings.dart';
import 'package:notes_app/pages/profile_photo_display.dart';
import 'package:notes_app/pages/sign_in.dart';
import 'package:notes_app/pages/voice_assistant_setings.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class ProfilePage extends StatefulWidget {
  String name;
  String userEmail;
  int notesLength;
  int specialNotesLength;

  ProfilePage(
      {Key key,
      this.name,
      this.userEmail,
      this.notesLength,
      this.specialNotesLength})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String imageUrl;
  String email;
  bool switchControl;
  DatabaseMethods databaseMethods = DatabaseMethods();
  AuthMethods authMethods = new AuthMethods();
  DarkThemePreference darkThemePreference = DarkThemePreference();

  @override
  void initState() {
    darkThemePreference.getTheme().then((value) {
      setState(() {
        switchControl = value;
      });
    });
    getImageUrlFromSharedPreference();
    super.initState();
  }

  getImageUrlFromSharedPreference() async {
    HelperFunction.getUserProfileImageInSharedPreference().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  bool shouldLogOut;

  @override
  Widget build(BuildContext context) {
    signOutAlertBox() {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Do you want to LogOut'),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      authMethods.signOut();
                      HelperFunction.saveUserLoggedInSharedPreference(false);
                      HelperFunction.saveUserProfileImageInSharedPreference(
                          null);
                      HelperFunction.saveNameInSharedPreference(null);
                      HelperFunction.saveUserEmailInSharedPreference(null);
                      HelperFunction.saveSpecialNotesCountInSharedPreference(
                          null);
                      HelperFunction.saveNotesCountInSharedPreference(null);
                      Navigator.pop(context);
                      setState(() {
                        shouldLogOut = true;
                      });
//                      Navigator.pushReplacement(context,
//                          MaterialPageRoute(builder: (_) => SignInPage()));
                    },
                    child: Text('Yes'))
              ],
            );
          });
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => HomePage()));
                      },
                      child: Icon(Icons.arrow_back_ios,
                          color: Theme.of(context).indicatorColor)),
                ),
                SizedBox(height: screenHeight * 0.08),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfilePhotoDisplay(
                                  imageUrl: imageUrl,
                                  name: widget.name,
                                  email: widget.userEmail,
                                  notesLength: widget.notesLength,
                                  specialNotesLength: widget.specialNotesLength,
                                )));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      height: 150.0,
                      width: 150.0,
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(75.0)),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              child: Center(
                              child: Icon(Icons.person,
                                  color: Theme.of(context)
                                      .indicatorColor
                                      .withOpacity(0.4)),
                            )),
                      decoration: BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.name,
                    style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // SizedBox(height : 20.0),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 32.0, left: 16.0, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HomePage(index: 1)));
                        },
                        child: ProfileNotesPageCard(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          textData: "Notes",
                          countData: widget.notesLength,
                          index: 1,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HomePage(index: 2)));
                        },
                        child: ProfileNotesPageCard(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          textData: "Special Notes",
                          countData: widget.specialNotesLength,
                          index: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => AppSettingPage(
                                        isDarkMode: switchControl,
                                        name: widget.name,
                                        userEmail: widget.userEmail,
                                        notesLength: widget.notesLength,
                                        specialNotesLength:
                                            widget.specialNotesLength,
                                      )));
                        },
                        child: SettingsWidget(
                          text: 'App Settings',
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => VoiceAssistantSettings()));
                        },
                        child: SettingsWidget(
                          text: 'Voice Assistant',
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () async {
                      await signOutAlertBox();
                      if (shouldLogOut == true) {
//                        Navigator.pushReplacement(context,
//                            MaterialPageRoute(builder: (_) => SignInPage()));
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => Authenticate()),
                            (route) => false);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.08,
                          width: screenWidth * 0.42,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff5E0035),
                                    Color(0xffE22386)
                                  ]),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 10.0),
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.signOutAlt,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'LogOut',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileNotesPageCard extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String textData;
  final int countData;
  int index;

  ProfileNotesPageCard(
      {Key key,
      this.screenHeight,
      this.screenWidth,
      this.textData,
      this.countData,
      this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.12,
      width: screenWidth * 0.42,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff5E0035), Color(0xffE22386)]),
          boxShadow: [
            categoryIndex == index
                ? BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 10.0)
                : BoxShadow(color: Colors.transparent),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textData,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                child: countData != null
                    ? Text(
                        countData.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )
                    : CircularProgressIndicator(backgroundColor: Colors.white),
              )
            ]),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  String text;

  SettingsWidget({this.text});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.10,
      width: screenWidth * 0.42,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff5E0035), Color(0xffE22386)]),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Center(
          child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w500),
      )),
    );
  }
}
