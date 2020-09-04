import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receipt_management/components/responsiveText.dart';
import 'package:receipt_management/screens/chatScreen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  double _height,_width;
  @override
  Widget build(BuildContext context) {
    _height=MediaQuery.of(context).size.height;
    _width=MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Chats',style: TextStyle(fontSize: getFontSize(context,4), fontWeight: FontWeight.w700),textAlign: TextAlign.center),
        actions: [
          Icon(CupertinoIcons.create_solid,
                  color: Colors.white, size: 35),
        ],
      ),
      body: buildChatPage(),
    );
  }
    ListView buildChatPage() {
    return ListView.builder(
      itemCount: 15,
      itemBuilder:(context,index){
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(name: 'Person ${index + 1}'),
                ),
              );
            },
            title: Text('Person ${index + 1}'),
            leading: Icon(
              Icons.account_circle,
              color: Theme.of(context).accentColor,
              size: 40,
            ),
            subtitle: Text('Previous message'),
          );
      }
    );
  }
}