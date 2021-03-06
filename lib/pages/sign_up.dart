import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/dark_theme_shared_preference.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/helper/policy_dialog.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';
import 'package:flutter/animation.dart';

class SignUpPage extends StatefulWidget {
  final Function toggle;

  SignUpPage({Key key, this.toggle}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> signUpScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  bool isLoading = true;
  bool isPolicyShown = false;
  bool isEmailPresent;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  HelperFunction helperFunction = new HelperFunction();
  DarkThemePreference darkThemePreference = DarkThemePreference();

  bool showEmailSnackBar;
  bool isPassHidden;

  Animation animation;
  AnimationController animationController;

  initState() {
    animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();
    isEmailPresent = false;
    showEmailSnackBar = false;
    isPassHidden = true;
    HelperFunction.isEmailAlreadyInUse(false);
    super.initState();
  }

  signUpUser() async {
    List<String> searchStringList = List();
    String temp = "";
    if (formKey.currentState.validate()) {
      authMethods
          .signUpUsingEmail(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        HelperFunction.getIsEmailAlreadyInUse().then((value) {
          setState(() {
            isEmailPresent = value;
          });
        });

        if (value != null) {
          setState(() {
            showEmailSnackBar = true;
          });

          for (int j = 0; j < emailController.text.length; j++) {
            temp = temp + emailController.text[j];
            searchStringList.add(temp);
          }
          Map<String, dynamic> userInfoMap = {
            "name": nameController.text,
            "userEmail": emailController.text,
            "isCheckedPolicy": false,
            "isCheckedTermsAndCondition": false,
            "language": "en-IN",
            "pitch": 1.0,
            "volume": 1.0,
            "searchTerm": searchStringList,
            "imageUrl": null
          };

          databaseMethods.uploadUserInfo(
              email: emailController.text, userMap: userInfoMap);
          Map<String, dynamic> roomDataMap = {
            "email": emailController.text,
            "friends": []
          };
          databaseMethods.createFriendsRoom(
              roomId: emailController.text, roomDataMap: roomDataMap);

          showDialog(
              context: context,
              builder: (context) {
                return PolicyDialog(
                    fileName: 'privacy_policy.md',
                    onPressed: () {
                      Map<String, dynamic> policyMap = {
                        "isCheckedPolicy": true
                      };
                      databaseMethods.updateUserInfo(
                          email: emailController.text, updateMap: policyMap);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PolicyDialog(
                              fileName: 'terms_and_conditions.md',
                              onPressed: () {
                                Map<String, dynamic> termsMap = {
                                  "isCheckedTermsAndCondition": true
                                };
                                databaseMethods.updateUserInfo(
                                    email: emailController.text,
                                    updateMap: termsMap);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            );
                          });
                    });
              });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            backgroundColor: Colors.black87,
            key: signUpScaffoldKey,
            body: Transform(
              transform: Matrix4.translationValues(
                  0.0, animation.value * screenWidth, 0),
              child: Container(
                // margin: EdgeInsets.only(bottom: 65),
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
                        Text("Sign Up",
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: screenHeight * 0.15),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (val) {
                                  return val.length > 3 ? null : "Enter Name";
                                },
                                controller: nameController,
                                obscureText: false,
                                textCapitalization: TextCapitalization.words,
                                style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 16.0),
                                decoration: InputDecoration(
                                    hintText: "Name",
                                    hintStyle: GoogleFonts.montserrat(
                                        color: Colors.grey),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )),
                              ),
                              SizedBox(height: 20.0),
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
                                      color: Colors.white, fontSize: 16.0),
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
                                obscureText: isPassHidden,
                                style: GoogleFonts.montserrat(
                                    color: Colors.white, fontSize: 16.0),
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: GoogleFonts.montserrat(
                                        color: Colors.grey),
                                    suffix: GestureDetector(
                                      child: Icon(
                                        Icons.remove_red_eye,
                                        color: isPassHidden
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isPassHidden = !isPassHidden;
                                        });
                                      },
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
                        GestureDetector(
                          onTap: () {
                            final initialSnackBar = SnackBar(
                              content: Text("Loading .. please wait"),
                              duration: Duration(seconds: 1),
                            );
                            signUpScaffoldKey.currentState
                                .showSnackBar(initialSnackBar);
                            signUpUser();

                            final emailSnackbar = SnackBar(
                              content: Text(
                                  'Please check your email for verification'),
                              duration: Duration(seconds: 7),
                            );
                            final isEmailPresentSnackBar = SnackBar(
                              content: Text('This email is already registered'),
                              duration: Duration(seconds: 5),
                            );
                            if (isEmailPresent == false ||
                                showEmailSnackBar == true) {
                              signUpScaffoldKey.currentState
                                  .showSnackBar(emailSnackbar);
                            } else if (isEmailPresent == true ||
                                showEmailSnackBar == false) {
                              signUpScaffoldKey.currentState
                                  .showSnackBar(isEmailPresentSnackBar);
                            }
                            // : Container();
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
                              "Sign Up",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white, fontSize: 16.0),
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
                        //     "Sign Up With Google",
                        //     style: TextStyle(fontSize: 16.0, color: Colors.black),
                        //   ),
                        // ),
                        SizedBox(height: 80),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have account? ",
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.toggle();
                              },
                              child: Text(
                                "Login Now",
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
