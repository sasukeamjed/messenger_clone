import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messenger_clone/helperfunctions/sharedpref_helper.dart';
import 'package:messenger_clone/services/database.dart';
import 'package:messenger_clone/views/home.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    try{
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount =
      await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      UserCredential result =
      await _firebaseAuth.signInWithCredential(credential);

      User userDetails = result.user;

      if (result != null) {
        SharedPreferenceHelper().saveUserEmail(userDetails.email);
        SharedPreferenceHelper().saveUserId(userDetails.uid);
        SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
        SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);

        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "username": userDetails.email.replaceAll("@gmail.com", ""),
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL
        };

        DatabaseMethods()
            .addUserInfoToDB(userDetails.uid, userInfoMap)
            .then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        });
      }
    }catch(e){
      print("This is the catch error message: $e");
    }

  }
}