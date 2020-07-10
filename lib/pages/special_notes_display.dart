import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/notes_editing_page.dart';
import 'package:notes_app/pages/special_notes_creation.dart';
import 'package:notes_app/pages/special_notes_editing.dart';
import 'package:share/share.dart';

import 'homepage.dart';

class SpecialNotesDisplayPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  SpecialNotesDisplayPage(
      {Key key, this.title, this.description, this.category})
      : super(key: key);

  @override
  _SpecialNotesDisplayPageState createState() =>
      _SpecialNotesDisplayPageState();
}

class _SpecialNotesDisplayPageState extends State<SpecialNotesDisplayPage> {
  FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  String lang;
  double pitch;
  double volume;

  @override
  void initState() {
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
      final shareString = "${title}\n${desc}";
      Share.share(shareString, subject: title);
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        height: screenHeight,
        width: screenWidth,
        child: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        widget.category,
                        style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 16.0),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            shareNotes(
                                title: widget.title, desc: widget.description);
                          },
                          child: Icon(Icons.share,
                              color: Theme.of(context).indicatorColor),
                        ),
                        SizedBox(width: 25.0),
                        GestureDetector(
                          onTap: () {
                            stop();
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => HomePage()));
                          },
                          child: Icon(Icons.done,
                              color: Theme.of(context).indicatorColor),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: screenWidth * 0.50,
                      child: AutoSizeText(
                        widget.title,
                        maxLines: 1,
                        minFontSize: 18,
                        maxFontSize: 25.0,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SpecialNotesEditingPage(
                                      title: widget.title,
                                      description: widget.description,
                                      category: widget.category,
                                    )));
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ],
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
                      style: TextStyle(
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
      ),
    );
  }
}
