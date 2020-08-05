import 'dart:io';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart' as IP;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/helper/ad_manager.dart';
import 'package:notes_app/helper/constants.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/pages/profile_page.dart';
import 'package:notes_app/pages/special_notes_display.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';
import 'package:toast/toast.dart';
import 'chat_screen.dart';
import 'notes_creation_page.dart';
import 'notes_editing_page.dart';
import 'special_notes_creation.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:multi_media_picker/multi_media_picker.dart';

String name;
int categoryIndex;
String email;
const String testDevice = 'mobile_id';
int notesDataCount = 0;

String getBannerAdUnitId() {
  Random randomGenerator = new Random();
  List<String> adUrl = [
    "ca-app-pub-1942646706163703/7765302270",
    "ca-app-pub-1942646706163703/8328409052",
    "ca-app-pub-1942646706163703/4389164047",
    "ca-app-pub-1942646706163703/1763000703"
  ];

  int urlIndex = randomGenerator.nextInt(adUrl.length - 1);
  print(adUrl[urlIndex]);

  return adUrl[urlIndex];
}

int notesAdIndex = 0;
int specialNotesAdIndex = 0;
int importantNotesAdIndex = 0;
int specialImportanrAdIndex = 0;

class HomePage extends StatefulWidget {
  final int index;

