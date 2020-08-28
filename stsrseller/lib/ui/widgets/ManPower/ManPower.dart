import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/ui/pages/home.dart';

import 'AddNewManPower.dart';

class ManPower extends StatefulWidget {
  @override
  _ManPowerState createState() => _ManPowerState();
}

class _ManPowerState extends State<ManPower> {
  List<DocumentSnapshot> _manpowerdata;
  StreamSubscription<QuerySnapshot> _subs;

  @override
  void initState() {
    _getmanpower();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("ManPower",style: GoogleFonts.muli(color: LightColor.background),),
      ),
      body: Container(
        color: LightColor.background,
        child: (){
          if(_manpowerdata==null) return SpinKitDoubleBounce(color: LightColor.orange,duration: Duration(milliseconds: 100),);
          else if(_manpowerdata.isEmpty) return Container(height: 0,width: 0,);
          return Container(
            padding: EdgeInsets.all(10),
            width: AppTheme.fullWidth(context),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _manpowerdata.length,
              itemBuilder: (context,index){
                return ManCard(_manpowerdata[index]);
              },
            ),
          );
        }()
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LightColor.black,
        child: Icon(Icons.add,color: LightColor.background,),
        onPressed: (){
          Navigator.push(context, PageTransition(
              child: AddNewManPower(),
              type: PageTransitionType.downToUp
          ));
        },
      ),
    );
  }



  void _getmanpower() async{
    if(Home.manpowerdata==null){
      Firestore.instance.collection('manpower').getDocuments().then((value){
        if(!mounted) return;
        setState(() {
          _manpowerdata=value.documents;
        });
        Home.manpowerdata=_manpowerdata;
      });
    }else{
      if(!mounted) return;
      setState(() {
        _manpowerdata=Home.manpowerdata;
      });
    }
    _refresh();
  }

  _refresh() async{
   _subs=await Firestore.instance.collection('manpower').snapshots().listen((event) {
      if(!mounted) return;
      setState(() {
        _manpowerdata=event.documents;
      });
      Home.manpowerdata=_manpowerdata;
    });
  }


  ManCard(DocumentSnapshot _mydaat){
    return Container(
      margin: EdgeInsets.all(15),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: _mydaat['image'],
                placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
                width: 150,
                height: 120,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(_mydaat['name'][0].toString().toUpperCase()+_mydaat['name'].toString().substring(1),style: GoogleFonts.muli(color: LightColor.black),textAlign: TextAlign.left,),
          )
        ],
      ),
    );
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

