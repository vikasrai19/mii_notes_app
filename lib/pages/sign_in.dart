import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/pages/reset_pass.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';

import 'homepage.dart';

class SignInPage extends StatefulWidget {
  final Function toggle;

  SignInPage({Key key, this.toggle}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<ScaffoldState> signInScaffoldKey = new GlobalKey<ScaffoldState>();
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

  initState(){
    isHidden = true;
    HelperFunction.saveUserEmailCorrectState(true);
    HelperFunction.saveUserPasswordCorrectState(true);
    HelperFunction.saveIsValidAttemptState(true);
    super.initState();
  }

  signIn() {

//    setState((){
//      isEmailCorrect = true;
//      isPasswordCorrect = true;
//    });
    if (formKey.currentState.validate()) {

      authMethods.SignInUsingEmail(
              email: emailController.text, password: passwordController.text)
          .then((value) async{

            await HelperFunction.getUserPasswordCorrectState().then((value) {
              setState(() {
                isPasswordCorrect = value;
              });
            });

            await HelperFunction.getUserEmailCorrectState().then((value) {
              setState(() {
                isEmailCorrect = value;
              });
            });

            await HelperFunction.getUserAttemptState().then((value) {
              setState(() {
                isValidAttempt = value;
              });
            });
        if (isPasswordCorrect == true && isEmailCorrect == true && value != null) {
          HelperFunction.saveUserEmailInSharedPreference(emailController.text);

          databaseMethods
              .getUserByUserEmail(email: emailController.text)
              .then((val) {
            snapshotUserInfo = val;
            HelperFunction.saveNameInSharedPreference(
                snapshotUserInfo.documents[0].data["name"]);
            HelperFunction.saveUserEmailInSharedPreference(
                snapshotUserInfo.documents[0].data["userEmail"]);
            HelperFunction.saveAssistantLangInSharedPreferences(
                snapshotUserInfo.documents[0].data['language']);
            HelperFunction.saveAssistantPicthInSharedPreference(
                snapshotUserInfo.documents[0].data["pitch"]);
            HelperFunction.saveAssistantVolumeInSharedPreference(snapshotUserInfo.documents[0].data["volume"]);
          });

          await databaseMethods
              .getProfilePhotoByEmail(email: emailController.text)
              .then((value) {
            setState(() {
              imageSnapshot = value;
              HelperFunction.saveUserProfileImageInSharedPreference(
                  imageSnapshot.documents[0].data["imageUrl"]);
            });
          });

          setState(() {
            isLoading = true;
          });

          HelperFunction.saveUserLoggedInSharedPreference(true);
          HelperFunction.saveUserEmailCorrectState(true);
          HelperFunction.saveUserPasswordCorrectState(true);
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

    return Scaffold(
      key: signInScaffoldKey,
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
                  "Sign In",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
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
                        obscureText: isHidden,
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white),
                            suffix:GestureDetector(
                              onTap: (){
                                setState(() {
                                  isHidden = !isHidden;
                                });
                              },
                              child: Icon(
                                Icons.remove_red_eye,
                                color: isHidden ? Colors.grey.withOpacity(0.5): Colors.white,
                              ),
                            ) ,
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
                          MaterialPageRoute(
                              builder: (_) => ResetPassWordPage()));
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        "Forgot Password ?",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () async {
                    await signIn();
                    final validCredentialsSnackBar = SnackBar(
                      content: Text('Signing In'),
                      duration: Duration(seconds: 3),
                    );
                    final validAttempSnackBar = SnackBar(
                      content: Text('Please try after some time'),
                      duration: Duration(seconds: 5),
                    );
                    final emailSnackBar = SnackBar(
                      content: Text('Please enter correct email'),
                      duration: Duration(seconds: 5),
                    );
                    final passwordSnackBar = SnackBar(
                      content:Text("Please enter a correct password"),
                      duration: Duration(seconds: 5),
                    );
                    final mixedSnackBar = SnackBar(
                      content: Text("Check Your Login Details"),
                      duration: Duration(seconds: 5),
                    );
                    if(isValidAttempt == true && isPasswordCorrect == true && isEmailCorrect == true){
                      signInScaffoldKey.currentState.showSnackBar(validCredentialsSnackBar);
                    } else if(isValidAttempt == false){
                      signInScaffoldKey.currentState.showSnackBar(validAttempSnackBar);
                    } else if(isPasswordCorrect == false && isEmailCorrect == false){
                      signInScaffoldKey.currentState.showSnackBar(mixedSnackBar);
                    }else if(isEmailCorrect == false){
                      signInScaffoldKey.currentState.showSnackBar(emailSnackBar);
                    }else if(isPasswordCorrect == false){
                      signInScaffoldKey.currentState.showSnackBar(passwordSnackBar);
                    }
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
                      "Sign In",
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
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Text(
                        "Register Now",
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
