import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/DialogInput.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/cartpage.dart';
import 'file:///G:/IdeaProjects/stsr/lib/ui/widgets/home/cart.dart';
import 'package:stsr/ui/widgets/category/itemcard.dart';
import 'package:stsr/ui/widgets/order/OrderDetails.dart';
import 'package:stsr/ui/widgets/product/productcurousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';
class Product extends StatefulWidget {
  DocumentSnapshot product;
  Product(this.product);
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<DocumentSnapshot> varients;
  StreamSubscription<DocumentSnapshot> _subscription;
  DocumentSnapshot _user;

  @override
  void initState() {
    _user=Home.user;
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
              child: ProductCurousel(widget.product['pictures']),
            ),
            _detailWidget()
          ],
        ),
      ),
        bottomSheet: BottomSheet(
          backgroundColor: LightColor.lightGrey,
          builder: (context){
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: LightColor.background,
              ),
              height: 70,
              alignment: Alignment.bottomCenter,
              child: Column(
                children: <Widget>[
                  _addtocart()
                ],
              ),
            );
          },
          onClosing: (){
          },
          elevation: 15,
          enableDrag: false,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
        )
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,size: 15,),
                        AutoSizeText(widget.product['coins'].toString()+" coins",
                          minFontSize: 15,
                          maxFontSize: 18,
                          style: GoogleFonts.muli(color: LightColor.yellowColor),)
                      ],
                    ),
                    GestureDetector(
                      onTap: ()async{
                        if(await IsConnectedtoInternet()){
                          ShowInternetDialog(context);
                          return;
                        }
                        if(_user['wishlist'].contains(widget.product.documentID)){
                          Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                            'wishlist':FieldValue.arrayRemove([widget.product.documentID])
                          });
                          return;
                        }
                        Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                          'wishlist':FieldValue.arrayUnion([widget.product.documentID])
                        });
                      },
                      child: Icon(Home.user['wishlist'].contains(widget.product.documentID)? Icons.favorite : Icons.favorite_border,
                        color:Home.user['wishlist'].contains(widget.product.documentID)? LightColor.red : LightColor.lightGrey,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          width: AppTheme.fullWidth(context)/2,
                          child: TitleText(text: widget.product['productname'], fontSize: 22)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TitleText(
                                text: widget.product['rating']['count'].toStringAsFixed(0)+" People rated",
                                fontSize: 15
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(widget.product['rating']['value'].toStringAsFixed(0),style: GoogleFonts.lato(color:LightColor.black),),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 10,
                                width: 100,
                                color: Color(0xfff8f8f8),
                                child: Container(
                                  height: 10,
                                  width:(widget.product['rating']['value']*100)/5,
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
                SizedBox(height: 15,),
                _seereviews(),
                SizedBox(height: 15,),
                (){
                if(varients==null){
                  return Container(alignment: Alignment.center,);
                }
                if(varients.isEmpty){
                  return Container(alignment: Alignment.center,);
                }
                 return _headings("See varients");
                }(),
                SizedBox(height: 15,),
                _varients(),
                SizedBox(height: 15,),


              ],
            ),
          ),
        );
      },
    );
  }
  _headings(text){
    return Container(
        margin: EdgeInsets.all(8),
        alignment: Alignment.topLeft,
        child: Text(text,style: GoogleFonts.muli(color:LightColor.lightblack),));
  }
  _priceanddiscount(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("Rs."+widget.product['price'],style: TextStyle(color: LightColor.grey,decoration: TextDecoration.lineThrough,fontSize: 16),),
        Text(widget.product['discount']+" %OFF",style: TextStyle(color: LightColor.orange,decoration: TextDecoration.underline,fontSize: 16),)
      ],
    );
  }

  _sellingprice(){
    return Container(
      alignment: Alignment.topLeft,
      child:   Text("Just at Rs. ${
          double.parse(widget.product['price'])-((double.parse(widget.product['price'])*double.parse(widget.product['discount']))/100)
      }",style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 17),),
    );
  }
  Widget _description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TitleText(
          text: "Product Description",
          fontSize: 14,
        ),
        SizedBox(height: 20),
        Text(widget.product['description'],style: GoogleFonts.muli(color: LightColor.black),),
      ],
    );
  }
  _seereviews(){
    return ExpansionTile(
      leading: Icon(Icons.star,color: LightColor.yellowColor,),
      title: Text(widget.product['reviews'].length.toString()+" Product reviews",style: GoogleFonts.muli(color: LightColor.black),),
      children:List.generate(widget.product['reviews'].length, (index){
        return ListTile(
          title: Text(widget.product['reviews'][index]['username'],style: GoogleFonts.muli(color: LightColor.lightblack),),
          leading: Icon(FontAwesomeIcons.user,color: LightColor.grey,),
          subtitle: Text(widget.product['reviews'][index]['review'],style: GoogleFonts.muli(fontSize: 12,color: LightColor.black),),
          isThreeLine: true,
        );
      }),
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
  _addtocart(){
    if(int.parse(widget.product['unitsinstock'].toString())>0){
    return Row(
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       mainAxisSize: MainAxisSize.max,
       children: <Widget>[
     Container(
     width: AppTheme.fullWidth(context)/2,
    child: RaisedButton(
    color: LightColor.background,
    child: Text("Buy now",style: GoogleFonts.muli(color: LightColor.orange),),
    onPressed: ()async{
    String quantity = await DialogInput(context, "quantity", TextInputType.number);
    if(int.parse(quantity)>int.parse(widget.product['unitsinstock'].toString())){
      Toast.show("Reduce quantity to continue", context);
      return;
    }
    if(int.parse(quantity)==0){
      Toast.show("increase quantity to continue", context);
      return;
    }

    if(quantity.isNotEmpty){
      String price=(double.parse(widget.product['price'])-((double.parse(widget.product['price'])*double.parse(widget.product['discount']))/100)
      ).toString();
      Map cartitem={'quantity':int.parse(quantity),'productid':widget.product.documentID};
      Navigator.push(context, PageTransition(
          child: OrderDetails([cartitem],(int.parse(quantity)*double.parse(price)).toString(),(){}),
          type: PageTransitionType.upToDown
      ));
    }else{
      Toast.show("Add quantity to continue", context);
    }
    },
    ),
    ),
         (){
           if(IfCartCOntaines(widget.product.documentID,_user)){
             return Container(
               width: (AppTheme.fullWidth(context)/2)-10,
               child: RaisedButton(
                 color: LightColor.orange,
                 child: Text("Go to cart",style: GoogleFonts.muli(color: LightColor.background),),
                 onPressed: (){
                   Navigator.push(context, PageTransition(
                       child: CartPage(),
                       type: PageTransitionType.fade
                   ));
                 },
               ),
             );
           }
           return Container(
             width: (AppTheme.fullWidth(context)/2)-10,
             child: RaisedButton(
               color: LightColor.orange,
               child: Text("Add to cart",style: GoogleFonts.muli(color: LightColor.background),),
               onPressed: ()async{
                 if(await IsConnectedtoInternet()){
                   ShowInternetDialog(context);
                   return;
                 }
                 LoaderDialog(context, false);
                 List<dynamic> cart=Home.user['cart'];
                 cart.add({
                   'productid':widget.product.documentID,
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
             ),
           );
         }()
       ],
     );
    }else{
    return  Container(
      width: AppTheme.fullWidth(context),
      child: RaisedButton(
        color: LightColor.lightGrey,
        child: Text("Out of stock"),
      ),
    );
    }
  }
  _varients(){
    if(varients==null){
      return Center(child: SpinKitCircle(color: Colors.orange,),);
    }
    else if(varients.isEmpty){
      return Container(alignment: Alignment.center,);
    }else{
      return Container(
        height: 300,
        width: AppTheme.fullWidth(context),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: varients.length,
            itemBuilder: (context,index){
              return Itemcard(varients[index],true,_user);
        }),
      );
    }
  }
  _laodvarients() async{
    await _refresh();
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    if(!widget.product['hasvarients']){
      if(!mounted) return;
      setState(() {
        varients=[];
      });
      return;
    }
    Firestore.instance.collection('products').where('varients',arrayContains: widget.product.documentID).getDocuments().then((value){
      if(!mounted) return;

      setState(() {
        varients=value.documents;
      });
    });
  }

  _refresh() async{
    if( await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    _subscription = Firestore.instance.collection('user').document(Home.user.documentID).snapshots().listen((event) {
      setState(() {
        _user=event;
      });
      Home.user=event;
    });
  }

  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }
}
