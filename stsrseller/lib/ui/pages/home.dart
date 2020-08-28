import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/ui/widgets/home/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class Home extends StatefulWidget {
 static DocumentSnapshot user;
 static List<DocumentSnapshot> products;
 static List<DocumentSnapshot> myorders;
 static List<DocumentSnapshot> manpowerdata;
 static List<DocumentSnapshot> myordershsitory;
 Home(DocumentSnapshot thisisuser){
   user=thisisuser;
   print(user.documentID);
 }
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("Press again to exit",context);
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: LightColor.black,
          title: Text("stsrseller",style: GoogleFonts.muli(),),
        ),
        drawer: mydrawer(),
        backgroundColor: LightColor.background,
        body: Container(
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
