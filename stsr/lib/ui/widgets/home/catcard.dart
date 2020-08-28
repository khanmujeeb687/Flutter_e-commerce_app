import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/pages/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class CatCard extends StatefulWidget {
  Map<dynamic,dynamic> cardadate;
  String catid;
  CatCard(this.cardadate,this.catid);
  @override
  _CatCardState createState() => _CatCardState();
}

class _CatCardState extends State<CatCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: Category(widget.catid,widget.cardadate['name']),
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
                  imageUrl: widget.cardadate['image'],
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
              child: Text(widget.cardadate['name'][0].toString().toUpperCase()+widget.cardadate['name'].toString().substring(1),style: GoogleFonts.muli(color: LightColor.black),textAlign: TextAlign.left,),
            )
          ],
        ),
      ),
    );
  }
}
