import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:notes_app/helper/ad_manager.dart';
import 'package:notes_app/helper/constants.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/note_display_page.dart';
import 'package:notes_app/pages/profile_page.dart';
import 'package:notes_app/pages/reminder_page.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';
import 'package:toast/toast.dart';
import 'notes_creation_page.dart';
import 'notes_editing_page.dart';
import 'special_notes_editing_page.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:firebase_admob/firebase_admob.dart';

String name;
int categoryIndex;
String email;
const String testDevice = 'mobile_id';
int notesDataCount = 0;

class HomePage extends StatefulWidget {
  int index;

  HomePage({Key key, this.index}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Game', 'Apps', 'App Development'],
  );

  BannerAd bannerAd;

  BannerAd createBannerAd() {
    return BannerAd(
//        adUnitId: BannerAd.testAdUnitId,
    adUnitId: AdManager.bannerAdUnitId,
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("Banner $event");
        });
  }

  TabController tabController;
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
  Stream specialNotesStream;
  AsyncSnapshot snapshot;
  Stream importanNotesStream;
  TextEditingController titleController = new TextEditingController();

  List<String> extractedWords;
  File pickedImage;
  String finalSentences;
  String title;
  bool isImportant;
  final CalendarPlugin calendarPlugin = CalendarPlugin();

  @override
  void initState() {
    getUserInfo();
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    getImageUrl();
    super.initState();
    extractedWords = [];
    title = "Add note heading";
    categoryIndex = widget.index == null ? 1 : widget.index;
    isImportant = true;
    FirebaseAdMob.instance.initialize(
//      appId: BannerAd.testAdUnitId,
    appId: AdManager.appId
    );
    bannerAd = createBannerAd()
      ..load()
      ..show();
  }

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }

  final picker = ImagePicker();

  Future PickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = File(pickedFile.path);
    });
    readText();
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

  Future readText() async {
    FirebaseVisionImage image = FirebaseVisionImage.fromFile(pickedImage);
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
            builder: (_) => SpecialNotesEditingPage(
                  description: finalSentences,
                  category: "special_notes",
                )));
  }

  getNotesLength({String email}) {
    databaseMethods.getNotesLength(notesRoomId: email).then((value) {
      notesLengthSnapshot = value;
      setState(() {
        notesLength = notesLengthSnapshot.documents.length;
      });
    });
  }

  getImportantNotes({String email}) {
    databaseMethods.getImportantNotes(notesRoomId: email).then((value) {
      importanNotesStream = value;
    });
  }

  getSpecialNotesLength({String email}) {
    databaseMethods.getSpecialNotesLength(notesRoomId: email).then((value) {
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

  getNotesInfo() async {
    await databaseMethods.getNotes(notesRoomId: email).then((value) {
      setState(() {
        notesStream = value;
        // print(notesStream);
      });
    });
  }

  getUserInfo() async {
    await HelperFunction.getUserNameFromSharedPreference().then((value) {
      setState(() {
        name = value;
        print(name);
      });
    });

    await HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        email = value;
        print(email);
      });
    });
    getNotesInfo();
    getNotesLength(email: email);
    getSpecialNotesLength(email: email);
    getSpecialNotes(email: email);
    getImportantNotes(email: email);
  }

  createNotesRoom() {
    Map<String, dynamic> notesMap = {
      "name": name,
      "email": email,
    };

    databaseMethods.createNoteRoom(notesRoomId: email, notesMap: notesMap);

    databaseMethods.createDeletedNotesRoom(
        deletedRoomId: email, deletedNotesMap: notesMap);
  }

  notesList() {
    return StreamBuilder(
        stream: notesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
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
                                      "Are you sure you want to delete ${snapshot.data.documents[index].data["title"]}?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .backgroundColor),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Map<String, dynamic> deletedNotesMap = {
                                          "title": snapshot.data
                                              .documents[index].data["title"],
                                          "description": snapshot
                                              .data
                                              .documents[index]
                                              .data["description"]
                                        };
                                        databaseMethods.addDeletedNotes(
                                          deletedRoomId: email,
                                          deletedNotesMap: deletedNotesMap,
                                          title: snapshot.data.documents[index]
                                              .data["title"],
                                        );
                                        databaseMethods.deleteNote(
                                            notesRoomId: email,
                                            documentId: snapshot
                                                .data
                                                .documents[index]
                                                .data["title"]);
                                        getNotesLength(email: email);
                                        getSpecialNotesLength(email: email);
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
                      child: ListTile(
                        onLongPress: () {
                          setState(() {
                            if (snapshot
                                    .data.documents[index].data["important"] ==
                                "false") {
                              isImportant = true;
                              Toast.show('Marked As Important', context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.BOTTOM);
                            } else {
                              isImportant = false;
                              Toast.show('Marked As UnImportant', context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.BOTTOM);
                            }
                          });
                          if (isImportant) {
                            Map<String, dynamic> importantMap = {
                              "important": "true"
                            };
                            databaseMethods.addImportantTag(
                                notesRoomId: email,
                                documentTitle: snapshot
                                    .data.documents[index].data["title"],
                                importantMap: importantMap);
                          } else {
                            Map<String, dynamic> importantMap = {
                              "important": "false"
                            };
                            databaseMethods.addImportantTag(
                                notesRoomId: email,
                                documentTitle: snapshot
                                    .data.documents[index].data["title"],
                                importantMap: importantMap);
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
                                        title: snapshot.data.documents[index]
                                            .data["title"],
                                        description: snapshot
                                            .data
                                            .documents[index]
                                            .data["description"],
                                        category: snapshot.data.documents[index]
                                            .data["category"],
                                      )));
                        },
                        title: Text(
                          snapshot.data.documents[index].data["title"]
                              .toString(),
                          style: TextStyle(
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
                          style: TextStyle(
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
                              style: TextStyle(
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
              style: TextStyle(
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
              style: TextStyle(
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
          color: Theme.of(context).backgroundColor,
          height: screenHeight,
          padding: EdgeInsets.only(bottom: 60),
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.08, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfilePage(
                                      name: name,
                                      userEmail: email,
                                      notesLength: notesLength,
                                      specialNotesLength: specialNotesLength,
                                    )));
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                                color: Theme.of(context).indicatorColor,
                                shape: BoxShape.circle),
                            child: imageUrl == null
                                ?Container(
                              child: Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 35,
                                  )),
                            ): ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    )),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            name != null ? name : "",
                            style: TextStyle(
                              color: Theme.of(context).indicatorColor,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.settings,
                        color: Theme.of(context).indicatorColor,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (_) => ProfilePage(
                                      name: name,
                                      userEmail: email,
                                      notesLength: notesLength,
                                      specialNotesLength: specialNotesLength,
                                    )));
                      },
                    ),
                  ],
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
              categoryIndex == 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TabBarV(),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(right: 15.0),
                          child: PopupMenuButton<String>(
                              color: Theme.of(context).primaryColor,
                              onSelected: choiceAction,
                              icon: Icon(Icons.add, color: Colors.white),
                              itemBuilder: (BuildContext context) {
                                return popUpConstants.choices
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(
                                      choice,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList();
                              }),
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: screenWidth * 0.25, height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(right: 15.0),
                          child: PopupMenuButton<String>(
                              color: Theme.of(context).primaryColor,
                              onSelected: choiceAction,
                              icon: Icon(Icons.add, color: Colors.white),
                              itemBuilder: (BuildContext context) {
                                return popUpConstants.choices
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(
                                      choice,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList();
                              }),
                        )
                      ],
                    ),
              categoryIndex == 1
                  ? Expanded(child: TabBarViewWidget())
                  : Expanded(child: specialNotesWidget())
            ],
          )),
    );
  }

  void choiceAction(String choice) {
    if (choice == popUpConstants.normalNotes) {
      createNotesRoom();
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => NotesCreatorPage()));
    } else if (choice == popUpConstants.specialNotes) {
      PickImage();
    } else {
      calendarPlugin.hasPermissions().then((value) {
        if (!value) {
          calendarPlugin.requestPermissions();
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ReminderPage(
                        email: email,
                      )));
        }
      });
    }
  }

  Widget TabBarV() {
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
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor),
              ),
            ),
            Tab(
              child: Text(
                'Important',
                style: TextStyle(
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

  Widget TabBarViewWidget() {
    return TabBarView(controller: tabController, children: [
      notesList(),
      getImportantNotesList(),
//      Container(
//        color: Colors.blue,
//      ),
    ]);
  }

  getSpecialNotes({String email}) {
    databaseMethods.getSpecialNotes(notesRoomId: email).then((value) {
      specialNotesStream = value;
    });
  }

  var notesLengthValue;

  Widget getImportantNotesList() {
    return StreamBuilder(
      stream: importanNotesStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    enabled: true,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NotesDisplayPage(
                                    title: snapshot
                                        .data.documents[index].data["title"],
                                    description: snapshot.data.documents[index]
                                        .data["description"],
                                    category: snapshot
                                        .data.documents[index].data["category"],
                                  )));
                    },
                    title: Text(
                      snapshot.data.documents[index].data["title"].toString(),
                      style: TextStyle(
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
                      style: TextStyle(
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.7),
                          fontSize: 16.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                })
            : Container(
                child: Center(child: Text('No Important Notes yet')),
              );
      },
    );
  }

  Widget specialNotesWidget() {
    return StreamBuilder(
        stream: specialNotesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
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
                                      "Are you sure you want to delete ${snapshot.data.documents[index].data["title"]}?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Map<String, dynamic> deletedNotesMap = {
                                          "title": snapshot.data
                                              .documents[index].data["title"],
                                          "description": snapshot
                                              .data
                                              .documents[index]
                                              .data["description"]
                                        };
                                        databaseMethods.addDeletedNotes(
                                          deletedRoomId: email,
                                          deletedNotesMap: deletedNotesMap,
                                          title: snapshot.data.documents[index]
                                              .data["title"],
                                        );
                                        databaseMethods.deleteNote(
                                            notesRoomId: email,
                                            documentId: snapshot
                                                .data
                                                .documents[index]
                                                .data["title"]);
                                        getNotesLength(email: email);
                                        getSpecialNotesLength(email: email);
                                        getSpecialNotes(email: email);
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
                                  builder: (_) => SpecialNotesEditingPage(
                                        description: snapshot
                                            .data
                                            .documents[index]
                                            .data["description"],
                                        category: snapshot.data.documents[index]
                                            .data["category"],
                                      )));
                        }
                      },
                      child: ListTile(
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
                                        category: snapshot.data.documents[index]
                                            .data["category"],
                                      )));
                        },
                        title: Text(
                          snapshot.data.documents[index].data["title"]
                              .toString(),
                          style: TextStyle(
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
                          style: TextStyle(
                              color: Theme.of(context)
                                  .indicatorColor
                                  .withOpacity(0.7),
                              fontSize: 16.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  })
              : Container(
                  child: Center(
                    child: specialNotesLength != 0 && specialNotesLength != null
                        ? CircularProgressIndicator()
                        : Text("No Special Notes Available"),
                  ),
                );
        });
  }
}

class NotesPageCard extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String textData;
  final int countData;
  int index;

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
      height: screenHeight * 0.24,
      width: screenWidth * 0.42,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: categoryIndex == index
                  ? [Color(0xff5E0035), Color(0xffE22386)]
                  : [Color(0xFFF5F7FB), Color(0xFFF5F7FB)]),
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
                    color: categoryIndex == index ? Colors.white : Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                child: countData != null
                    ? Text(
                        countData.toString(),
                        style: TextStyle(
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
