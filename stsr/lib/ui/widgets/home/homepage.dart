import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/widgets/ManPower/manpower.dart';
import 'package:stsr/ui/widgets/category/SubCategoryOnly.dart';

import 'package:stsr/ui/widgets/home/catcard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Search.dart';
import 'bannerscurousel.dart';


class MyHomePage extends StatefulWidget {
  List<DocumentSnapshot> allcats;
  MyHomePage(this.allcats);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  _allcategories(){
    if(widget.allcats==null) return SpinKitCircle(color: LightColor.orange,);
    return Container(
          padding: EdgeInsets.all(10),
          height: 180,
          width: AppTheme.fullWidth(context),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ListView.builder(
                scrollDirection: Axis.horizontal,
                  itemCount: widget.allcats.length,
                  itemBuilder: (context,index){
                return _subcatcard(widget.allcats[index]);
              }
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text("All categories",
                    style: GoogleFonts.lato(color: LightColor.lightblack,fontWeight: FontWeight.bold,fontSize: 18),),
                ),
              )
            ],
          ),
        );

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.fromLTRB(0, 15, 0, 70),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        dragStartBehavior: DragStartBehavior.down,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _allcategories(),
            CarouselWithIndicatorDemo(),
            _search(),
            SizedBox(height: 10,),
            ManPower(),
            SizedBox(height: 10,),
            (){
          if(widget.allcats==null){
            return Center(
              child: SpinKitCircle(color: LightColor.orange,),
            );
          }else if(widget.allcats.isEmpty){
            Center(child: Text("No categories yet",style: GoogleFonts.lato(color: LightColor.grey),));
          }
            return Column(
              children: widget.allcats.map((category){
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
                          itemCount: category['subcategories'].length,
                          itemBuilder: (context,index){
                            return CatCard(category['subcategories'][index],category['subcategoriesid'][index]);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(category['name'],
                            style: GoogleFonts.muli(color: LightColor.lightblack,fontWeight: FontWeight.bold,fontSize: 18),),
                        ),
                      )
                    ],
                  ),
                );
              }).toList()
            );

        }()


          ],
        ),
      ),
    );
  }
  Widget _search() {
    return Container(
      margin: AppTheme.padding,
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: Search(),
            type: PageTransitionType.fade
          ));
        },
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: LightColor.lightGrey.withAlpha(100),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Products",
                      hintStyle: TextStyle(fontSize: 12),
                      contentPadding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 5),
                      prefixIcon: Icon(Icons.search, color: Colors.black54)),
                  onTap: (){
                    debugPrint("hjn");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  _subcatcard(category) {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: SubCategoryOnly(category),
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
                  imageUrl: category['image'],
                  placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 80,
                  height: 50,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(category['name'][0].toString().toUpperCase()+category['name'].toString().substring(1),style: GoogleFonts.lato(color: LightColor.black),textAlign: TextAlign.left,),
            )
          ],
        ),
      ),
    );
  }


}