  HomePage({Key key, this.index}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  TabController tabController;
  TabController specialTabController;
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream notesStream;
  QuerySnapshot notesSnapshot;
  Stream userProfileSnapshot;
  String imageUrl;
  int notesLength;
  int specialNotesLength;
  QuerySnapshot notesLengthSnapshot;
  QuerySnapshot specialNotesLengthSnapshot;
  QuerySnapshot userInfoSnapshot;
  QuerySnapshot imageSnapshot;
  Stream specialNotesStream;
  AsyncSnapshot snapshot;
  Stream importanNotesStream;
  Stream specialImportantNotesStream;
  Stream notesSearchStream;
  Stream specialNotesSearchStream;
  TextEditingController titleController = new TextEditingController();
  TextEditingController searchController = new TextEditingController();

  List<String> extractedWords;
  List<File> imgs;
  bool isVideo = false;
  File pickedImage;
  File pickedImageFromCamera;
  String finalSentences;
  String title;
  bool isImportant;
  final CalendarPlugin calendarPlugin = CalendarPlugin();
  bool isSearching;
  bool searchEnabled;
  bool showAds = false;
  String userUid;

  @override
  void initState() {
    HelperFunction.getUserUidFromSharedPreference().then((value) {
      setState(() {
        userUid = value;
        print("User Uid is " + userUid);
      });
    });
    getUserInfo();
    isSearching = false;
    searchEnabled = false;
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    specialTabController =
        TabController(length: 2, vsync: this, initialIndex: 0);
    getImageUrl();
    super.initState();
    extractedWords = [];
    title = "Add note heading";
    categoryIndex = widget.index == null ? 1 : widget.index;
    isImportant = true;
    FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    bannerAd = createBannerAd()
      ..load()
      ..show();
//    _nativeAdmob.initialize(appID: AdManager.appId);
    // HelperFunction.getAdsPrevInSharedPreference().then((value) {
    //   if (value != null && value == true) {
    //     setState(() {
    //       showAds = true;
    //     });
    //     FirebaseAdMob.instance.initialize(appId: AdManager.appId);
    //     bannerAd = createBannerAd()
    //       ..load()
    //       ..show();
    //   } else {
    //     setState(() {
    //       showAds = false;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    // if (showAds == true) {
    //   bannerAd.dispose();
    // }
    bannerAd.dispose();
    super.dispose();
  }

  final picker = IP.ImagePicker();

  Future pickImage(ImageSource source, {bool singleImage = false}) async {
    var _imgs;
    if (!isVideo) {
      _imgs = await MultiMediaPicker.pickImages(
          source: source, singleImage: singleImage);
    }

    setState(() {
      imgs = _imgs;
    });

    for (var i = 0; i < imgs.length; i++) {
      await readMultipleText(imgs[i], i: i, length: imgs.length);
    }
  }

  Future readMultipleText(File imagePicked, {int i, int length}) async {
    FirebaseVisionImage image = FirebaseVisionImage.fromFile(
        imagePicked); //this line is used to get firebase vision image
    TextRecognizer recognizeText = FirebaseVision.instance
        .textRecognizer(); //this line is used to initilaize the text recognizer
    VisionText readText = await recognizeText.processImage(image);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          extractedWords.add(word.text);
        }
      }
    }
    finalSentences = extractedWords.join(" ");
    print(finalSentences);
    if (i == length - 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SpecialNotesCreationPage(
                    description: finalSentences,
                    category: "special_notes",
                    uid: userUid,
                  )));
    }
  }

  Future pickImageFromCamera() async {
    final pickedFileFromCamera =
        await picker.getImage(source: IP.ImageSource.camera);
    setState(() {
      pickedImageFromCamera = File(pickedFileFromCamera.path);
    });
    readText(pickedImageFromCamera);
  }

  takeInputForTitle({String desc}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Title for notes"),
            actions: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.black45),
                  border: InputBorder.none,
                ),
                onSubmitted: (string) {},
              )
            ],
          );
        });
  }

  Future readText(File imagePicked) async {
    FirebaseVisionImage image = FirebaseVisionImage.fromFile(imagePicked);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(image);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          extractedWords.add(word.text);
        }
      }
    }
    finalSentences = extractedWords.join(" ");
    print(finalSentences);
    // takeInputForTitle(desc: finalSentences);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SpecialNotesCreationPage(
                  description: finalSentences,
                  category: "special_notes",
                  uid: userUid,
                )));
  }

  getNotesLength({String uid}) {
    databaseMethods.getNotesLength(notesRoomId: uid).then((value) {
      notesLengthSnapshot = value;
      setState(() {
        notesLength = notesLengthSnapshot.documents.length;
      });
    });
  }

  getImportantNotes({String uid}) {
    databaseMethods.getImportantNotes(notesRoomId: uid).then((value) {
      importanNotesStream = value;
    });
  }

  getSpecialImportantNotes({String uid}) {
    databaseMethods.getSpecialImportantNotes(notesRoomId: uid).then((value) {
      specialImportantNotesStream = value;
    });
  }

  getSpecialNotesLength({String uid}) {
    databaseMethods.getSpecialNotesLength(notesRoomId: uid).then((value) {
      specialNotesLengthSnapshot = value;
      setState(() {
        specialNotesLength = specialNotesLengthSnapshot.documents.length;
      });
    });
  }

  getImageUrl() {
    HelperFunction.getUserProfileImageInSharedPreference().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  updateValue() async {
    if (snapshot.hasData) {
      setState(() {
        notesLength = snapshot.data.documents.length;
        print("Notes length is " + notesLength.toString());
      });
    }
  }

  getNotesInfo({String uid}) async {
    print("Before notes Stream");
    print(uid);
    if (uid != null) {
      await databaseMethods.getNotes(notesRoomId: uid).then((value) {
        // print("User uid inside notes stream function is " + uid);
        setState(() {
          notesStream = value;
          print("After notes Stream");
          print(uid);
          // print(notesStream);
        });
      });
    }
  }

  getUserInfo() async {
    await HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        email = value;
        print("Email " + email);
      });
    });

    HelperFunction.getUserNameFromSharedPreference().then((value) {
      if (value == null) {
        databaseMethods.getUserByUserEmail(email: email).then((value) {
          setState(() {
            userInfoSnapshot = value;

            HelperFunction.saveNameInSharedPreference(
                userInfoSnapshot.documents[0].data['name']);
            name = userInfoSnapshot.documents[0].data['name'];
            HelperFunction.saveAssistantLangInSharedPreferences(
                userInfoSnapshot.documents[0].data['language']);
            HelperFunction.saveAssistantPicthInSharedPreference(
                userInfoSnapshot.documents[0].data['pitch']);
            HelperFunction.saveAssistantVolumeInSharedPreference(
                userInfoSnapshot.documents[0].data['volume']);
          });
        });
      } else {
        setState(() {
          name = value;
        });
      }
    });

    HelperFunction.getUserProfileImageInSharedPreference().then((value) {
      if (value == null) {
        databaseMethods.getProfilePhotoByEmail(email: email).then((value) {
          setState(() {
            imageSnapshot = value;
            HelperFunction.saveUserProfileImageInSharedPreference(
                imageSnapshot.documents[0].data['imageUrl']);
            imageUrl = imageSnapshot.documents[0].data['imageUrl'];
          });
        });
      } else {
        setState(() {
          imageUrl = value;
        });
      }
    });
    print("Just beore calling the function");
    print(userUid);
    getNotesInfo(uid: userUid);
    getNotesLength(uid: userUid);
    getSpecialNotesLength(uid: userUid);
    getSpecialNotes(uid: userUid);
    getImportantNotes(uid: userUid);
    getSpecialImportantNotes(uid: userUid);
  }

  createNotesRoom() {
    Map<String, dynamic> notesMap = {
      "name": name,
      "email": email,
      "uid": userUid
    };

    databaseMethods.createNoteRoom(notesRoomId: userUid, notesMap: notesMap);

    databaseMethods.createDeletedNotesRoom(
        deletedRoomId: userUid, deletedNotesMap: notesMap);
  }

  createSpecialNotesRoom() {
    Map<String, dynamic> notesMap = {
      "name": name,
      "email": email,
      "uid": userUid
    };
    databaseMethods.createSpecialNotesRoom(
        notesRoomId: userUid, notesMap: notesMap);
    databaseMethods.createSpecialNotesDeleteRoom(
        deleteRoomId: userUid, deletedNotesMap: notesMap);
  }

  notesList({Stream notesStreamlist, int secIndex}) {
    return StreamBuilder(
        stream: notesStreamlist,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data.documents[index].data["important"] ==
                        "false") {
                      isImportant = false;
                    } else {
                      isImportant = true;
                    }

                    return Dismissible(
                      key: Key(snapshot.data.documents[index].data["title"]),
                      background: slideRightBackground(),
                      secondaryBackground: slideLeftBackground(),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          final bool res = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                      "Are you sure you want to delete ${snapshot.data.documents[index].data["title"]}?",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black)),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Cancel",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Delete",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.red),
                                      ),
                                      onPressed: () {
                                        if (secIndex == 1) {
                                          Map<String, dynamic> deletedNotesMap =
                                              {
                                            "title": snapshot.data
                                                .documents[index].data["title"],
                                            "description": snapshot
                                                .data
                                                .documents[index]
                                                .data["description"],
                                            "uid": userUid
                                          };
                                          databaseMethods.addDeletedNotes(
                                            deletedRoomId: userUid,
                                            deletedNotesMap: deletedNotesMap,
                                            title: snapshot.data
                                                .documents[index].data["title"],
                                          );
                                          databaseMethods.deleteNote(
                                              notesRoomId: userUid,
                                              documentId: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["title"]);
                                        } else if (secIndex == 2) {
                                          Map<String, dynamic> deletedNotesMap =
                                              {
                                            "title": snapshot.data
                                                .documents[index].data["title"],
                                            "description": snapshot
                                                .data
                                                .documents[index]
                                                .data["description"],
                                            "uid": userUid
                                          };
                                          databaseMethods
                                              .addSpecialDeletedNotes(
                                            deletedRoomId: userUid,
                                            deletedNotesMap: deletedNotesMap,
                                            title: snapshot.data
                                                .documents[index].data["title"],
                                          );
                                          databaseMethods.deletSpecialNotes(
                                              notesRoomId: userUid,
                                              documentId: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["title"]);
                                        }
                                        getNotesLength(uid: userUid);
                                        getSpecialNotesLength(uid: userUid);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
                          return res;
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NotesEditingPage(
                                        title: snapshot.data.documents[index]
                                            .data["title"],
                                        description: snapshot
                                            .data
                                            .documents[index]
                                            .data["description"],
                                        category: snapshot.data.documents[index]
                                            .data["category"],
                                      )));
                        }
                      },
                      child: index != 0 &&
                              index % 3 == 0 &&
                              index != snapshot.data.documents.length - 1
                          ? Column(
                              children: [
                                ListTile(
                                  onLongPress: () {
                                    if (secIndex == 1) {
                                      setState(() {
                                        if (snapshot.data.documents[index]
                                                .data["important"] ==
                                            "false") {
                                          isImportant = true;
                                          Toast.show(
                                              'Marked As Important', context,
                                              duration: Toast.LENGTH_SHORT,
                                              gravity: Toast.BOTTOM);
                                        } else {
                                          isImportant = false;
                                          Toast.show(
                                              'Marked As UnImportant', context,
                                              duration: Toast.LENGTH_SHORT,
                                              gravity: Toast.BOTTOM);
                                        }
                                      });
                                      if (isImportant) {
                                        Map<String, dynamic> importantMap = {
                                          "important": "true"
                                        };
                                        databaseMethods.addImportantTag(
                                            notesRoomId: userUid,
                                            documentTitle: snapshot.data
                                                .documents[index].data["title"],
                                            importantMap: importantMap);
                                      } else {
                                        Map<String, dynamic> importantMap = {
                                          "important": "false"
                                        };
                                        databaseMethods.addImportantTag(
                                            notesRoomId: userUid,
                                            documentTitle: snapshot.data
                                                .documents[index].data["title"],
                                            importantMap: importantMap);
                                      }
                                    } else if (secIndex == 2) {
                                      setState(() {
                                        if (snapshot.data.documents[index]
                                                .data["important"] ==
                                            "false") {
                                          isImportant = true;
                                          Toast.show(
                                              'Marked As Important', context,
                                              duration: Toast.LENGTH_SHORT,
                                              gravity: Toast.BOTTOM);
                                        } else {
                                          isImportant = false;
                                          Toast.show(
                                              'Marked As UnImportant', context,
                                              duration: Toast.LENGTH_SHORT,
                                              gravity: Toast.BOTTOM);
                                        }
                                      });
                                      if (isImportant) {
                                        Map<String, dynamic> importantMap = {
                                          "important": "true"
                                        };
                                        databaseMethods.addSpecialImportantTag(
                                            notesRoomId: userUid,
                                            documentTitle: snapshot.data
                                                .documents[index].data["title"],
                                            importantMap: importantMap);
                                      } else {
                                        Map<String, dynamic> importantMap = {
                                          "important": "false"
                                        };
                                        databaseMethods.addSpecialImportantTag(
                                            notesRoomId: userUid,
                                            documentTitle: snapshot.data
                                                .documents[index].data["title"],
                                            importantMap: importantMap);
                                      }
                                    }
                                  },
                                  enabled: true,
                                  trailing: isImportant != null && isImportant
                                      ? Icon(MdiIcons.star,
                                          color: Theme.of(context).primaryColor)
                                      : Icon(MdiIcons.star,
                                          color: Theme.of(context)
                                              .backgroundColor
                                              .withOpacity(0.5)),
                                  onTap: () {
                                    if (secIndex == 1) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => NotesDisplayPage(
                                                    showAds: showAds,
                                                    title: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data["title"],
                                                    description: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data["description"],
                                                    category: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data["category"],
                                                  )));
                                    } else if (secIndex == 2) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  SpecialNotesDisplayPage(
                                                    showAds: showAds,
                                                    title: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data["title"],
                                                    description: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data["description"],
                                                    category: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data["category"],
                                                  )));
                                    }
                                  },
                                  title: Text(
                                    snapshot.data.documents[index].data["title"]
                                        .toString(),
                                    style: GoogleFonts.montserrat(
                                      color: Theme.of(context).indicatorColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    snapshot.data.documents[index]
                                        .data["description"]
                                        .toString(),
                                    style: GoogleFonts.montserrat(
                                        color: Theme.of(context)
                                            .indicatorColor
                                            .withOpacity(0.6),
                                        fontSize: 16.0),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AdmobBanner(
                                    adUnitId: getBannerAdUnitId(),
                                    adSize: AdmobBannerSize.BANNER),
                              ],
                            )
                          : ListTile(
                              onLongPress: () {
                                if (secIndex == 1) {
                                  setState(() {
                                    if (snapshot.data.documents[index]
                                            .data["important"] ==
                                        "false") {
                                      isImportant = true;
                                      Toast.show('Marked As Important', context,
                                          duration: Toast.LENGTH_SHORT,
                                          gravity: Toast.BOTTOM);
                                    } else {
                                      isImportant = false;
                                      Toast.show(
                                          'Marked As UnImportant', context,
                                          duration: Toast.LENGTH_SHORT,
                                          gravity: Toast.BOTTOM);
                                    }
                                  });
                                  if (isImportant) {
                                    Map<String, dynamic> importantMap = {
                                      "important": "true"
                                    };
                                    databaseMethods.addImportantTag(
                                        notesRoomId: userUid,
                                        documentTitle: snapshot.data
                                            .documents[index].data["title"],
                                        importantMap: importantMap);
                                  } else {
                                    Map<String, dynamic> importantMap = {
                                      "important": "false"
                                    };
                                    databaseMethods.addImportantTag(
                                        notesRoomId: userUid,
                                        documentTitle: snapshot.data
                                            .documents[index].data["title"],
                                        importantMap: importantMap);
                                  }
                                } else if (secIndex == 2) {
                                  setState(() {
                                    if (snapshot.data.documents[index]
                                            .data["important"] ==
                                        "false") {
                                      isImportant = true;
                                      Toast.show('Marked As Important', context,
                                          duration: Toast.LENGTH_SHORT,
                                          gravity: Toast.BOTTOM);
                                    } else {
                                      isImportant = false;
                                      Toast.show(
                                          'Marked As UnImportant', context,
                                          duration: Toast.LENGTH_SHORT,
                                          gravity: Toast.BOTTOM);
                                    }
                                  });
                                  if (isImportant) {
                                    Map<String, dynamic> importantMap = {
                                      "important": "true"
                                    };
                                    databaseMethods.addSpecialImportantTag(
                                        notesRoomId: userUid,
                                        documentTitle: snapshot.data
                                            .documents[index].data["title"],
                                        importantMap: importantMap);
                                  } else {
                                    Map<String, dynamic> importantMap = {
                                      "important": "false"
                                    };
                                    databaseMethods.addSpecialImportantTag(
                                        notesRoomId: userUid,
                                        documentTitle: snapshot.data
                                            .documents[index].data["title"],
                                        importantMap: importantMap);
                                  }
                                }
                              },
                              enabled: true,
                              trailing: isImportant != null && isImportant
                                  ? Icon(MdiIcons.star,
                                      color: Theme.of(context).primaryColor)
                                  : Icon(MdiIcons.star,
                                      color: Theme.of(context)
                                          .backgroundColor
                                          .withOpacity(0.5)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => NotesDisplayPage(
                                              title: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["title"],
                                              description: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["description"],
                                              category: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["category"],
                                            )));
                              },
                              title: Text(
                                snapshot.data.documents[index].data["title"]
                                    .toString(),
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).indicatorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                snapshot
                                    .data.documents[index].data["description"]
                                    .toString(),
                                style: GoogleFonts.montserrat(
                                    color: Theme.of(context)
                                        .indicatorColor
                                        .withOpacity(0.6),
                                    fontSize: 16.0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    );
                  })
              : Container(
                  child: Center(
                    child: notesLength != null && notesLength != 0
                        ? CircularProgressIndicator()
                        : Container(
                            child: Text(
                              "No Notes Available",
                              style: GoogleFonts.montserrat(
                                  color: Theme.of(context).indicatorColor),
                            ),
                          ),
                  ),
                );
        });
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Edit",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showAds != null) {
      SizeConstants(showAds: showAds).init(context);
    }
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            color: Theme.of(context).backgroundColor,
            height: screenHeight,
            padding: EdgeInsets.only(bottom: 55), //SizeConstants.bottomPadding
            width: screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.08, left: 24, right: 24),
                  child: searchEnabled == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProfilePage(
                                              name: name,
                                              userEmail: email,
                                              notesLength: notesLength,
                                              specialNotesLength:
                                                  specialNotesLength,
                                            )));
                              },
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'imageUrl',
                                    child: Container(
                                      height: 60.0,
                                      width: 60.0,
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).indicatorColor,
                                          shape: BoxShape.circle),
                                      child: imageUrl == null
                                          ? Container(
                                              child: Center(
                                                  child: Icon(
                                                Icons.person,
                                                size: 35,
                                              )),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              )),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Text(name != null ? name : "",
                                      style: GoogleFonts.grenze(
                                          color:
                                              Theme.of(context).indicatorColor,
                                          fontSize: 26.0,
                                          fontWeight: FontWeight.bold)
                                      // style: TextStyle(
                                      //   color: Theme.of(context).indicatorColor,
                                      //   fontSize: 24.0,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                      ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
//                                GestureDetector(
//                                    onTap: () {
//                                      setState(() {
//                                        searchEnabled = true;
//                                      });
//                                    },
//                                    child: Icon(Icons.search,
//                                        color:
//                                            Theme.of(context).indicatorColor)),
                                SizedBox(width: 10),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProfilePage(
                                                    name: name,
                                                    userEmail: email,
                                                    notesLength: notesLength,
                                                    specialNotesLength:
                                                        specialNotesLength,
                                                  )));
                                    },
                                    child: Icon(Icons.settings,
                                        color:
                                            Theme.of(context).indicatorColor))
                                // GestureDetector(
                                //   child: Container(
                                //       padding: EdgeInsets.all(2.0),
                                //       child: Icon(Icons.message,
                                //           color: Theme.of(context)
                                //               .indicatorColor)),
                                //   onTap: () {
                                //     print("tapped");
                                //     if (email == "vikasrai1906@gmail.com") {
                                //       Navigator.push(
                                //           context,
                                //           CupertinoPageRoute(
                                //               builder: (_) => ChatScreenPage(
                                //                     email: email,
                                //                   )));
                                //     }
                                //   },
                                // ),
                              ],
                            )
                          ],
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).indicatorColor,
                              )),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: searchController,
                                  onChanged: (searchString) {
                                    print(searchString);
                                    if (searchString == null ||
                                        searchString == "") {
                                      setState(() {
                                        isSearching = false;
                                      });
                                    } else {
                                      setState(() {
                                        isSearching = true;
                                      });
                                      databaseMethods
                                          .searchNotes(
                                              notesRoomId: email,
                                              value: searchController.text)
                                          .then((value) {
                                        setState(() {
                                          notesSearchStream = value;
                                        });
                                      });
                                      databaseMethods
                                          .searchSpecialNotes(
                                              notesRoomId: email,
                                              searchTerm: searchString)
                                          .then((value) {
                                        setState(() {
                                          specialNotesSearchStream = value;
                                        });
                                      });
                                    }
                                  },
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16.0,
                                      color: Theme.of(context).indicatorColor),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: categoryIndex == 1
                                          ? 'Search Notes'
                                          : 'Search Special Notes',
                                      hintStyle: GoogleFonts.montserrat(
                                          fontSize: 12.0,
                                          color: Theme.of(context)
                                              .indicatorColor
                                              .withOpacity(0.5))),
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      searchEnabled = false;
                                      isSearching = false;
                                      searchController.clear();
                                      print("not searching");
                                    });
                                  },
                                  child: Icon(Icons.cancel,
                                      color: Theme.of(context).indicatorColor))
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              categoryIndex = 1;
                            });
                          },
                          child: NotesPageCard(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            textData: "Notes",
                            countData: notesLength,
                            index: 1,
                          )),
                      SizedBox(width: screenWidth * 0.05),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            categoryIndex = 2;
                          });
                        },
                        child: NotesPageCard(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          textData: "Special Notes",
                          countData: specialNotesLength,
                          index: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tabBarV(),
                    categoryIndex == 1
                        ? GestureDetector(
                            onTap: () {
                              createNotesRoom();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          NotesCreatorPage(uid: userUid)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.only(right: 15.0),
                              child: Icon(Icons.add,
                                  color: Colors.white, size: 30),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(3.0),
                            margin: EdgeInsets.only(right: 15.0),
                            // child: Icon(Icons.add,
                            //     color: Colors.white, size: 30)
                            child: PopupMenuButton(
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text('Image From Camera',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .indicatorColor)),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child: Text('Image From Gallery',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .indicatorColor)),
                                      )
                                    ],
                                onSelected: (value) {
                                  if (value == 1) {
                                    createSpecialNotesRoom();
                                    pickImageFromCamera();
                                  } else if (value == 2) {
                                    createSpecialNotesRoom();
                                    setState(() {
                                      isVideo = false;
                                    });
                                    pickImage(ImageSource.gallery);
                                  }
                                },
                                color: Theme.of(context).backgroundColor,
                                icon: Icon(Icons.add,
                                    color: Colors.white, size: 30)),
                          )
                  ],
                ),
                Expanded(
                  child: tabBarViewWidget(),
                ),
