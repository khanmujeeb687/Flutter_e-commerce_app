import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/cartpage.dart';
import 'package:stsr/ui/pages/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../loaderdialog.dart';

class Itemcard extends StatefulWidget {
  DocumentSnapshot item;
  DocumentSnapshot user;
  bool varient;
  Itemcard(this.item,this.varient,this.user);
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
          if(widget.varient){
            Navigator.pushReplacement(context, PageTransition(
                child: Product(widget.item),
                type: PageTransitionType.fade
            ));
            return;
          }
          Navigator.push(context, PageTransition(
            child: Product(widget.item),
            type: PageTransitionType.fade
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,size: 15,),
                      AutoSizeText(widget.item['coins'].toString()+" coins",
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
                      if(widget.user['wishlist'].contains(widget.item.documentID)){
                        Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                          'wishlist':FieldValue.arrayRemove([widget.item.documentID])
                        });
                        return;
                      }
                      Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                        'wishlist':FieldValue.arrayUnion([widget.item.documentID])
                      });
                    },
                    child: Icon(widget.user['wishlist'].contains(widget.item.documentID)? Icons.favorite : Icons.favorite_border,
                        color:widget.user['wishlist'].contains(widget.item.documentID)? LightColor.red : LightColor.lightGrey,
                        size: 25,
                    ),
                  ),
                ],
              ),
              Center(
                child: CachedNetworkImage(
                  imageUrl: widget.item['pictures'][0],
                  placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
              AutoSizeText(widget.item['productname'][0].toString().toUpperCase()+widget.item['productname'].toString().substring(1),
                style: GoogleFonts.lato(color: LightColor.black),),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  (int.parse(widget.item['unitsinstock'].toString())>0)? AutoSizeText(widget.item['discount']+"% OFF",style: GoogleFonts.lato(decoration: TextDecoration.underline,color: LightColor.orange,fontSize: 13)):Container(height: 0,width: 0,),
                  (){
                  if(widget.item['unitsinstock']<=0) return Container(height: 0,width: 0,);
                    if(IfCartCOntaines(widget.item.documentID,widget.user)){
                      return RaisedButton(
                        padding: EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        color: LightColor.orange,
                        child: AutoSizeText("Cart->",style: GoogleFonts.muli(color: LightColor.background),),
                        onPressed: (){
                          Navigator.push(context, PageTransition(
                              child: CartPage(),
                              type: PageTransitionType.fade
                          ));
                        },
                      );
                    }
                    return RaisedButton(
                      padding: EdgeInsets.all(2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      color: LightColor.orange,
                      child: AutoSizeText("+Add",style: GoogleFonts.muli(color: LightColor.background),),
                      onPressed: ()async{
                        if(await IsConnectedtoInternet()){
                          ShowInternetDialog(context);
                          return;
                        }
                        LoaderDialog(context, false);
                        List<dynamic> cart=Home.user['cart'];
                        cart.add({
                          'productid':widget.item.documentID,
                          'quantity':1
                        });
                        Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                          'cart':cart
                        }).then((value){
                          setState(() {

                          });
                          Navigator.pop(context);
                        });
                      },
                    );
                  }()
                ],
              ),
              (int.parse(widget.item['unitsinstock'].toString())<=0)?
              AutoSizeText("Out of Stock",style: GoogleFonts.lato(color:LightColor.orange,fontWeight: FontWeight.bold,fontSize: 15),)
                  :Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0,
                children: <Widget>[
                  AutoSizeText("Just at Rs. ${
                      double.parse(widget.item['price'].toString())-((double.parse(widget.item['price'].toString())*double.parse(widget.item['discount'].toString()))/100)
                  }",
                    minFontSize: 8,
                    maxFontSize: 14,
                    style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold),),
                  AutoSizeText("Rs."+widget.item['price'].toString(),style: GoogleFonts.lato(decoration: TextDecoration.lineThrough,color: LightColor.grey,fontSize: 12),),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }



  bool IfCartCOntaines(String id,DocumentSnapshot user){
    for(int i=0;i<user['cart'].length;i++){
      if(user['cart'][i]['productid']==id){
        return true;
      }
    }
    return false;
  }
}
