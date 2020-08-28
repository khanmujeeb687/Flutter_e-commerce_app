import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:stsrseller/ui/widgets/myproducts/products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';


class subcategorypage extends StatefulWidget {
  String categoryid;
  String categoryname;
  subcategorypage(this.categoryid,this.categoryname);
  @override
  _subcategorypageState createState() => _subcategorypageState();
}

class _subcategorypageState extends State<subcategorypage> {
  List<String> subcategories=[];
  List<String> subcategoriesid=[];

  @override
  void initState() {
    _fixall(Home.products);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffbfbfb),
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text(widget.categoryname,style: GoogleFonts.muli(),),
             ),
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topCenter,
        color: LightColor.lightGrey,
        child: (){
          if(subcategories==null){
            return Center(
              child: SpinKitCircle(color: LightColor.orange,),
            );
          }else if(subcategories.isEmpty){
            return Center(
              child: SpinKitCircle(color: LightColor.orange,),
            );
          }
          return ListView.builder(
            itemCount: subcategories.length,
            itemBuilder: (context,index){
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, PageTransition(
                        child:Products(subcategoriesid[index],subcategories[index]),
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
                    child: Text(subcategories[index],style: GoogleFonts.muli(color: LightColor.black),),
                  ),
                ),
              );
            },
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
      if(products[i]['categoryid']==widget.categoryid){
      if(!subcategoriesid.contains(products[i]['subcategoryid'])){
        subcategories.add(products[i]['subcategoryname']);
        subcategoriesid.add(products[i]['subcategoryid']);
      }
      }
    }
    setState(() {
      products=products;
      subcategories=subcategories;
    });
  }
}
