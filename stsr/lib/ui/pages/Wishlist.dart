import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/pages/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

import 'Home.dart';

class WishList extends StatefulWidget {
  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<DocumentSnapshot> items=[];
  StreamSubscription<DocumentSnapshot> _usersubscription;
  DocumentSnapshot _user;
  bool loaded=false;
  @override
  void initState() {
    _user=Home.user;
    _loaditems();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height-150,
        margin: EdgeInsets.only(bottom: 60),
        color: Color(0xfff8f8f8),
        alignment: (){
        if(items==null){
          return Alignment.topCenter;
        }
      else if(!loaded){
          return Alignment.topCenter;
        }
       else  if(items.isEmpty){
          return Alignment.center;
        }
          return Alignment.topCenter;
        }(),
        child: SingleChildScrollView(
          child: (){
            if(items==null){
              return _shimmer();
            }
            else if(!loaded){
              return _shimmer();
            }
            else if(items.isEmpty){
              return Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.heart,color: LightColor.grey,size: 50,),
                  Text("No items in wishlist",style: GoogleFonts.alef(color: LightColor.grey),),
                ],
              ),);
            }

            return Column(
              children: <Widget>[
                _header(),
                GridView.count(
                  padding: EdgeInsets.all(6),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: List.generate(items.length, (index){
                    return _ItemCard(index);
                  }),
                  childAspectRatio: 0.7,
                ),
              ],
            );
          }(),
        )
    );
  }

  _loaditems() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    if(_user['wishlist'].isNotEmpty){
      await Firestore.instance.collection('products').where('productid',whereIn:_user['wishlist']).getDocuments().then((value){
        if(value.documents.isNotEmpty){
          if(!mounted) return;
          setState(() {
            items=value.documents;
          });
        }
      });
    }
    if(!mounted) return;
    setState(() {
      loaded=true;
    });
    _userrefresh();
  }




  _shimmer(){
    return Column(
      children: <Widget>[
        GridView.count(crossAxisCount: 2,
          childAspectRatio: 1/1.5,
          shrinkWrap: true,
          physics: ScrollPhysics(),
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
        ),
      ],
    );
  }

  _userrefresh() async{
    if( await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    _usersubscription =await Firestore.instance.collection('user').
    document(Home.user.documentID).snapshots().listen((event) async{
      setState(() {
        _user=event;
      });
      Home.user=event;
    });
  }


  Widget _ItemCard(int index) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(context, PageTransition(
              child: Product(items[index]),
              type: PageTransitionType.fade
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,size: 15,),
                      AutoSizeText(items[index]['coins'].toString()+" coins",
                        minFontSize: 7,
                        maxFontSize: 13,
                        style: GoogleFonts.muli(color: LightColor.yellowColor),)
                    ],
                  ),
                  GestureDetector(
                    onTap: ()async{
                      if(await IsConnectedtoInternet()){
                        ShowInternetDialog(context);
                        return;
                      }
                      if(_user['wishlist'].contains(items[index].documentID)){
                        Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                          'wishlist':FieldValue.arrayRemove([items[index].documentID])
                        });
                        setState(() {
                          items.removeAt(index);
                        });
                        return;
                      }
                      Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                        'wishlist':FieldValue.arrayUnion([items[index].documentID])
                      });
                    },
                    child: Icon(_user['wishlist'].contains(items[index].documentID)? Icons.favorite : Icons.favorite_border,
                        color:_user['wishlist'].contains(items[index].documentID)? LightColor.red : LightColor.lightGrey,
                  ),
                  ),
                ],
              ),
              Center(
                child: CachedNetworkImage(
                  imageUrl: items[index]['pictures'][0],
                  placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
              AutoSizeText(items[index]['productname'][0].toString().toUpperCase()+items[index]['productname'].toString().substring(1),style: GoogleFonts.lato(color: LightColor.black),),
              AutoSizeText(items[index]['discount']+"% OFF",style: GoogleFonts.lato(decoration: TextDecoration.underline,color: LightColor.orange,fontSize: 13)),
              (int.parse(items[index]['unitsinstock'].toString())<=0)?
              AutoSizeText("Out of Stock",style: GoogleFonts.lato(color:LightColor.orange,fontWeight: FontWeight.bold,fontSize: 15),)
                  :Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0,
                children: <Widget>[
                  AutoSizeText("Just at ${
                      double.parse(items[index]['price'].toString())-((double.parse(items[index]['price'].toString())*double.parse(items[index]['discount'].toString()))/100)
                  }",style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 17),),
                  AutoSizeText("Rs."+items[index]['price'],style: GoogleFonts.lato(decoration: TextDecoration.lineThrough,color: LightColor.grey,fontSize: 12),),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }


  _header(){
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TitleText(
              text: 'Wishlist',
              fontSize: 27,
              fontWeight: FontWeight.w400,
              color: LightColor.black,
            ),
            TitleText(
              text: 'Items',
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: LightColor.black,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if(_usersubscription!=null){
      _usersubscription.cancel();
    }
    super.dispose();
  }
}



