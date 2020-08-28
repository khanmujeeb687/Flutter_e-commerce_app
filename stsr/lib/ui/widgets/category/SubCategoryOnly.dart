import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/pages/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class SubCategoryOnly extends StatefulWidget {
  DocumentSnapshot data;
  SubCategoryOnly(this.data);
  @override
  _SubCategoryOnlyState createState() => _SubCategoryOnlyState();
}

class _SubCategoryOnlyState extends State<SubCategoryOnly> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.lightGrey,
      body:  NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: LightColor.black,
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title:  Text(widget.data['name'],
                      style: GoogleFonts.lato(
                        color: LightColor.background,
                        fontSize: 16.0,
                      )),
                  background: CachedNetworkImage(
                    imageUrl: widget.data['image'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body:Container(
          height: AppTheme.fullHeight(context),
          width: AppTheme.fullWidth(context),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(widget.data['subcategories'].length, (index) => _card(index))
            ),
          ),
        ),
      ),
    );
  }


  _card(index){
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: Category(widget.data['subcategoriesid'][index],widget.data['subcategories'][index]['name']),
            type: PageTransitionType.downToUp
          ));
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            color: LightColor.black,
          ),
          height: AppTheme.fullWidth(context)/2,
          width: AppTheme.fullWidth(context)/1.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.data['subcategories'][index]['image'],
                  placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: AppTheme.fullWidth(context)-50,
                  height: 150,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: AppTheme.fullWidth(context)/1.5,
                    height: 30,
                    color: LightColor.orange.withOpacity(0.5),
                    child: Text(
                     widget.data['subcategories'][index]['name'],
                      style: GoogleFonts.muli(
                        color: LightColor.lightGrey,
                        fontSize: 20
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
