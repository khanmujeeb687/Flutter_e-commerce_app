import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/category.dart';
import 'package:stsr/ui/pages/product.dart';
import 'package:stsr/ui/widgets/category/SubCategoryOnly.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';
import '../../resources/themes/light_color.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<DocumentSnapshot> _data;
  TextEditingController _controller;
  bool loading=false;
  List<Map> results=[];
  List<DocumentSnapshot> _products=[];



  @override
  Future<void> initState(){
    _data=Home.allcats;
_controller=new TextEditingController();
    super.initState();
  }



  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: LightColor.lightGrey,
      child: SingleChildScrollView(
          child: Column(
            children:<Widget>[
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.topCenter,
              color: LightColor.black,
              child: TextField(
                controller: _controller,
                style: GoogleFonts.muli(
                  fontWeight: FontWeight.w400,
                  color: LightColor.darkgrey,
                  fontSize: 17
                ),
                autofocus: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: InputBorder.none,
                  hintText: "search category subcategory or product...",
                  hintStyle: GoogleFonts.muli(
                    fontWeight: FontWeight.w400,
                    color: LightColor.lightblack
                  ),
                ),
                onChanged: (a){
                  _searchincategory(a);
                },
              ),
            ),
            Container(
child:(results.isEmpty)?Container(
                          color: LightColor.lightGrey,
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.searchengin,size: 20,color: Colors.grey,),
                                SizedBox(width: 7,),
                                !loading?Text("Search something..",style: GoogleFonts.muli(
                                    fontSize: 24,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold
                                )):Column(
                                  children: <Widget>[
                                    Text("No results found",style: GoogleFonts.muli(
                                        fontSize: 24,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: LightColor.orange,
                                      child: Text("See suggestions",style: GoogleFonts.muli(color: LightColor.background),),
                                      onPressed: (){
                                        _searchindatabase();
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ):Container(
                      height: MediaQuery.of(context).size.height/1.5,
                            color: LightColor.lightGrey,
                            child:   ListView.builder(
                            itemCount: results.length+1,
                              physics: ScrollPhysics(),
                            itemBuilder: (context,index){
                              if(index==0){
                                return Container(
                                  height: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Icon(Icons.search,color: LightColor.darkgrey,),
                                      Text("Results",style: GoogleFonts.muli(color: LightColor.darkgrey),),
                                    ],
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(results[index-1]['name'],style: GoogleFonts.muli(color: LightColor.skyBlue),),
                                subtitle: Divider(),
                                onTap: (){
                                  _onclickitem(results[index-1]);
                                },
                              );
                            },
                              ),
                        )
            )
          ],
          )
      ),
    );
  }


  void _searchindatabase() async{
    if(_controller.text.isEmpty) return;
    LoaderDialog(context, false,text: "Searching..");
    await Firestore.instance.collection("products").where('productname',isEqualTo: _controller.text)
    .limit(10)
    .getDocuments().then((value) {
      if(value.documents.isNotEmpty){
        _products.clear();
        results.clear();
        _products=value.documents;
        setState(() {
          value.documents.forEach((element) {
            results.add({'name':element['productname'],'type':"product",'id':element.documentID});
          });
        });
      }else{
        Toast.show("No results", context,duration:Toast.LENGTH_LONG,backgroundColor: LightColor.black,textColor: LightColor.orange,gravity: Toast.TOP,backgroundRadius: 6);
      }
    });
    Navigator.pop(context);
  }


  _searchincategory(String query){
    if(query.isEmpty){
      setState(() {
        results.clear();
      });
      return;
    }
    results.clear();
    query=query.toLowerCase();
    for(int i=0;i<_data.length;i++){
      if(_data[i]['name'].toString().toLowerCase().contains(query)){
        setState(() {
          results.add({'name':_data[i]['name'],'type':"category",'id':_data[i].documentID});
        });
      }
      for(int j=0;j<_data[i]['subcategories'].length;j++){
        if(_data[i]['subcategories'][j]['name'].toString().toLowerCase().contains(query)){
          setState(() {
            results.add({'name':_data[i]['subcategories'][j]['name'],'type':"subcategory",'id':_data[i]['subcategoriesid'][j]});
          });
        }
      }
    }
    setState(() {
      loading=true;
      results=results;
    });
  }

  _onclickitem(Map _data){
    switch(_data['type']){
      case 'category':
        {
          for(int i=0;i<this._data.length;i++){
            if(this._data[i].documentID==_data['id']){
              Navigator.push(context, PageTransition(
                  child: SubCategoryOnly(this._data[i]),
                  type: PageTransitionType.fade
              ));
              return;
            }
          }
        }
        break;
      case 'subcategory':
        {
          Navigator.push(context, PageTransition(
              child: Category(_data['id'],_data['name']),
              type: PageTransitionType.fade
          ));
          return;
        }
        break;
      case 'product':
        {
          for(int i=0;i<_products.length;i++){
            if(this._products[i].documentID==_data['id']){
              Navigator.push(context, PageTransition(
                  child: Product(this._products[i]),
                  type: PageTransitionType.fade
              ));
              return;
            }
          }
        }
        break;
    }
  }

}
