import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:receipt_management/components/messageBubble.dart';
import 'package:receipt_management/components/responsiveText.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  ChatScreen({this.name});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(widget.name,style: TextStyle(fontSize: getFontSize(context,4), fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MessageBubble(
                        isSent: true, messageText: 'Hellohvjndfnvkjfdnvkd',),
                    MessageBubble(
                        isSent: false, messageText: 'Hellohvjndfnvkjfdnjjmjmkmkmvkd',)
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide())),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: Theme.of(context).accentColor,
                      decoration: InputDecoration(
                        hintText: 'Type Something...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, size: 30,color: Theme.of(context).accentColor,),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }
}
