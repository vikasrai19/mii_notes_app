import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/dark_theme_shared_preference.dart';
import 'package:notes_app/helper/policy_dialog.dart';
import 'package:notes_app/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingPage extends StatefulWidget {
  final bool isDarkMode;
  final String name;
  final String userEmail;
  final int notesLength;
  final int specialNotesLength;

  AppSettingPage(
      {this.isDarkMode,
      this.name,
      this.userEmail,
      this.notesLength,
      this.specialNotesLength});

  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
  bool isDark = false;
  bool switchControl = false;
  DarkThemePreference darkThemePreference = DarkThemePreference();

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 20,
    remindDays: 2,
    remindLaunches: 5,
    googlePlayIdentifier: 'com.mii.notes_app',
  );

  @override
  void initState() {
    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showStarRateDialog(context,
            title: 'Enjoying Notes App',
            message: 'Take Some Time And Rate The App',
            actionsBuilder: (context, stars) {
          return [
            FlatButton(
              child: Text(
                'Ok',
                style: GoogleFonts.montserrat(),
              ),
              onPressed: () {
                if (stars != null) {
                  rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
                  rateMyApp.save().then((value) => Navigator.pop(context));
                  print("Thanks for ur rating");
                } else {
                  Navigator.pop(context);
                }
              },
            )
          ];
        },
            starRatingOptions: StarRatingOptions(),
            dialogStyle: DialogStyle(
                contentPadding: EdgeInsets.all(10.0),
                titleAlign: TextAlign.center,
                messageAlign: TextAlign.center));
      }
    });
    setState(() {
      switchControl = widget.isDarkMode;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    void toggleSwitch(bool value) {
      if (switchControl == false) {
        setState(() {
          switchControl = true;
          themeChange.darkTheme = switchControl;
        });
      } else {
        setState(() {
          switchControl = false;
          themeChange.darkTheme = switchControl;
        });
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "App Settings",
                            style: GoogleFonts.montserrat(
                                color: Theme.of(context).indicatorColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.065),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.8),
                            height: 2,
                            width: screenWidth * 0.5,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Container(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.7),
                            height: 2,
                            width: screenWidth * 0.45,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Customize Your App',
                            style: GoogleFonts.montserrat(
                                fontSize: screenWidth * 0.04,
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.4)),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProfilePage(
                                        name: widget.name,
                                        userEmail: widget.userEmail,
                                        notesLength: widget.notesLength,
                                        specialNotesLength:
                                            widget.specialNotesLength,
                                      )));
                        },
                        child: Icon(
                          Icons.save,
                          color: Theme.of(context).indicatorColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: Theme.of(context).indicatorColor.withOpacity(0.5),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Mode',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      Switch(
                        onChanged: toggleSwitch,
                        value: switchControl,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rate Us On PlayStore',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          rateMyApp.showStarRateDialog(context,
                              title: 'Rate App',
                              message: 'Thank You For Rating The App',
                              actionsBuilder: (context, stars) {
                            return [
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  if (stars != null) {
                                    rateMyApp.callEvent(
                                        RateMyAppEventType.rateButtonPressed);
                                    rateMyApp.save().then(
                                        (value) => Navigator.pop(context));
                                    print("Thanks for ur rating");
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                              )
                            ];
                          },
                              starRatingOptions: StarRatingOptions(),
                              dialogStyle: DialogStyle(
                                  contentPadding: EdgeInsets.all(10.0),
                                  titleAlign: TextAlign.center,
                                  messageAlign: TextAlign.center));
                        },
                        child: Icon(
                          Icons.star_half,
                          color: Theme.of(context).indicatorColor,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DM us on Instagram',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          launch('https://instagram.com/_v.i.k.a.s_r.a.i_/');
                        },
                        child: FaIcon(
                          FontAwesomeIcons.instagram,
                          color: Theme.of(context).indicatorColor,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Follow Us On Facebook',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                          onTap: () {
                            launch('https://www.facebook.com/miiappsdev/');
                          },
                          child: FaIcon(
                            FontAwesomeIcons.facebook,
                            color: Theme.of(context).indicatorColor,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Follow Us On Twitter',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                          onTap: () {
                            launch('https://twitter.com/AppsMi');
                          },
                          child: FaIcon(
                            FontAwesomeIcons.twitter,
                            color: Theme.of(context).indicatorColor,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Follow Us On Youtube',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                          onTap: null,
                          child: FaIcon(
                            FontAwesomeIcons.youtube,
                            color: Theme.of(context).indicatorColor,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Privacy Policy',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return PolicyDialog(
                                  fileName: 'privacy_policy.md',
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                              });
                        },
                        child: FaIcon(
                          FontAwesomeIcons.externalLinkAlt,
                          color: Theme.of(context).indicatorColor,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Terms And Conditions',
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return PolicyDialog(
                                  fileName: 'terms_and_conditions.md',
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                              });
                        },
                        child: FaIcon(
                          FontAwesomeIcons.externalLinkAlt,
                          color: Theme.of(context).indicatorColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 55),
                width: screenWidth,
                child: Text(
                  "Created by MII Apps",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).indicatorColor.withOpacity(0.6),
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
