import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:stsrseller/ui/widgets/myproducts/subcategorypage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class Mycategories extends StatefulWidget {
  @override
  _MycategoriesState createState() => _MycategoriesState();
}

class _MycategoriesState extends State<Mycategories> {
  List<DocumentSnapshot> products;
  List<String> categories=[];
  List<String> categoriesid=[];
  StreamSubscription<QuerySnapshot> _subs;


  @override
  void initState() {
    if(Home.products!=null){
      products=Home.products;
      _fixall(products);
      _refresh();
    }else{
      _start();
    }
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffbfbfb),
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("My categories",style: GoogleFonts.muli(),),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topCenter,
        color: LightColor.lightGrey,
        child: (){
          if(categories==null){
            return Center(
              child: SpinKitCircle(color: LightColor.orange,),
            );
          }else if(categories.isEmpty){
            return Center(
              child: SpinKitCircle(color: LightColor.orange,),
            );
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context,index){
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, PageTransition(
                      child:subcategorypage(categoriesid[index],categories[index]),
                      duration: Duration(milliseconds: 100),
                      type: PageTransitionType.fade,
                      curve: Curves.linear
                    ));
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    width: AppTheme.fullWidth(context)-40,
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: LightColor.background
                    ),
                    child: Text(categories[index],style: GoogleFonts.muli(color: LightColor.black),),
                  ),
                ),
              );
            },
          );
        }(),
      ),
    );
  }

  _start() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
   await Firestore.instance.collection('products').where('sellerid',isEqualTo: Home.user.documentID).getDocuments().then((value){
     if(!mounted) return;
     setState(() {
        products=value.documents;
      });
      Home.products=products;
      _fixall(products);
    });
    _refresh();
  }

  _refresh() async{
   _subs = await Firestore.instance.collection('products').where('sellerid',isEqualTo: Home.user.documentID).snapshots().listen((value){
      if(!mounted) return;
      setState(() {
        products.clear();
        products.addAll(value.documents);
      });
      Home.products=products;
    });
  }

  void _fixall(List<DocumentSnapshot> products) {
    if(products.isEmpty){
      if(!mounted) return;
      setState(() {
        products=products;
      });
      return;
    }
    categories.clear();
    for(int i=0;i<products.length;i++){
      if(!categoriesid.contains(products[i]['categoryid'])){
        categories.add(products[i]['categoryname']);
        categoriesid.add(products[i]['categoryid']);
      }

    }
    if(!mounted) return;
    setState(() {
      products=products;
      categories=categories;
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
