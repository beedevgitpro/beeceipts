import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:receipt_management/components/loader.dart';
import 'package:receipt_management/components/responsiveText.dart';
import 'package:receipt_management/constants.dart';
import 'package:receipt_management/screens/registrationScreen.dart';
import 'package:receipt_management/screens/landingPage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey=GlobalKey<FormState>();
  final firebaseAuth=FirebaseAuth.instance;
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  @override
  void initState() {
    super.initState();
  }
  void showAlert(String title,String description){
    Alert(
      style: AlertStyle(
       isCloseButton: false, 
      ),
      context: context,
      title: title,
      desc: description,
      buttons: [
        DialogButton(child: Text('CLOSE',style: TextStyle(color:Colors.white)), onPressed:(){
          Navigator.of(context).pop();
        })
      ]
    ).show();
  }
  void loginUser()async {
    final loader=Loader(context);
    if(_loginFormKey.currentState.validate())
    try{
      loader.show();
    final _auth=await firebaseAuth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
     FirebaseFirestore.instance.collection('users').doc(_auth.user.email).get().then((doc){
        print(doc.data()['name']);
        SharedPreferences.getInstance().then((prefs)async{
          bool done=await prefs.setString('name',doc.data()['name'].split(' ')[0]);
          if(done)
          {
            loader.hide();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LandingScreen(user: _auth.user,name: doc.data()['name'].split(' ')[0],)),(r)=>false);
          }
        });
        
    });
    }on FirebaseAuthException catch(e){
      loader.hide();
      print(e.message);
      showAlert('Invalid Credentials', e.message);
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onPanDown: (_){
            FocusScope.of(context).requestFocus(FocusNode());
          },
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: [
              Text('BEECEIPTS',style: kHeadingStyle.copyWith(color:Theme.of(context).accentColor),textAlign: TextAlign.center,),
             buildLoginForm(context)
           ], 
          ),
        ),
      ),
    );
  }

  Form buildLoginForm(BuildContext context) {
    return Form(
             key:_loginFormKey,
             child: GestureDetector(
               onPanDown: (_){
                    FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Padding(
                     padding: EdgeInsets.symmetric(horizontal:20.0),
                     child: buildTextFormField(context,'Email Address',emailController),
                   ),
                   Padding(
                     padding:EdgeInsets.all(20.0),
                     child: buildTextFormField(context,'Password',passwordController,obscureText: true),
                   ),
                   buildLoginButton(context),
                   buildRegisterText(context)
                 ],
               ),
             ),
           );
  }

  Padding buildRegisterText(BuildContext context) {
    return Padding(
                   padding: EdgeInsets.symmetric(vertical:18.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text('Don\'t have an account?',style: TextStyle(fontSize: getFontSize(context,-2))),
                       GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>RegistrationScreen()));
                         },
                         child: Text(' Register',style: TextStyle(color: Theme.of(context).accentColor,fontSize: getFontSize(context,-2),fontWeight: FontWeight.w400))),
                     ],
                   ),
                 );
  }

  Padding buildLoginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:20.0),
      child: FlatButton(
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color:Colors.black) 
                       ),
                       color: Theme.of(context).accentColor,
                       onPressed: 
                              loginUser
                     , child: Padding(
                       padding:  EdgeInsets.all(15.0),
                       child: Text('LOGIN',style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.w600,
                         fontSize: getFontSize(context,2),
                       ),),
                     )),
    );
  }

  TextFormField buildTextFormField(BuildContext context,String labelText,TextEditingController controller,{bool obscureText=false}) {
    return TextFormField(
                       cursorColor: Theme.of(context).primaryColor,
                       obscureText: obscureText,
                       decoration: buildInputDecoration(labelText, context),
                       controller: controller,
                       validator: (value){
                         if(value.isEmpty)
                          return '$labelText Required';
                          return null;
                       },
                     );
  }

  InputDecoration buildInputDecoration(String labelText, BuildContext context) {
    return InputDecoration(
                       labelText: labelText,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Theme.of(context).primaryColor),
                       borderRadius: BorderRadius.circular(10) 
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Theme.of(context).primaryColor),
                       borderRadius: BorderRadius.circular(10)
                      ),
                      errorBorder:  OutlineInputBorder(
                        borderSide: BorderSide(color:Colors.red),
                       borderRadius: BorderRadius.circular(10)
                      ),
                      focusedErrorBorder:  OutlineInputBorder(
                        borderSide: BorderSide(color:Colors.red),
                       borderRadius: BorderRadius.circular(10)
                      ),
                     );
  }
}