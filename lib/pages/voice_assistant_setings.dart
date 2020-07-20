import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/services/database.dart';

String lang;
double pitch;
double volume;

class VoiceAssistantSettings extends StatefulWidget {
  @override
  _VoiceAssistantSettingsState createState() => _VoiceAssistantSettingsState();
}

class _VoiceAssistantSettingsState extends State<VoiceAssistantSettings> {
  String email;
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

  DatabaseMethods databaseMethods = new DatabaseMethods();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistant Settings',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: screenWidth * 0.065,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Container(
                        color: Theme.of(context).indicatorColor,
                        height: 2,
                        width: screenWidth * 0.6,
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Container(
                        color:
                            Theme.of(context).indicatorColor.withOpacity(0.5),
                        height: 2,
                        width: screenWidth * 0.55,
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        'Customize Your Assistant',
                        style: GoogleFonts.montserrat(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.save,
                          color: Theme.of(context).indicatorColor))
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(color: Colors.black45),
              SizedBox(
                height: 40.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Assistant Language",
                    style: GoogleFonts.montserrat(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 16.0),
                  ),
                  assistantLangDropDownMenu(),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Assistant Pitch",
                    style: GoogleFonts.montserrat(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 16.0),
                  ),
                  assistantPitchDropDownMenu(),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Assistant Volume",
                    style: GoogleFonts.montserrat(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 16.0),
                  ),
                  assistantVolumeDropDownMenu(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget assistantPitchDropDownMenu() {
    return DropdownButton(
      items: [
        DropdownMenuItem(
          child: Text(
            '0.5',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 0.5,
        ),
        DropdownMenuItem(
          child: Text(
            '1.0',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 1.0,
        ),
        DropdownMenuItem(
          child: Text(
            '1.5',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 1.5,
        ),
        DropdownMenuItem(
          child: Text(
            '2.0',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 2.0,
        ),
      ],
      style: GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
      onChanged: (_value) {
        setState(() {
          pitch = _value;
        });
        Map<String, dynamic> updateMap = {"pitch": pitch};
        databaseMethods.updateUserInfo(updateMap: updateMap, email: email);
        HelperFunction.saveAssistantPicthInSharedPreference(pitch);
        print("The pitch is $pitch");
      },
      value: pitch,
      dropdownColor: Theme.of(context).backgroundColor,
    );
  }

  Widget assistantVolumeDropDownMenu() {
    return DropdownButton(
      dropdownColor: Theme.of(context).backgroundColor,
      style: GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
      items: [
        DropdownMenuItem(
          child: Text(
            '0.0',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 0.0,
        ),
        DropdownMenuItem(
          child: Text(
            '0.2',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 0.2,
        ),
        DropdownMenuItem(
          child: Text(
            '0.4',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 0.4,
        ),
        DropdownMenuItem(
          child: Text(
            '0.6',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 0.6,
        ),
        DropdownMenuItem(
          child: Text(
            '0.8',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 0.8,
        ),
        DropdownMenuItem(
          child: Text(
            '1.0',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 1.0,
        ),
      ],
      onChanged: (_value) {
        setState(() {
          volume = _value;
        });
        HelperFunction.saveAssistantVolumeInSharedPreference(volume);
        Map<String, dynamic> updateMap = {
          "volume": volume,
        };
        databaseMethods.updateUserInfo(updateMap: updateMap, email: email);
      },
      value: volume,
    );
  }

  Widget assistantLangDropDownMenu() {
    return DropdownButton(
      dropdownColor: Theme.of(context).backgroundColor,
      style: GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
      items: [
        DropdownMenuItem(
          child: Text(
            'English US',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 'en-US',
        ),
        DropdownMenuItem(
          child: Text(
            'English India',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 'en-IN',
        ),
        DropdownMenuItem(
          child: Text(
            'Hindi',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 'hi-IN',
        ),
        DropdownMenuItem(
          child: Text(
            'Kannada',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 'kn-IN',
        ),
        DropdownMenuItem(
          child: Text(
            'Gujarathi',
            style:
                GoogleFonts.montserrat(color: Theme.of(context).indicatorColor),
          ),
          value: 'gu-IN',
        ),
      ],
      onChanged: (_value) {
        setState(() {
          lang = _value;
        });
        Map<String, dynamic> updateMap = {
          "language": lang,
        };
        databaseMethods.updateUserInfo(updateMap: updateMap, email: email);
        HelperFunction.saveAssistantLangInSharedPreferences(lang);
        print("The selected option is $lang");
      },
      value: lang,
    );
  }
}
