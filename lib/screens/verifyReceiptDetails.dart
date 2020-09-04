import 'dart:io';
import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receipt_management/components/loader.dart';
import 'package:receipt_management/components/responsiveText.dart';
import 'package:receipt_management/constants.dart';
import 'package:receipt_management/models/receiptModel.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class VerifyDetailsScreen extends StatefulWidget {
  VerifyDetailsScreen({this.receipt});
  final Receipt receipt;
  @override
  _VerifyDetailsScreenState createState() => _VerifyDetailsScreenState();
}

class _VerifyDetailsScreenState extends State<VerifyDetailsScreen> {
  final _verifyForm = GlobalKey<FormState>();
  final merchantNameController = TextEditingController();
  final totalController = TextEditingController();
  final dateController = TextEditingController();
  String merchantName;
  String total;
  String date;
  DateTime selectedDate = DateTime.now();
  Future<void> submitQuery() async {
    final pr = Loader(context);
    pr.show();
    final currentUserUID = FirebaseAuth.instance.currentUser.uid;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final imageName = widget.receipt.receiptImage.split('/').last;
    final snapshot = await storage
        .ref()
        .child("$imageName")
        .putFile(File(widget.receipt.receiptImage))
        .onComplete;
    if (snapshot.error == null)
      snapshot.ref.getDownloadURL().then((downloadURL) async {
        print(downloadURL.toString());
        firestore.collection('receipts').add({
          'merchant_name': merchantName,
          'total': total,
          'date': selectedDate.toString(),
          'uid': currentUserUID,
          'downloadUrl': await snapshot.ref.getDownloadURL(),
          'storagePath': await snapshot.ref.getPath()
        }).then((value) {
          pr.hide();
          Navigator.pop(context);
        });
      });
    // jsonEncode({'merchant_name':merchantNameController.text,'total':totalController.text,'date':dateController.text,'uid':currentUserUID,'downloadUrl':await snapshot.ref.getDownloadURL()});
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      merchantName = widget.receipt.merchantName;
      total = widget.receipt.total.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Receipt Details',
            style: TextStyle(
                fontSize: getFontSize(context, 4),
                fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
          child: GestureDetector(
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: InkWell(
                    onTap: () {
                      Alert(
                          context: context,
                          title: '',
                          content:
                              Image.file(File(widget.receipt.receiptImage)),
                          style: AlertStyle(
                            isCloseButton: false,
                            isOverlayTapDismiss: false,
                            titleStyle: TextStyle(
                             fontSize: 0 
                            )
                          ),buttons: [
                                DialogButton(child: Text('CLOSE',style: TextStyle(
                                 fontSize: getFontSize(context,0),
                                 color: Colors.white
                                //  fontFamily: 'receiptFont',
                                ),), onPressed: (){
                                  Navigator.of(context).pop();
                                })
                              ]).show();
                    },
                    child: Image.file(
                      File(widget.receipt.receiptImage),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),),),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Form(
                key: _verifyForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Scan Results',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: getFontSize(context, 7),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value){
                          if(value.isEmpty)
                            return 'Required';
                          return null;
                        },
                        decoration:
                            buildInputDecoration('Merchant Name', context),
                        initialValue: widget.receipt.merchantName,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          merchantName = value;
                        },
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Theme(
                          data: ThemeData(
                              colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).accentColor),
                              buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary),
                              primaryColor: Theme.of(context)
                                  .accentColor, //Head background
                              accentColor: Theme.of(context)
                                  .accentColor //selection color
                              //dialogBackgroundColor: Colors.white,//Background color
                              ),
                          child: DateTimeFormField(
                            decoration:
                                buildInputDecoration('Select Date', context),
                            label: 'Select Date',
                            lastDate: DateTime.now().add(Duration(days: 1)),
                            initialValue: selectedDate ?? DateTime.now(),
                            onDateSelected: (date) {
                              selectedDate = date;
                            },
                          ),
                        ),),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration:
                            buildInputDecoration('Total Amount', context),
                        onChanged: (value) {
                          total = value;
                        },
                        validator: (value){
                          if(value.isEmpty)
                            return 'Required';
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[^0-9.]')),
                        ],
                        initialValue: widget.receipt.total.toString(),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: kAccentColor,
                          onPressed: () async {
                            await submitQuery();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'VERIFY',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getFontSize(context, 2)),
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.grey[800],
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getFontSize(context, 2)),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

InputDecoration buildInputDecoration(String labelText, BuildContext context) {
  return InputDecoration(
    labelText: labelText,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10)),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10)),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10)),
  );
}