//                Expanded(
//                    child: tabBarViewWidget(
//                        notesSearchStreamv: notesSearchStream,
//                        specialNotesSearchStreamv: specialNotesSearchStream)),
              ],
            )),
      ),
    );
  }

  Widget specialPopUpButton() {
    return PopupMenuButton(
      elevation: 5.0,
      tooltip: 'Select an image',
      itemBuilder: (context) => [
        PopupMenuItem(child: Text('Image From Camera')),
        PopupMenuItem(child: Text('Image From Gallery'))
      ],
    );
  }

  Widget tabBarV() {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Color(0xFFAFB4C6),
          indicatorColor: Theme.of(context).primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 4.0,
          isScrollable: true,
          onTap: (value) {
            tabController.index = value;
          },
          tabs: [
            Tab(
              child: Text(
                'Notes',
                style: GoogleFonts.montserratSubrayada(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor),
              ),
            ),
            Tab(
              child: Text(
                'Important',
                style: GoogleFonts.montserratSubrayada(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor),
              ),
            ),
//            Tab(
//              child: Text(
//                'Reminder',
//                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//              ),
//            ),
          ],
        ),
      ],
    );
  }

  Widget tabBarViewWidget() {
    return TabBarView(controller: tabController, children: [
      categoryIndex == 1
          ? notesList(notesStreamlist: notesStream, secIndex: 1)
          : notesList(notesStreamlist: specialNotesStream, secIndex: 2),
      categoryIndex == 1
          ? getImportantNotesList(notesStreamList: importanNotesStream)
          : getImportantNotesList(notesStreamList: specialImportantNotesStream),
    ]);
  }

  Widget searchNotesList({Stream searchStream}) {
    return StreamBuilder(
      stream: searchStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  print("Title is " +
                      snapshot.data.documents[index].data["title"]);
                  return snapshot.data.documents[index].data["title"]
                          .contains(searchController.text)
                      ? ListTile(
                          title: Text(
                              snapshot.data.documents[index].data["title"],
                              style: TextStyle(
                                  color: Theme.of(context).indicatorColor)),
                          subtitle: Text(
                              snapshot
                                  .data.documents[index].data["description"],
                              maxLines: 1,
                              style: TextStyle(
                                  color: Theme.of(context).indicatorColor)),
                        )
                      : Container();
                },
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  getSpecialNotes({String uid}) {
    databaseMethods.getSpecialNotes(notesRoomId: uid).then((value) {
      specialNotesStream = value;
    });
  }

  var notesLengthValue;

  Widget getImportantNotesList({Stream notesStreamList}) {
    return StreamBuilder(
      stream: notesStreamList,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return index != 0 &&
                          index % 3 == 0 &&
                          index != snapshot.data.documents.length - 1
                      ? Column(
                          children: [
                            ListTile(
                              enabled: true,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => NotesDisplayPage(
                                              title: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["title"],
                                              description: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["description"],
                                              category: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data["category"],
                                            )));
                              },
                              title: Text(
                                snapshot.data.documents[index].data["title"]
                                    .toString(),
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).indicatorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                snapshot
                                    .data.documents[index].data["description"]
                                    .toString(),
                                style: GoogleFonts.montserrat(
                                    color: Theme.of(context)
                                        .indicatorColor
                                        .withOpacity(0.7),
                                    fontSize: 16.0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AdmobBanner(
                                adUnitId: getBannerAdUnitId(),
                                adSize: AdmobBannerSize.BANNER)
                          ],
                        )
                      : ListTile(
                          enabled: true,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => NotesDisplayPage(
                                          title: snapshot.data.documents[index]
                                              .data["title"],
                                          description: snapshot
                                              .data
                                              .documents[index]
                                              .data["description"],
                                          category: snapshot
                                              .data
                                              .documents[index]
                                              .data["category"],
                                        )));
                          },
                          title: Text(
                            snapshot.data.documents[index].data["title"]
                                .toString(),
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).indicatorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            snapshot.data.documents[index].data["description"]
                                .toString(),
                            style: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.7),
                                fontSize: 16.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                })
            : Container(
                child: Center(
                    child: Text('No Important Notes yet',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor))),
              );
      },
    );
  }
}

