import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/widgets/category/itemcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class Category extends StatefulWidget {
  bool name=false;
  String catname;
  String catid;
  Category(this.catid,this.catname,{this.name=false});
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<DocumentSnapshot> items;
  StreamSubscription<QuerySnapshot> _subscription;
  StreamSubscription<DocumentSnapshot> _usersubscription;
  DocumentSnapshot _user;
  @override
  void initState() {
    _user=Home.user;
    _loaditems();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text(widget.catname[0].toUpperCase()+widget.catname.substring(1),style: GoogleFonts.lato(),),
      ),
      body: Container(
        color: Color(0xfff8f8f8),
        alignment: Alignment.topCenter,
        child: (){
          if(items==null){
            return _shimmer();
          } else if(items.isEmpty){
            return Center(
              child: Text("No items in this category",style: GoogleFonts.lato(color: LightColor.grey))
            );
          }
          return GridView.count(crossAxisCount: 2,
            padding: EdgeInsets.all(8),
            children: List.generate(items.length, (index){
              return Itemcard(items[index],false,_user);
            }),
            childAspectRatio: .7,
          );
        }(),
      ),
    );
  }

  _shimmer(){
    return GridView.count(crossAxisCount: 2,
    childAspectRatio: 1/1.5,
    children: List.generate(3, (index){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Shimmer.fromColors(
            baseColor: LightColor.grey,
            highlightColor: LightColor.lightGrey,
            child: Card(
              child: Container(
                  height: AppTheme.fullHeight(context)/4,
                  width: AppTheme.fullWidth(context)/2.1,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Shimmer.fromColors(
            baseColor: LightColor.grey,
            highlightColor: LightColor.lightGrey,
            child: Card(
              child: Container(
                  height: 20,
                  width: AppTheme.fullWidth(context)/2.1,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: LightColor.grey,
            highlightColor: LightColor.lightGrey,
            child: Card(
              child: Container(
                  height: 20,
                  width: AppTheme.fullWidth(context)/4,
              ),
            ),
          ),
        ],
      );
    }),
    );
  }
  
  _loaditems() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    if(widget.name){
      Firestore.instance.collection('products').where('subcategoryname',isEqualTo: widget.catname).getDocuments().then((value){
        if(!mounted) return;
        setState(() {
          items=value.documents;
        });
        _refresh();
      });
    }else{
      Firestore.instance.collection('products').where('subcategoryid',isEqualTo: widget.catid).getDocuments().then((value){
        if(!mounted) return;
        setState(() {
          items=value.documents;
        });
        _refresh();
      });
    }

  }
  _refresh() async{
    if(widget.name){
      _subscription = Firestore.instance.collection('products').where('subcategoryname',isEqualTo: widget.catname).snapshots().listen((event) {
        if(!mounted) return;
        setState(() {
          items=event.documents;
        });
      });
    }else{
      _subscription = Firestore.instance.collection('products').where('subcategoryid',isEqualTo: widget.catid).snapshots().listen((event) {
        if(!mounted) return;
        setState(() {
          items=event.documents;
        });
      });
    }
   _userrefresh();
  }
  _userrefresh() async{
    if( await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    _usersubscription =await Firestore.instance.collection('user').document(Home.user.documentID).snapshots().listen((event) {
      setState(() {
        _user=event;
      });
      Home.user=event;
    });
  }


  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }
    if(_usersubscription!=null){
      _usersubscription.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }
}
