import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/reset_pass.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';
import 'package:flutter/animation.dart';

import 'homepage.dart';

class SignInPage extends StatefulWidget {
  final Function toggle;

  SignInPage({Key key, this.toggle}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> signInScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  final AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  bool isLoading = true;
  QuerySnapshot snapshotUserInfo;
  QuerySnapshot imageSnapshot;
  bool isEmailCorrect;
  bool isPasswordCorrect;
  bool isValidAttempt;
  bool isHidden;

  bool isSecondEmailValid;
  bool isSecondAttemptValid;
  bool isSecondPassValid;

  Animation animation;
  AnimationController animationController;
  QuerySnapshot noAdsSnapshot;

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();
    isHidden = true;
    isSecondEmailValid = false;
    isSecondAttemptValid = true;
    isSecondPassValid = false;
    HelperFunction.saveUserEmailCorrectState(true);
    HelperFunction.saveUserPasswordCorrectState(true);
    HelperFunction.saveIsValidAttemptState(true);
    super.initState();
  }

  userSignIn() {
    if (formKey.currentState.validate()) {
      authMethods
          .signInUsingEmail(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        HelperFunction.getUserAttemptState().then((value) {
          setState(() {
            isValidAttempt = value;
          });
        });

        HelperFunction.getUserEmailCorrectState().then((value) {
          setState(() {
            isEmailCorrect = value;
          });
        });

        // databaseMethods.getNoAdsList(email: emailController.text).then((value) {
        //   if (value != null) {
        //     HelperFunction.saveUserAdsPrevInSharedPreference(false);
        //   } else {
        //     HelperFunction.saveUserAdsPrevInSharedPreference(true);
        //   }
        // });

        HelperFunction.getUserPasswordCorrectState().then((value) {
          setState(() {
            isPasswordCorrect = value;
          });
        });
        if (value != null) {
          setState(() {
            isSecondEmailValid = true;
            isSecondAttemptValid = true;
            isSecondPassValid = true;
          });

          HelperFunction.saveUserLoggedInSharedPreference(true);
          HelperFunction.saveUserEmailInSharedPreference(emailController.text);

          // databaseMethods
          //     .getUserByUserEmail(email: emailController.text)
          //     .then((val) {
          //   snapshotUserInfo = val;
          //   HelperFunction.saveUserEmailInSharedPreference(
          //       emailController.text);
          //   HelperFunction.saveNameInSharedPreference(
          //       snapshotUserInfo.documents[0].data["name"]);
          //   HelperFunction.saveAssistantLangInSharedPreferences(
          //       snapshotUserInfo.documents[0].data["language"]);
          //   HelperFunction.saveAssistantPicthInSharedPreference(
          //       snapshotUserInfo.documents[0].data["pitch"]);
          //   HelperFunction.saveAssistantVolumeInSharedPreference(
          //       snapshotUserInfo.documents[0].data["volume"]);
          // });
          // databaseMethods
          //     .getProfilePhotoByEmail(email: emailController.text)
          //     .then((val) {
          //   imageSnapshot = val;
          //   HelperFunction.saveUserProfileImageInSharedPreference(
          //       imageSnapshot.documents[0].data['imageUrl']);
          // });

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomePage(
                        index: 1,
                      )));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            backgroundColor: Colors.black87,
            key: signInScaffoldKey,
            body: Transform(
              transform: Matrix4.translationValues(
                  animation.value * screenWidth, 0.0, 0.0),
              child: Container(
                alignment: Alignment.bottomCenter,
                color: Colors.black87,
                padding: EdgeInsets.symmetric(vertical: 60.0),
                child: SingleChildScrollView(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Sign In",
                          style: GoogleFonts.montserrat(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          // style: TextStyle(
                          //   color: Colors.white,
                          //   fontSize: 30.0,
                          //   fontWeight: FontWeight.bold,
                          // ),
                        ),
                        SizedBox(height: screenHeight * 0.2),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  validator: (val) {
                                    return RegExp(
                                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                            .hasMatch(val)
                                        ? null
                                        : "Please enter valid email";
                                  },
                                  controller: emailController,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16.0, color: Colors.white),
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      hintStyle: GoogleFonts.montserrat(
                                          color: Colors.grey),
                                      prefixIcon: Icon(Icons.email,
                                          color: Colors.white))),
                              SizedBox(height: 20.0),
                              TextFormField(
                                validator: (val) {
                                  return val.length > 6
                                      ? null
                                      : "Enter password with more than 6 characters";
                                },
                                controller: passwordController,
                                obscureText: isHidden,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16.0, color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: GoogleFonts.montserrat(
                                        color: Colors.grey),
                                    suffix: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isHidden = !isHidden;
                                        });
                                      },
                                      child: Icon(
                                        Icons.remove_red_eye,
                                        color: isHidden
                                            ? Colors.grey.withOpacity(0.5)
                                            : Colors.white,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25.0),
                        Container(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => ResetPassWordPage()));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                "Forgot Password ?",
                                style:
                                    GoogleFonts.montserrat(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () {
                            final initialSnackBar = SnackBar(
                              content: Text("Loading .. please wait"),
                              duration: Duration(seconds: 1),
                            );
                            signInScaffoldKey.currentState
                                .showSnackBar(initialSnackBar);
                            userSignIn();

                            final loginSnackBar = SnackBar(
                              content: Text('Signing in'),
                              duration: Duration(seconds: 3),
                            );

                            final passwordSnackBar = SnackBar(
                              content: Text('Please enter a correct password'),
                              duration: Duration(seconds: 3),
                            );
                            final emailSnackBar = SnackBar(
                              content: Text('Please check your credentials'),
                              duration: Duration(seconds: 3),
                            );
                            final validAttemptSnackBar = SnackBar(
                              content: Text('Please try after some time'),
                              duration: Duration(seconds: 3),
                            );

                            if (isValidAttempt == true &&
                                isEmailCorrect == true &&
                                isPasswordCorrect == true &&
                                isSecondEmailValid == true &&
                                isSecondAttemptValid == true &&
                                isSecondPassValid == true) {
                              signInScaffoldKey.currentState
                                  .showSnackBar(loginSnackBar);
                            } else if (isPasswordCorrect == false &&
                                isSecondPassValid == false) {
                              signInScaffoldKey.currentState
                                  .showSnackBar(passwordSnackBar);
                            } else if (isEmailCorrect == false &&
                                isSecondEmailValid == false) {
                              signInScaffoldKey.currentState
                                  .showSnackBar(emailSnackBar);
                            } else if (isValidAttempt == false &&
                                isSecondAttemptValid == false) {
                              signInScaffoldKey.currentState
                                  .showSnackBar(validAttemptSnackBar);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            width: screenWidth,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Color(0xff1f5cfc), Colors.blue]),
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.montserrat(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                          ),
                        ),
                        // SizedBox(height: 20.0),
                        // Container(
                        //   padding: EdgeInsets.symmetric(vertical: 20.0),
                        //   width: screenWidth,
                        //   alignment: Alignment.center,
                        //   decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(50.0)),
                        //   child: Text(
                        //     "Sign In With Google",
                        //     style: TextStyle(fontSize: 16.0, color: Colors.black),
                        //   ),
                        // ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have account? ",
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.toggle();
                              },
                              child: Text(
                                "Register Now",
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
