import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/widgets/order/SingleOrderManage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List<DocumentSnapshot> items;
  StreamSubscription<QuerySnapshot> _subscription;
  ScrollController _controller=new ScrollController();
  bool hasmore=true;
  @override
  void initState() {
    if(Home.myordersdata!=null){
      items=Home.myordersdata;
    }
    _loaditems();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.black,
      appBar: AppBar(
        title: Text("My orders",style: GoogleFonts.muli(),),
        backgroundColor: LightColor.darkgrey,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.topCenter,
        child: (){
          if(items==null){
           return _shimmer();
          }else if(items.isEmpty){
           return Center(child: Text("NO ORDERS!",style: GoogleFonts.muli(color: LightColor.grey),),);
          }
          return ListView.builder(
            controller: _controller,
            itemCount: items.length+1,
            itemBuilder: (context,index){
              if(index==items.length){
                if(!hasmore || items.length<7){
                  return Center(
                      child: Icon(Icons.timelapse,color: LightColor.grey,size: 40,)
                  );
                }
                return Center(
                  child: SpinKitCircle(color: LightColor.orange,)
                );
              }
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, PageTransition(
                    child: SingleOrderManage(items[index]),
                    type: PageTransitionType.leftToRightWithFade
                  ));
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: LightColor.background,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: items[index]['image'],
                            placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                          )
                      ),
                      Expanded(
                          child: ListTile(
                              title: Wrap(
                                spacing: 15.0,
                                runSpacing: 4.0,
                                children: <Widget>[
                                  TitleText(
                                    text: items[index]['productname'],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: <Widget>[
                                      Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,size: 15,),
                                      AutoSizeText(items[index]['coins'].toString()+" coins${items[index]['status']=="delivered"?" added to your wallet":" to be rewarded"}",
                                        minFontSize: 7,
                                        maxFontSize: 12,
                                        style: GoogleFonts.muli(color: LightColor.yellowColor),)
                                    ],
                                  ),
                                ],
                              ),
                              subtitle: _priceanddiscount(index),
                              trailing: Container(
                                width: 35,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: LightColor.lightGrey.withAlpha(150),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TitleText(
                                  text: "Qty. "+items[index]['quantity'].toString(),
                                  fontSize: 12,
                                ),
                              )))
                    ],
                  ),
                ),
              );
            },
          );
        }()
      ),
    );
  }

  _priceanddiscount(index){
    return Container(
      width: AppTheme.fullWidth(context)/3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(items[index]['ifprepaid']?"Prepaid order":"Cash on delivery",style: TextStyle(color: LightColor.orange,decoration: TextDecoration.underline,fontSize: 16),),
          _price(index),
          RaisedButton(
            elevation: 0,
            color: LightColor.orange,
            child: Text(items[index]['status'],style: GoogleFonts.muli(color: LightColor.background),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
            ),
            onPressed: (){
              Navigator.push(context, PageTransition(
                  child: SingleOrderManage(items[index]),
                  type: PageTransitionType.leftToRightWithFade
              ));
            },
          )
        ],
      ),
    );
  }

  _shimmer(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index){
        return Container(
          width: AppTheme.fullWidth(context)-60,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 50,
                    width: AppTheme.fullWidth(context)-60,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 35,
                    width: AppTheme.fullWidth(context)-60,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 35,
                    width: AppTheme.fullWidth(context)/2,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  _price(index){
    return Text("Price: Rs. "+items[index]['orderprice'],style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 14),);
  }
  _loaditems() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    Firestore.instance.collection('orders').where('userid',isEqualTo: Home.user.documentID)
        .orderBy('orderdatetime',descending: true)
        .limit(7).
    getDocuments().then((value){
      if(!mounted) return;
      setState(() {
        items=value.documents;
      });
      if(items.isNotEmpty){
        _controller.addListener(() {
          if(_controller.position.pixels == _controller.position.maxScrollExtent){
            _loadmore();
          }
        });

      }
      _refresh();
    });
  }
  _refresh() async{
    hasmore=false;
    _subscription = Firestore.instance.collection('orders').where('userid',isEqualTo: Home.user.documentID)
        .orderBy('orderdatetime',descending: true)
        .limit(7)
        .snapshots().listen((event) {
      if(!mounted) return;
      setState(() {
        items=event.documents;
      });
      hasmore=true;
    });
  }

  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void _loadmore() {
    if(!hasmore) return;
    hasmore=false;
    Firestore.instance.collection('orders').where('userid',isEqualTo: Home.user.documentID)
        .orderBy('orderdatetime',descending: true)
        .startAfterDocument(items.last)
        .limit(7).
    getDocuments().then((value){
      if(!mounted) return;
      setState(() {
        items.addAll(value.documents);
        print(items.length.toString());
      });
      _refreshagain(value.documents.isEmpty?false:true);
    });
  }

  void _refreshagain(hasmore) async{
    if(_subscription!=null){
      _subscription.cancel();
      _subscription =  Firestore.instance.collection('orders').where('userid',isEqualTo: Home.user.documentID)
          .orderBy('orderdatetime',descending: true)
          .limit(items.length)
          .snapshots().listen((event) {
        if(!mounted) return;
        setState(() {
          items=event.documents;
        });
      });
    }
    setState(() {
      this.hasmore=hasmore;
    });
  }
}
