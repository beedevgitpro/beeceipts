import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:receipt_management/components/loader.dart';
import 'package:receipt_management/components/responsiveText.dart';
import 'package:receipt_management/screens/chatListingScreen.dart';
import 'package:receipt_management/screens/loginScreen.dart';
import 'package:receipt_management/utility/readReceiptDetails.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen({this.user,this.name});
  final User user;
  final String name;
  @override
  _LandingScreenState createState() => _LandingScreenState();
}
class _LandingScreenState extends State<LandingScreen> {
  // double _height,_width;
  final searchController=TextEditingController();
  bool showSearchBar=false;
  Loader loader;
  Route get _createRoute {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatListScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(Tween(begin: Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeIn))),
        child: child);
    },
  );
}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loader = Loader(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: RaisedButton(onPressed: ()async{
         getReceiptDetails(context);
        // loader.show();
        // Timer(Duration(seconds:3), (){
        //   loader.hide();
        // });
      },
                  padding: EdgeInsets.all(18.0),
                  elevation: 5,
                  shape: CircleBorder(),
                  color: Theme.of(context).accentColor,
                  child: Icon(Icons.camera_alt,color:Colors.white,size:35),
                  ),
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
         title: Text('${widget.name.trim()}\'s Receipts'.toUpperCase(),style: TextStyle(fontSize: getFontSize(context,0.5), fontWeight: FontWeight.w800)), 
         actions: [
           IconButton(icon: Icon(Icons.search,size: 30,), onPressed: (){
             setState(() {
               showSearchBar=!showSearchBar;
               searchController.clear();
             });
           }),
           IconButton(icon: Icon(Icons.forum,size: 30,), onPressed: (){
             Navigator.push(context, _createRoute);
           }),
           IconButton(icon: Icon(Icons.exit_to_app,size: 30,), onPressed: (){
             FirebaseAuth.instance.signOut();
             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LoginScreen()), (r) => false);
           }),
           
         ],
        ),
        body: SafeArea(
          child:  buildReceiptList(),
        ));
  }

  StreamBuilder buildReceiptList(){
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('receipts').snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          return Center(
            child: Text('No Receipts to show'),
          );
        bool isEmpty=true;
          print(snapshot.data.documents.length.toString());
          for(var doc in snapshot.data.documents)
            if(doc.data()['uid']==FirebaseAuth.instance.currentUser.uid)
                isEmpty=false;
        return Column(
          children: [
            Visibility(visible:showSearchBar,child: Container(
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide())
                ),
                child: Row(
                  children: [
                    Expanded(
                              child: TextFormField(
                                     onChanged: (_){
                                            setState(() {});
                                          },
                                          controller: searchController,
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                         hintText: 'Search...',
                         contentPadding: EdgeInsets.symmetric(horizontal:15) 
                        ),
                      ),
                    ),
                   IconButton(
                     onPressed: (){
                       searchController.clear();
                     },
                        icon: Icon(Icons.clear),
                   ),
                  ],
                ),
              ),
            )),
            isEmpty?Expanded(
                            child: Center(child:
              Text('No Receipts To Show',style: TextStyle(
                fontSize: getFontSize(context, 2),
                fontWeight: FontWeight.w500,
                color: Colors.black54
              )),
              ),
            ):ListView.builder(
              shrinkWrap: true,
             itemCount: snapshot.data.documents.length,
             // ignore: missing_return
             itemBuilder: (context,index){
                print(snapshot.data.documents[index].data()['downloadUrl']);
                if(snapshot.data.documents[index].data()['merchant_name'].toString().toLowerCase().contains(searchController.text.toLowerCase()) || searchController.text.isEmpty)
                if(snapshot.data.documents[index].data()['uid']==FirebaseAuth.instance.currentUser.uid)
                return Dismissible(
                  key:Key(snapshot.data.documents[index].documentID),
                  onDismissed: (direction)async{
                    loader.show();
                    try{
                    FirebaseFirestore.instance.doc('receipts/'+snapshot.data.documents[index].documentID).delete().then((value) => loader.hide());
                    print('gs://receipt-management-bb942.appspot.com/'+snapshot.data.documents[index].data()['storagePath']);
                    FirebaseStorage.instance.getReferenceFromUrl('gs://receipt-management-bb942.appspot.com/'+snapshot.data.documents[index].data()['storagePath']).then((value)async => await value.delete());
                    } catch(e){
                      print(e);
                    loader.hide();
                    }
                  },
                  background: Container(
                   color: Colors.red,
                   padding: EdgeInsets.all(10),
                   alignment: Alignment.centerLeft,
                   child: Icon(Icons.delete,size: 40,color: Colors.grey[200],), 
                  ),
                  secondaryBackground: Container(
                   color: Colors.red,
                   padding: EdgeInsets.all(10),
                   alignment: Alignment.centerRight,
                   child: Icon(Icons.delete,size: 40,color: Colors.grey[200],), 
                  ),
                                  child: Card(
                    color: Colors.white,
                            child: ListTile(
                              onTap: (){
                                Alert(context: context, title: '',content: Image.network(snapshot.data.documents[index].data()['downloadUrl']),buttons: [
                                  DialogButton(child: Text('CLOSE',style: TextStyle(
                                   fontSize: getFontSize(context,0),
                                   color: Colors.white
                                  //  fontFamily: 'receiptFont',
                                  ),), onPressed: (){
                                    Navigator.of(context).pop();
                                  })
                                ],style:AlertStyle(
                                  titleStyle: TextStyle(
                               fontSize: 0.1
                              ),
                              isOverlayTapDismiss: false,
                                 isCloseButton: false 
                                )).show();
                              },
                              contentPadding: EdgeInsets.all(5),
                     leading:FadeInImage(
                       placeholder: AssetImage(
                        'assets/receipt_placeholder.png'
                       ),
                      image: NetworkImage(
                        snapshot.data.documents[index].data()['downloadUrl'])
                        ,fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width*0.2,
                       ),
                     title: Text(snapshot.data.documents[index].data()['merchant_name'].toString(),textAlign: TextAlign.left,style: TextStyle(
                                   fontSize: getFontSize(context,0),
                                   fontWeight: FontWeight.w500
                                  //  fontFamily: 'receiptFont',
                                  ),),
                                  
                                  trailing: Text('₹'+snapshot.data.documents[index].data()['total'].toString().toUpperCase(),textAlign: TextAlign.left,style: TextStyle(
                                   fontSize: getFontSize(context,0),
                                  //  fontFamily: 'receiptFont',
                                  ),),
                                  subtitle:Text(DateFormat('dd MMM, yyyy').format(DateTime.parse(snapshot.data.documents[index].data()['date'])).toString().toUpperCase(),textAlign: TextAlign.left,style: TextStyle(
                                   fontSize: getFontSize(context,-2),
                                  //  fontFamily: 'receiptFont',
                                  ),),
                                  ), 
                                
                    ),
                );
                  return Container();
              }
            ),
          ],
        );
      }
    );
  }
}