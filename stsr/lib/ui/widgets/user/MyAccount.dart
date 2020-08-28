import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/ui/DialogInput.dart';
import 'package:stsr/resources/ui/addlocation.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stsr/ui/widgets/user/singleearning.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  DocumentSnapshot _user;
  StreamSubscription<DocumentSnapshot> _subs;
  DocumentSnapshot _reffredby;
  List<DocumentSnapshot> _referals;

  @override
  void initState() {
    // TODO: implement initState
    _user=Home.user;
    _userload();
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
            children: <Widget>[
              _showdata("Name",_user['name'], FontAwesomeIcons.user, () async{
                if(await IsConnectedtoInternet()){
                  ShowInternetDialog(context);
                  return;
                }
                String text=await DialogInput(context, "name", TextInputType.text);
                if(text.isNotEmpty){
                  Firestore.instance.collection('user').document(_user.documentID).updateData({
                    'name':text
                  });
                }
              },true),
              _showdata("Phone",_user['phone'], FontAwesomeIcons.phone, () {},false),
              _showdata("Email",_user['email'], Icons.mail, () async{
                if(await IsConnectedtoInternet()){
                  ShowInternetDialog(context);
                  return;
                }
                String text=await DialogInput(context, "email", TextInputType.emailAddress);
                if(text.isNotEmpty){
                  Firestore.instance.collection('user').document(_user.documentID).updateData({
                    'email':text
                  });
                }
              },true),
              _showdata("Floor and house/building no.",_user['house'], FontAwesomeIcons.home, () async{
                if(await IsConnectedtoInternet()){
                  ShowInternetDialog(context);
                  return;
                }
                String text=await DialogInput(context, "Floor and house/building no.", TextInputType.text);
                if(text.isNotEmpty){
                  Firestore.instance.collection('user').document(_user.documentID).updateData({
                    'house':text
                  });
                }
              },true),
              _showdata("Address",_user['address'], Icons.location_on, () async{
                if(await IsConnectedtoInternet()){
                  ShowInternetDialog(context);
                  return;
                }
                Map addressdata=await Navigator.push(context, PageTransition(
                    child: AddLocation(),
                    type: PageTransitionType.fade
                ));
                if(addressdata!=null){
                  Firestore.instance.collection('user').document(_user.documentID).updateData({
                    'address':addressdata['address'],
                    'pincode':addressdata['pincode'],
                    'city':addressdata['city'],
                    'sublocality':addressdata['sublocality'],
                    'lat':addressdata['lat'],
                    'long':addressdata['long'],
                  });
                }
              },true),
              _showdata("City",_user['city'], FontAwesomeIcons.city, () {},false),
              _showdata("Pincode",_user['pincode'], FontAwesomeIcons.code, () {},false),
              _showdata("Sublocality",_user['sublocality'], FontAwesomeIcons.city, () {},false),
              _showdata("Referal Id",_user['referalid'], FontAwesomeIcons.moneyBill, () {},false),
              _reffredbywidget(),
              _referalswidget()
            ],
          ),
        ),
      ),
    );
  }

  _reffredbywidget(){
    if(_reffredby==null){
      return Container(height: 0,width: 0,);
    }
    return _showdata("Referred by", _reffredby['phone'], FontAwesomeIcons.user, () { }, false);
  }
 _referalswidget(){
    if(_referals==null){
      return SpinKitSpinningCircle(color: LightColor.orange,);
    }
    if(_referals.isEmpty){
      return Container(height: 0,width: 0,);
    }
   return ListTile(
     trailing: Icon(Icons.arrow_drop_down,color: LightColor.orange,),
      title: Text("Your referals",style: GoogleFonts.muli(color: LightColor.darkgrey),),
      leading: Icon(FontAwesomeIcons.user,color: LightColor.orange,),
     onTap: (){
       showModalBottomSheet(context: context, builder: (context){
         return SingleChildScrollView(
           child: Column(
             children: List.generate(_referals.length, (index){
               return _showdata("Referal ${index+1}", _referals[index]['phone'], FontAwesomeIcons.user, () {
                 Navigator.push(context, PageTransition(
                   child: singleearning(_referals[index]),
                   type: PageTransitionType.downToUp
                 ));
               }, false);
             }),
           ),
         );
       });
     },
    );
  }

  _showdata(String text,String subtext,IconData icon,VoidCallback onclick,trail){
    return ListTile(
      title: Text(text,style: GoogleFonts.muli(color: LightColor.darkgrey),),
      subtitle: Text(subtext.isEmpty?"Enter"+text:subtext,style: GoogleFonts.muli(color: LightColor.darkgrey),),
      leading: Icon(icon,color: LightColor.orange,),
      trailing: !trail?Container(height: 0,width: 0,alignment: Alignment.center,):Icon(Icons.edit,color:LightColor.lightGrey),
      onTap: onclick,
    );
  }
  _userload() async{
    _subs = await Firestore.instance.collection('user').document(Home.user.documentID).snapshots().listen((event) {
      setState(() {
        _user=event;
      });
      Home.user=_user;
    });
    _getreffredby();
  }
  
  _getreffredby()async{
  if(_user['referredby'].isNotEmpty){
    Firestore.instance.collection("user").where('referalid',isEqualTo:_user['referredby']).getDocuments().then((value){
     setState(() {
       if(value.documents.isNotEmpty){
         _reffredby=value.documents.first;
       }
     });
   });
  }
   Firestore.instance.collection('user').where('referredby',isEqualTo:_user['referalid']).getDocuments().then((value){
     setState(() {
       _referals=value.documents;
     });
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
