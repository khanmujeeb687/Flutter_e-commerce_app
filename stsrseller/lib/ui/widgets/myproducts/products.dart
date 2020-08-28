import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'itemcard.dart';

class Products extends StatefulWidget {
  String subcategoryid;
  String subcategory;
  Products(this.subcategoryid,this.subcategory);
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<DocumentSnapshot> items=[];
  @override
  void initState() {
    _fixall(Home.products);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.lightGrey,
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text(widget.subcategory,style: GoogleFonts.muli(),),
      ),
      body: Container(
        color: LightColor.lightGrey,
        child:  (){
          if(items==null){
            return SpinKitCircle(color: LightColor.orange);
          } else if(items.isEmpty){
            return Center(
                child: Text("No items in this category",style: GoogleFonts.lato(color: LightColor.grey))
            );
          }
          return GridView.count(crossAxisCount: 2,
            children: List.generate(items.length, (index){
              return Itemcard(items[index]);
            }),
            childAspectRatio: 0.7,
          );
        }(),
      ),
    );
  }

  void _fixall(List<DocumentSnapshot> products) {
    if(products.isEmpty){
      setState(() {
        products=products;
      });
      return;
    }
    for(int i=0;i<products.length;i++){
      if(products[i]['subcategoryid']==widget.subcategoryid){
        if(!items.contains(products[i])){
          items.add(products[i]);
        }
      }
    }
    setState(() {
      products=products;
      items=items;
    });
  }
}
