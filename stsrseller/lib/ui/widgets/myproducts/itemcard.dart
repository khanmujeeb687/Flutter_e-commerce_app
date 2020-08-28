import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/ui/widgets/myproducts/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:auto_size_text/auto_size_text.dart';


class Itemcard extends StatefulWidget {
  DocumentSnapshot item;
  Itemcard(this.item);
  @override
  _ItemcardState createState() => _ItemcardState();
}

class _ItemcardState extends State<Itemcard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: Product(widget.item),
            duration: Duration(milliseconds: 100),
            type: PageTransitionType.fade
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: CachedNetworkImage(
                  imageUrl: widget.item['pictures'][0],
                  placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 110,
                  height: 140,
                ),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: <Widget>[
                  Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,size: 15,),
                  AutoSizeText(widget.item['coins'].toString()+" coins",
                    minFontSize: 15,
                    maxFontSize: 18,
                    style: GoogleFonts.muli(color: LightColor.yellowColor),)
                ],
              ),
              Text(widget.item['productname'][0].toString().toUpperCase()+widget.item['productname'].toString().substring(1),style: GoogleFonts.lato(color: LightColor.black),),
              Text(widget.item['discount']+"% OFF",style: GoogleFonts.lato(decoration: TextDecoration.underline,color: LightColor.orange,fontSize: 13)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Just at ${
                      double.parse(widget.item['price'])-((double.parse(widget.item['price'])*double.parse(widget.item['discount']))/100)
                  }",style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 17),),
                  Text("Rs."+widget.item['price'],style: GoogleFonts.lato(decoration: TextDecoration.lineThrough,color: LightColor.grey,fontSize: 12),),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}


