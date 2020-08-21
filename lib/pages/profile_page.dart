import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/ad_manager.dart';
import 'package:notes_app/helper/authenticate.dart';
import 'package:notes_app/helper/dark_theme_shared_preference.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/app_settings.dart';
import 'package:notes_app/pages/profile_photo_display.dart';
import 'package:notes_app/pages/voice_assistant_setings.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String userEmail;
  final int notesLength;
  final int specialNotesLength;

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
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Game', 'Apps', 'App Development'],
  );

  BannerAd bannerAd;

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: AdManager.bannerAdUnitId,
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("Banner $event");
        });
  }

  String imageUrl;
  String email;
  bool switchControl;
  DatabaseMethods databaseMethods = DatabaseMethods();
  AuthMethods authMethods = new AuthMethods();
  DarkThemePreference darkThemePreference = DarkThemePreference();

  @override
  void initState() {
    // FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    // bannerAd = createBannerAd()
    //   ..load()
    //   ..show();
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
              title: Text('Do you want to LogOut',
                  style: GoogleFonts.montserrat()),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No', style: GoogleFonts.montserrat())),
                FlatButton(
                    onPressed: () {
                      authMethods.signOut();
                      HelperFunction.saveUserAdsPrevInSharedPreference(null);
                      HelperFunction.saveUserLoggedInSharedPreference(false);
                      HelperFunction.saveUserProfileImageInSharedPreference(
                          null);
                      HelperFunction.saveUserUidInSharedPreferences(null);
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
                    child: Text('Yes', style: GoogleFonts.montserrat()))
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Container(
                    height: 40.0,
                    width: 175,
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
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
                        Hero(
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
                            // padding: EdgeInsets.symmetric(
                            //     vertical: 8.0, horizontal: 16.0),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
//                                  Navigator.pushAndRemoveUntil(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (_) => HomePage()),
//                                      (route) => false);
                                },
                                child: Icon(Icons.arrow_back,
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Profile Page',
                              style: GoogleFonts.grenze(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
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
                  child: Hero(
                    tag: 'imageUrl',
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
                ),
                SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.name,
                    style: GoogleFonts.grenze(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 34.0,
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
                                  colors: [Color(0xff1f5cfc), Colors.blue]),
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
                                style: GoogleFonts.montserrat(
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
  final int index;

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
              colors: [Color(0xff1f5cfc), Colors.blue]),
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
                style: GoogleFonts.fondamento(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                child: countData != null
                    ? Text(
                        countData.toString(),
                        style: GoogleFonts.montserrat(
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
  final String text;

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
              begin: Alignment.topLeft, end: Alignment.bottomRight,
//              colors: [Color(0xff5E0035), Color(0xffE22386)]
              colors: [Color(0xff1f5cfc), Colors.blue]),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Center(
          child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
            color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w500),
      )),
    );
  }
}
