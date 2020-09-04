import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:receipt_management/constants.dart';
import 'package:receipt_management/screens/landingPage.dart';
import 'package:receipt_management/screens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
   Timer(Duration(seconds: 2),(){
      Firebase.initializeApp().then((value)async{
        User currentUser= FirebaseAuth.instance.currentUser;
        SharedPreferences prefs=await SharedPreferences.getInstance();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>currentUser!=null?LandingScreen(user:currentUser,name: prefs.getString('name'),):LoginScreen()), (route) => false);
      });
   }); 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SafeArea(
              child: Column(
         mainAxisAlignment: MainAxisAlignment.spaceAround, 
         children: [
          Text('BEECEIPTS',style: kHeadingStyle.copyWith(color:Colors.white),textAlign: TextAlign.center),
          SpinKitThreeBounce(
           color: Colors.white, 
          )
         ],
        ),
      ),
    );
  }
}