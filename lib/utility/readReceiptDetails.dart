import 'dart:convert';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:receipt_management/components/loader.dart';
import 'package:receipt_management/models/receiptModel.dart';
import 'package:receipt_management/screens/verifyReceiptDetails.dart';
import 'package:image_cropper/image_cropper.dart';
void getReceiptDetails(BuildContext context) async{
  final pr=Loader(context);
    final pickedFile=await ImagePicker().getImage(source: ImageSource.camera);
    pr.show();
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
        activeControlsWidgetColor: Theme.of(context).accentColor,
          toolbarTitle: 'Edit Receipts',
          toolbarColor: Theme.of(context).accentColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    );
    
    if(croppedFile==null)
      croppedFile=File(pickedFile.path);
    VisionText _textScanResults=await FirebaseVision.instance.textRecognizer().processImage(FirebaseVisionImage.fromFilePath(croppedFile.path??pickedFile.path));
    for(TextBlock blk in _textScanResults.blocks)
      debugPrint(blk.text);
    // Response r=await post('$kAPIBaseUrl/extract-data',body: {'ocr_data':_textScanResults.text});
    // debugPrint(jsonDecode(r.body)['total'].toString());
    // print(jsonDecode(r.body)['merchant_name']);
    Map extractedData=extractText(_textScanResults.text);
    extractedData.addAll(<String,dynamic>{'receipt_image':croppedFile.path??pickedFile.path});
    pr.hide();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyDetailsScreen(receipt: Receipt.fromJson(extractedData),)));
    // return Receipt.fromJson(extractedData);
  }

Map<String,dynamic> extractText(String text){
  String merchantName=LineSplitter().convert(text)[0];
  print('Length=${LineSplitter().convert(text).length}');
    double total=0.0;
    String date;
    for(String textLine in LineSplitter().convert(text))
      if(RegExp(r'[0-9]+,?[0-9]+[,.][0-9]+').hasMatch(textLine) && !RegExp(r'[:/%]').hasMatch(textLine))
        {if(total<(double.tryParse(textLine.replaceAll(',', '.').replaceAll(RegExp(r'[a-zA-Z]'),'').trim())??0.0))
          total=double.parse(textLine.replaceAll(',', '.').replaceAll(RegExp(r'[a-zA-Z]'),'').trim());}
      else if(RegExp(r'[0-9]+[\/-][0-9]+[\/-][0-9]{4}').hasMatch(textLine) || RegExp(r'[0-9]{2}\s[a-zA-z]+[0-9]{2,4}').hasMatch(textLine))
        {
          RegExp(r'[0-9]+[\/-][0-9]+[\/-][0-9]{4}').hasMatch(textLine)?
          date=RegExp(r'[0-9]{2}[\/-][0-9]{2}[\/-][0-9]{4}').stringMatch(textLine):date=RegExp(r'[0-9]+\s*[a-zA-z]{3}.\s*.[0-9]{2,4}').stringMatch(textLine);
          print('Date: '+ '$date');
        }
      
    print('Total:'+total.toString());
    print('MerchantName: $merchantName');
    print('Date: $date');
    return {'merchant_name':merchantName,'total':total,'date':date.toString()};
}