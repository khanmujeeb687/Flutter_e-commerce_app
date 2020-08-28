import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class Admins extends StatefulWidget {
  @override
  _AdminsState createState() => _AdminsState();
}

class _AdminsState extends State<Admins> {
  DocumentSnapshot _user;
  StreamSubscription<DocumentSnapshot> _subs;
  @override
  void initState() {
    _user=Home.user;
    _refresh();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.black,
      appBar: AppBar(
        backgroundColor: LightColor.darkgrey,
        title: Text("My Account",style: GoogleFonts.muli(),),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(Home.user['phone'].length, (index) => _showdata(Home.user['phone'][index], index)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,color: LightColor.background,),
        backgroundColor: LightColor.orange,
        onPressed: ()async{
          String text=await DialogInput(context, "new admin phone no.", TextInputType.phone);
          if(Home.user['phone'].contains(text)){
            Toast.show('Admin already exists', context);
            return;
          }
          if(text.length!=10){
            Toast.show('Please enter a valid phone number', context);
            return;
          }
          if(text.isNotEmpty){
            Firestore.instance.collection('seller').document(Home.user.documentID).updateData({
              'phone':FieldValue.arrayUnion([text])
            });
          }
        },
      ),
    );
  }

  _showdata(String text,int index){
    return ListTile(
      title: Text("Admin ${index+1}",style: GoogleFonts.muli(color: LightColor.darkgrey),),
      subtitle: Text(text,style: GoogleFonts.muli(color: LightColor.darkgrey),),
      leading: Icon(FontAwesomeIcons.user,color: LightColor.orange,),
    );
  }

  _refresh() async{
    _subs = Firestore.instance.collection('seller').document(Home.user.documentID).snapshots().listen((event) {
      setState(() {
        _user=event;
      });
      Home.user=_user;
    });
  }

  @override
  void dispose() {
    if(_subs!=null){
      _subs.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }

}
