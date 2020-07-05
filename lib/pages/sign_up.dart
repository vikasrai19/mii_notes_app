import 'package:flutter/material.dart';
import 'package:notes_app/helper/authenticate.dart';
import 'package:notes_app/helper/dark_theme_shared_preference.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/helper/policy_dialog.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';

import 'homepage.dart';

class SignUpPage extends StatefulWidget {
  final Function toggle;

  SignUpPage({Key key, this.toggle}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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

  initState() {
    isEmailPresent = false;
    super.initState();
  }

  signMeUp() async {
    if (formKey.currentState.validate()) {
      await authMethods
          .signUpUsingEmail(
              email: emailController.text, password: passwordController.text)
          .then((value) async{
        Map<String, dynamic> userInfoMap = {
          "userEmail": emailController.text,
          "name": nameController.text,
          "language": "en-US",
          "pitch": 1.0,
          "volume": 1.0
        };
//        HelperFunction.saveUserEmailInSharedPreference(emailController.text);
//        HelperFunction.saveNameInSharedPreference(nameController.text);
//        HelperFunction.saveUserLoggedInSharedPreference(true);
//        HelperFunction.saveAssistantLangInSharedPreferences('en-US');
//        HelperFunction.saveAssistantPicthInSharedPreference(1.0);
//        HelperFunction.saveAssistantVolumeInSharedPreference(1.0);
//        darkThemePreference.setDarkTheme(false);
//
        await HelperFunction.getIsEmailAlreadyInUse().then((value) {
          if(value == true){
            databaseMethods.uploadUserInfo(
                userMap: userInfoMap, email: emailController.text);
          }
        });
      });

      await HelperFunction.getIsEmailAlreadyInUse().then((value) {
        setState(() {
          isEmailPresent = value;
        });
      });
      if (isEmailPresent == true) {
        Future.delayed(Duration(seconds: 1), () {
          showDialog(
              context: context,
              builder: (context) {
                return PolicyDialog(
                    fileName: 'privacy_policy.md',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PolicyDialog(
                              fileName: 'terms_and_conditions.md',
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState(() {
                                  isPolicyShown = true;
                                });
                              },
                            );
                          });
                    });
              });
        });

        setState(() {
          isLoading = true;
        });
      }
//      Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>Authenticate()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: signUpScaffoldKey,
      body: Container(
        alignment: Alignment.bottomCenter,
        color: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Name",
                            hintStyle: TextStyle(color: Colors.white),
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
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.white),
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.white))),
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) {
                          return val.length > 6
                              ? null
                              : "Enter password with more than 6 characters";
                        },
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white),
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
                  onTap: () async {
                    await signMeUp();
                    final snackBar = SnackBar(
                      content: Text('Check Your email'),
                      duration: Duration(seconds: 2),
                    );
                    final errorSnackBar = SnackBar(
                      content: Text(
                        'Email Already In User',
                      ),
                      duration: Duration(seconds: 2),
                    );
                    isEmailPresent
                        ? signUpScaffoldKey.currentState
                            .showSnackBar(snackBar)
                        : signUpScaffoldKey.currentState.showSnackBar(errorSnackBar);
                    HelperFunction.isEmailAlreadyInUse(false);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    width: screenWidth,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff5E0035), Color(0xffE22386)]),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Text(
                        "Login Now",
                        style: TextStyle(
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
    );
  }
}
