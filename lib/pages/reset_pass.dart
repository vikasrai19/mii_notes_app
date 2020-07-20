import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/services/auth.dart';
import 'package:flutter/animation.dart';

class ResetPassWordPage extends StatefulWidget {
  @override
  _ResetPassWordPageState createState() => _ResetPassWordPageState();
}

class _ResetPassWordPageState extends State<ResetPassWordPage> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AuthMethods authMethods = new AuthMethods();

  TextEditingController emailController = new TextEditingController();

  Animation animation;
  AnimationController animationController;

  @override
  void initState(){
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin:1.0, end:0.0).animate(
      CurvedAnimation(
        parent:animationController,
        curve: Curves.fastLinearToSlowEaseIn
      )
    );
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {

    final double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animation,
      builder:(BuildContext context, Widget child){
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.black87,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
              child: Transform(
                transform: Matrix4.translationValues(animation.value * screenWidth,0.0,0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Text(
                          "Reset Password",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                        Form(
                          key: formKey,
                          child: TextFormField(
                              validator: (val) {
                                return RegExp(
                                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                    .hasMatch(val)
                                    ? null
                                    : "Please enter valid email";
                              },
                              style: TextStyle(color: Colors.white),
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle:
                                  GoogleFonts.montserrat(color: Colors.grey),
                                  prefixIcon:
                                  Icon(Icons.email, color: Colors.white))),
                        ),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () {
                            authMethods.resetPass(email: emailController.text);
                            final snackBar = SnackBar(
                              content: Text("Passowrd Reset Link Has Been Sent",
                                  style: GoogleFonts.montserrat()),
                            );
                            if (formKey.currentState.validate()) {
//                  authMethods.resetPass(email: emailController.text);
                              _scaffoldKey.currentState.showSnackBar(snackBar);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Color(0xff5E0035), Color(0xffE22386)]),
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Text(
                              "Send Password Reset Link",
                              style: GoogleFonts.montserrat(
                                  fontSize: 16.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
