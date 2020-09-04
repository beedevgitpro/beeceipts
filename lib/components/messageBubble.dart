import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isSent;
  final String messageText;
  MessageBubble({@required this.isSent, @required this.messageText});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
          mainAxisAlignment:
              isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(maxWidth:MediaQuery.of(context).size.width*0.6),
              decoration: BoxDecoration(
                  color:
                      isSent ? Theme.of(context).accentColor : Colors.grey[300],
                  borderRadius: BorderRadius.only(
                      bottomLeft:
                          !isSent ? Radius.circular(0) : Radius.circular(10),
                      bottomRight:
                          !isSent ? Radius.circular(10) : Radius.circular(0),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),),),
              child: Text(messageText,style: TextStyle(
               color: isSent ? Colors.white:Colors.black
         ),),
            )
          ]),
    );
  }
}
