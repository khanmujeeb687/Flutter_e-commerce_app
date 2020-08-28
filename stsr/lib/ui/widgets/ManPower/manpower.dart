import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/pages/Home.dart';

import 'ManPowerCategory.dart';

class ManPower extends StatefulWidget {
  @override
  _ManPowerState createState() => _ManPowerState();
}

class _ManPowerState extends State<ManPower> {
  List<DocumentSnapshot> _manpowerdata;

  @override
  void initState() {
    _getmanpower();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(_manpowerdata==null) return SpinKitDoubleBounce(color: LightColor.orange,duration: Duration(milliseconds: 100),);
    else if(_manpowerdata.isEmpty) return Container(height: 0,width: 0,);
    return Container(
      padding: EdgeInsets.all(10),
      height: 180,
      width: AppTheme.fullWidth(context),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _manpowerdata.length,
              itemBuilder: (context,index){
                return ManCard(_manpowerdata[index]);
              },
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              alignment: Alignment.topLeft,
              child: Text("Man Power",
                style: GoogleFonts.muli(color: LightColor.lightblack,fontWeight: FontWeight.bold,fontSize: 18),),
            ),
          )
        ],
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
  }


  ManCard(DocumentSnapshot _mydaat){
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: ManPowerCategory(_mydaat),
            type: PageTransitionType.leftToRight,
          ));
        },
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
                  width: 100,
                  height: 70,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(_mydaat['name'][0].toString().toUpperCase()+_mydaat['name'].toString().substring(1),style: GoogleFonts.muli(color: LightColor.black),textAlign: TextAlign.left,),
            )
          ],
        ),
      ),
    );
  }
}
