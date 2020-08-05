import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/services/database.dart';
import 'package:notes_app/services/user.dart';

DatabaseMethods databaseMethods = new DatabaseMethods();
bool isEmailCorrect;
bool isPasswordCorrect;
bool isValidAttempt;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userFromFirebase(FirebaseUser user) {
    // return user != null ? User(userId: user.uid) : null;
    return user != null ? user.uid : null;
  }

  Future signInUsingEmail({String email, String password}) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = authResult.user;
      if (user.isEmailVerified) {
        String userUid = userFromFirebase(user);
        HelperFunction.saveUserUidInSharedPreferences(userUid);
        print("User uid is " + userUid);
        HelperFunction.saveUserPasswordCorrectState(true);
        HelperFunction.saveUserEmailCorrectState(true);
        HelperFunction.saveIsValidAttemptState(true);
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      if (Platform.isAndroid) {
        switch (e.message) {
          case 'The password is invalid or the user does not have a password.':
            HelperFunction.saveUserPasswordCorrectState(false);
            break;
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            HelperFunction.saveUserEmailCorrectState(false);
            break;
          case 'We have blocked all requests from this device due to unusual activity. Try again later. [ Too many unsuccessful login attempts. Please try again later. ]':
            HelperFunction.saveIsValidAttemptState(false);
        }
      }
    }
  }

  // Future SignInUsingEmail({String email, String password}) async {
  //   try {
  //     AuthResult result = await _auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     FirebaseUser firebaseUser = result.user;
  //     if (firebaseUser.isEmailVerified) {
  //       HelperFunction.saveUserPasswordCorrectState(true);
  //       HelperFunction.saveUserEmailCorrectState(true);
  //       HelperFunction.saveIsValidAttemptState(true);
  //       return _userFromFirebase(firebaseUser);
  //     }
  //     return null;
  //   } catch (e) {
  //     print(e.toString());
  //     if (Platform.isAndroid) {
  //       switch (e.message) {
  //         case 'The password is invalid or the user does not have a password.':
  //           HelperFunction.saveUserPasswordCorrectState(false);
  //           break;
  //         case 'There is no user record corresponding to this identifier. The user may have been deleted.':
  //           HelperFunction.saveUserEmailCorrectState(false);
  //           break;
  //         case 'We have blocked all requests from this device due to unusual activity. Try again later. [ Too many unsuccessful login attempts. Please try again later. ]':
  //           HelperFunction.saveIsValidAttemptState(false);
  //           break;
  //       }
  //     }
  //   }
  // }

  Future signUpUsingEmail({String email, String password}) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = authResult.user;
      HelperFunction.isEmailAlreadyInUse(false);
      user.sendEmailVerification();
      return user.uid;
    } catch (e) {
      print(e.toString());
      if (e is PlatformException) {
        if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          HelperFunction.isEmailAlreadyInUse(true);
        }
      }
    }
  }

//   Future signUpUsingEmail({String email, String password}) async{
//     try{
//       AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//       FirebaseUser firebaseUser = result.user;
//       await databaseMethods.checkEmaIlId(email: email).then((value){
//         if(value != null){
//           firebaseUser.sendEmailVerification();
//           if(firebaseUser.isEmailVerified) return firebaseUser.uid;
//           HelperFunction.isEmailAlreadyInUse(true);
//           return null;
//         }else{
//           print("Email already exists");
//           HelperFunction.isEmailAlreadyInUse(false);
//           return null;
//         }
//       });
//       firebaseUser.sendEmailVerification();
//       if(firebaseUser.isEmailVerified) return firebaseUser.uid;
//       return null;
// //      return _userFromFirebase(firebaseUser);
//     }catch(e){
//       print(e.toString());
//       if(e is PlatformException){
//         if(e.code == 'ERROR_EMAIL_ALREADY_IN_USE'){
// //          print("email already exists");
// //        HelperFunction.isEmailAlreadyInUse(true);
//         }
//       }
//     }
//   }

  Future resetPass({String email}) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
