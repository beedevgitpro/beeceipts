import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receipt_management/constants.dart';
import 'package:receipt_management/screens/splashScreen.dart';

void main(){
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));
  runApp(ReceiptManagementApp());
  
  }

class ReceiptManagementApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
       accentColor: kAccentColor,
       primaryColor: kAccentColor 
      ),
      home: SplashScreen());
  }
}