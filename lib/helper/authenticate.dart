import 'package:flutter/material.dart';
import 'package:notes_app/pages/sign_in.dart';
import 'package:notes_app/pages/sign_up.dart';

class Authenticate extends StatefulWidget {
  Authenticate({Key key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  
  void toggleView(){
    setState(() {
      showSignIn = !showSignIn;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showSignIn){
      return SignInPage(toggle: toggleView);
    }else{
      return SignUpPage(toggle: toggleView);
    }
  }
}