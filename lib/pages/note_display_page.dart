import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/notes_editing_page.dart';
import 'package:share/share.dart';

import 'homepage.dart';

bool isClicked;

class NotesDisplayPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;

  NotesDisplayPage({Key key, this.title, this.description, this.category})
      : super(key: key);

  @override
  _NotesDisplayPageState createState() => _NotesDisplayPageState();
}

class _NotesDisplayPageState extends State<NotesDisplayPage> {
  FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  String lang;
  double pitch;
  double volume;

  double _width = 50;
  double _height = 50;
  double _width2 = 50;
  double _height2 = 50;
  double _rightPosition = 20;
  double _bottomPosition = 65;
  BorderRadius _borderRadius = BorderRadius.circular(25);

  @override
  void initState() {
    isClicked = false;
    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        email = value;
      });
      print(email);
    });
    HelperFunction.getAssistantLangInSharedPreference().then((value) {
      setState(() {
        lang = value;
      });
    });
    HelperFunction.getAssistantPitchInSharedPreference().then((value) {
      setState(() {
        pitch = value;
      });
    });
    HelperFunction.getAssistantVolumeInSharedPreference().then((value) {
      setState(() {
        volume = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    speak({String text}) async {
      await flutterTts.setVolume(volume);
      await flutterTts.setLanguage(lang);
      await flutterTts.setPitch(pitch);
      print(await flutterTts.getVoices);
      setState(() {
        isPlaying = true;
      });
      await flutterTts.speak(text);
      flutterTts.setCompletionHandler(() {
        setState(() {
          isPlaying = false;
        });
      });
    }

    stop() async {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
      });
    }

    shareNotes({String title, String desc}) {
      final shareString = title + "\n" + desc;
      Share.share(shareString, subject: title);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            SafeArea(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, bottom: 55, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  widget.category,
                                  style: GoogleFonts.grenze(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
//                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => HomePage(index: 1)),
                                (route) => false);
                          },
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
                                  colors: [Color(0xff1f5cfc), Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                            ),
                            child: Icon(Icons.done, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      width: screenWidth * 0.50,
                      child: AutoSizeText(
                        widget.title,
                        maxLines: 1,
                        minFontSize: 18,
                        maxFontSize: 25.0,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                        if (isPlaying) {
                          speak(text: widget.description);
                        } else {
                          stop();
                        }
                      },
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.description,
                          style: GoogleFonts.montserrat(
                              color: Theme.of(context).indicatorColor,
                              fontSize: 18.0,
                              wordSpacing: 5.0),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
            Stack(
              children: [
                Positioned(
                    right: 20,
                    bottom: 65,
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
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        stop();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    NotesEditingPage(
                                                      title: widget.title,
                                                      category: widget.category,
                                                      description:
                                                          widget.description,
                                                    )));
                                      },
                                      child: Icon(
                                        Icons.brush,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    FaIcon(FontAwesomeIcons.whatsapp,
                                        color: Colors.white),
                                    SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () {
                                        stop();
                                        shareNotes(
                                            title: widget.title,
                                            desc: widget.description);
                                      },
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container())),
                AnimatedPositioned(
                    duration: Duration(milliseconds: 100),
                    bottom: _bottomPosition,
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
                                    _bottomPosition = 65;
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
                                    _width = 175;
                                    _rightPosition = 25;
                                    _bottomPosition = 70;
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
                              ))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