class NotesPageCard extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String textData;
  final int countData;
  final int index;

  NotesPageCard(
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
      height: screenHeight * 0.22,
      width: screenWidth * 0.42,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: categoryIndex == index
                  ? [Color(0xff1f5cfc), Colors.blue]
//                  ? [Color(0xff5E0035), Color(0xffE22386)]
                  : [Color(0xFFF5F7FB), Color(0xFFF5F7FB)]),
          boxShadow: [
            categoryIndex == index
                ? BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    offset: Offset(2, 2),
                    blurRadius: 10.0,
                    spreadRadius: 2.0)
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
                    color: categoryIndex == index ? Colors.white : Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                child: countData != null
                    ? Text(
                        countData.toString(),
                        style: GoogleFonts.montserrat(
                            color: categoryIndex == index
                                ? Colors.white
                                : Colors.black,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      )
                    : CircularProgressIndicator(backgroundColor: Colors.white),
              )
            ]),
      ),
    );
  }
}

class CustomSettingButton extends StatelessWidget {
  //Just created a new customSetting button for style
  final Color color;

  CustomSettingButton(
      {this.color = Colors
          .black}); //This is a sample speed test of my android studio in ubuntu

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 3,
            width: 30,
            color: color,
          ),
          SizedBox(height: 5),
          Container(height: 3, width: 20, color: color)
        ],
      ),
    );
  }
}

// AdmobBanner(
//                                 adUnitId: getBannerAdUnitId(),
//                                 adSize: AdmobBannerSize.BANNER)
