import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'file:///G:/IdeaProjects/stsrseller/lib/resources/ui/title_text.dart';
import 'file:///G:/IdeaProjects/stsrseller/lib/ui/widgets/myproducts/addvarient.dart';
import 'package:stsrseller/ui/widgets/myproducts/itemcard.dart';
import 'package:stsrseller/ui/widgets/myproducts/productcurousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
class Product extends StatefulWidget {
  DocumentSnapshot product;
  Product(this.product);
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<DocumentSnapshot> varients=[];
  DocumentSnapshot _product;
  StreamSubscription<DocumentSnapshot> _subs;

  @override
  void initState() {
    _product=widget.product;
    _laodvarients();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xfff8f8f8),
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top*2),
        alignment: Alignment.topCenter,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: ProductCurousel(_product['pictures']),
            ),
            _detailWidget()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LightColor.black,
        child: Icon(Icons.add,color: LightColor.grey,),
        onPressed: (){
          Navigator.push(context, PageTransition(
            child: AddVarient(_product),
            type: PageTransitionType.upToDown
          ));
        },
      ),
    );
  }



  Widget _detailWidget() {
    return DraggableScrollableSheet(
      maxChildSize: 1,
      initialChildSize: .7,
      minChildSize: .7,
      builder: (context, scrollController) {
        return Container(
          padding: AppTheme.padding.copyWith(bottom: 0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Colors.white),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[

                SizedBox(height: 5),
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: LightColor.iconColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.email,color: LightColor.black,),
                  title: Text("Click on a property to change it",style: GoogleFonts.muli(color: LightColor.orange),),
                  subtitle: Text("For example: units in stock,price , discount,description etc.",style: GoogleFonts.muli(color: LightColor.darkgrey),),
                ),
                SizedBox(height: 10,),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          width: AppTheme.fullWidth(context)/2,
                          child: GestureDetector(
                              onTap: ()async{
                                String text=await DialogInput(context, "new productname", TextInputType.text);
                                if(text.isNotEmpty){
                                  Firestore.instance.collection('products').document(_product.documentID).updateData({
                                    'productname':text
                                  });
                                }
                              },
                              child: TitleText(text: _product['productname'], fontSize: 22))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TitleText(
                                text: _product['rating']['count'].toString()+" People rated",
                                fontSize: 15
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(_product['rating']['value'].toString(),style: GoogleFonts.lato(color:LightColor.black),),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 10,
                                width: 100,
                                color: Color(0xfff8f8f8),
                                child: Container(
                                  height: 10,
                                  width:(_product['rating']['value']*100)/5,
                                  color: Colors.yellow,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                _priceanddiscount(),
                SizedBox(height: 15,),
                _sellingprice(),
                SizedBox(height: 15,),
                Divider(),
                _description(),
                Divider(),
                ListTile(
                  leading: Icon(Icons.account_balance,color: LightColor.orange,),
                  title: Text("Units in stock",style: GoogleFonts.muli(),),
                  subtitle: Text(_product['unitsinstock'].toString(),style: GoogleFonts.muli(),),
                  onTap: ()async{
                    String text=await DialogInput(context, "units in stock", TextInputType.number);
                    if(text.isNotEmpty){
                      text=text.replaceAll("-", "");
                      text=text.replaceAll(".", "");
                      text=text.replaceAll(",", "");
                      text=text.replaceAll(" ", "");
                      Firestore.instance.collection('products').document(_product.documentID).updateData({
                        'unitsinstock':int.parse(text)
                      });
                    }
                  },
                ), ListTile(
                  leading: Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
                  title: Text("Coins reward",style: GoogleFonts.muli(),),
                  subtitle: Text(_product['coins'].toString(),style: GoogleFonts.muli(),),
                  onTap: ()async{
                    String text=await DialogInput(context, "coins", TextInputType.number);
                    if(text.isNotEmpty){
                      Firestore.instance.collection('products').document(_product.documentID).updateData({
                        'coins':int.parse(text)
                      });
                    }
                  },
                ),
                SizedBox(height: 15,),
                _seereviews(),
                SizedBox(height: 15,),
                _varients(),

              ],
            ),
          ),
        );
      },
    );
  }

  _priceanddiscount(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
            onTap: ()async{
              String text=await DialogInput(context, "new price", TextInputType.numberWithOptions(decimal: true));
              if(text.isNotEmpty){
                text=text.replaceAll("-", "");
                text=text.replaceAll(".", "");
                text=text.replaceAll(",", "");
                text=text.replaceAll(" ", "");
                Firestore.instance.collection('products').document(_product.documentID).updateData({
                  'price':text
                });
              }
            },
            child: Text("Rs."+_product['price'],style: TextStyle(color: LightColor.grey,decoration: TextDecoration.lineThrough,fontSize: 16),)),
        GestureDetector(
            onTap: ()async{
              String text=await DialogInput(context, "new discount", TextInputType.numberWithOptions(decimal: true));
              if(text.isNotEmpty){
                text=text.replaceAll("-", "");
                text=text.replaceAll(".", "");
                text=text.replaceAll(",", "");
                text=text.replaceAll(" ", "");
                Firestore.instance.collection('products').document(_product.documentID).updateData({
                  'discount':text
                });
              }
            },
            child: Text(_product['discount']+" %OFF",style: TextStyle(color: LightColor.orange,decoration: TextDecoration.underline,fontSize: 16),))
      ],
    );
  }

  _sellingprice(){
    return Container(
      alignment: Alignment.topLeft,
      child:   GestureDetector(     onTap: ()async{
        String text=await DialogInput(context, "new price", TextInputType.numberWithOptions(decimal: true));
        if(text.isNotEmpty){
          text=text.replaceAll("-", "");
          text=text.replaceAll(".", "");
          text=text.replaceAll(",", "");
          text=text.replaceAll(" ", "");
          Firestore.instance.collection('products').document(_product.documentID).updateData({
            'price':text
          });
        }
      },
        child: Text("Just at ${
            double.parse(_product['price'])-((double.parse(_product['price'])*double.parse(_product['discount']))/100)
        }",style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 17),),
      ),
    );
  }
  Widget _description() {
    return GestureDetector(
      onTap: ()async{
        String text=await DialogInput(context, "new description", TextInputType.text);
        if(text.isNotEmpty){
          Firestore.instance.collection('products').document(_product.documentID).updateData({
            'description':text
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TitleText(
            text: "Product Description",
            fontSize: 14,
          ),
          SizedBox(height: 20),
          Text(_product['description'],style: GoogleFonts.muli(color: LightColor.black),),
        ],
      ),
    );
  }
  _seereviews(){
    return ExpansionTile(
      leading: Icon(Icons.star,color: LightColor.yellowColor,),
      title: Text(_product['reviews'].length.toString()+" Product reviews",style: GoogleFonts.muli(color: LightColor.black),),
      children:List.generate(_product['reviews'].length, (index){
        return ListTile(
          title: Text(_product['reviews'][index]['username'],style: GoogleFonts.muli(color: LightColor.lightblack),),
          leading: Icon(FontAwesomeIcons.user,color: LightColor.grey,),
          subtitle: Text(_product['reviews'][index]['review'],style: GoogleFonts.muli(fontSize: 12,color: LightColor.black),),
          isThreeLine: true,
        );
      }),
    );
  }

  _varients(){
    if(varients.isEmpty){
      return Container(alignment: Alignment.center,);
    }
      return Container(
        alignment: Alignment.topLeft,
        height: 250,
        width: AppTheme.fullWidth(context),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
            itemCount: varients.length,
            itemBuilder: (context,index){
              return Itemcard(varients[index]);
        }),
      );

  }
  _laodvarients() async{
    _refresh();
    if(!_product['hasvarients']){
      setState(() {
        varients=[];
      });
      return;
    }
    Firestore.instance.collection('products').where('varients',arrayContains: _product.documentID).getDocuments().then((value){
      setState(() {
        varients=value.documents;
      });
    });
  }
  
  _refresh()async{
    Firestore.instance.collection('products').document(_product.documentID).snapshots().listen((event) {
      if(!mounted) return;
      setState(() {
        _product=event;
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
