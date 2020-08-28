import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/product.dart';
import 'package:stsr/ui/widgets/order/OrderDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  DocumentSnapshot _user;
  StreamSubscription<QuerySnapshot> _subscription;
  StreamSubscription<DocumentSnapshot> _usersubscription;
  double price=0;
  List<String> itemids=[];
  List<DocumentSnapshot> cartitems;
  bool allowed=false;


  Widget _cartItems() {
    if(cartitems==null){
      return _shimmer();
    }
    if(cartitems.isEmpty){
      return Center(child: Column(
        children: <Widget>[
          Icon(Icons.shopping_cart,color: LightColor.orange,size: 50,),
          Text("No items in cart!",style: GoogleFonts.alef(color: LightColor.grey)),
        ],
      ));
    }
    return Column(children:List.generate(cartitems.length, (index){

     return CartItem(cartitems[index],_user,index,removecartitem);
    }));
  }

  Widget _submitButton(BuildContext context) {
    return FlatButton(
        onPressed: () {
          _next();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: !allowed?LightColor.darkgrey:LightColor.orange,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 12),
          width: AppTheme.fullWidth(context) * .7,
          child: TitleText(
            text: 'Next',
            color: LightColor.background,
            fontWeight: FontWeight.w500,
          ),
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        color: LightColor.black,
        padding: AppTheme.padding,
        alignment: Alignment.topCenter,
        height: AppTheme.fullHeight(context)-150,
        margin: EdgeInsets.only(bottom: 100),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _header(),
              SizedBox(height: 20,),
              _cartItems(),
              Divider(
                thickness: 1,
                height: 70,
              ),
              _price(),
              SizedBox(height: 30),
              _submitButton(context),
            ],
          ),
        ),
    );
  }
  Widget _price() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TitleText(
          text: '${_user['cart'].length} Items',
          color: LightColor.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        TitleText(
          text: 'Rs. ${price.toStringAsFixed(2)}',
          fontSize: 18,
          color: LightColor.lightGrey,
        ),
      ],
    );
  }
  _header(){
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TitleText(
            text: 'Shopping',
            fontSize: 27,
            fontWeight: FontWeight.w400,
            color: LightColor.background,
          ),
          TitleText(
            text: 'Cart',
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: LightColor.background,
          ),
        ],
      ),
    );
  }

  _refresh() async{
    if( await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    _usersubscription = Firestore.instance.collection('user').document(Home.user.documentID).snapshots().listen((event) {
      if(!mounted) return;
      setState(() {
        _user=event;
      });
      int l=itemids.length;
      itemids.clear();
      for(int i=0;i<_user['cart'].length;i++){
        itemids.add(_user['cart'][i]['productid']);
      }
      if(l!=itemids.length){
        if(_subscription!=null){
          _subscription.cancel();
        }
        _addproductsubs();
      }
      Home.user=event;
      _calculateprice();
    });
    _addproductsubs();
  }

  _addproductsubs() async{
    if(itemids.isEmpty) return;
    _subscription = Firestore.instance.collection('products').where('productid',whereIn: itemids).snapshots().listen((event) {
      if(!mounted) return;
      if(_user['cart'].isEmpty) return;
      cartitems=event.documents;
      _calculateprice();
    });
  }

  _calculateprice(){
    price=0;
    if(!mounted) return;
    int quantity=1;
    cartitems.forEach((element) {
      for(int x=0;x<_user['cart'].length;x++){
        if(_user['cart'][x]['productid']==element.documentID){
          quantity=_user['cart'][x]['quantity'];
        }
      }
    price=price+ (double.parse(element['price'].toString())-((double.parse(element['price'].toString())*double.parse(element['discount'].toString()))/100))*quantity;
    });
    setState(() {
      price=price;
    });
    _ChangeAllowed();
  }

  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }
    if(_usersubscription!=null){
      _usersubscription.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }
  @override
  void initState() {

    _user=Home.user;
    _loadcartitems();
    // TODO: implement initState
    super.initState();
  }

    _next() async{
    if(!allowed){
    return;
    }
    Navigator.push(context, PageTransition(
      child: OrderDetails(_user['cart'],price.toStringAsFixed(2),(){
        _subscription.cancel();
        _usersubscription.cancel();
        setState(() {
          price=0;
          cartitems.clear();
        });
      }),
      type: PageTransitionType.upToDown
    ));

  }


  _loadcartitems() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    itemids.clear();
    for(int i=0;i<_user['cart'].length;i++){
      itemids.add(_user['cart'][i]['productid']);
    }
    if(itemids.isEmpty){
      if(!mounted) return;
      setState(() {
        cartitems=[];
      });
      return;}
   await Firestore.instance.collection('products').where('productid',whereIn: itemids).getDocuments().then((value){
      if(!mounted) return;
      setState(() {
        cartitems=value.documents;
      });
    });
    _refresh();
    _calculateprice();
  }


  removecartitem(a) {
    setState(() {
      cartitems.removeWhere((element){
        return element.documentID==a;
      });
      _subscription.cancel();
    });
  }


  _ChangeAllowed(){
    allowed=true;
    if(_user['cart'].isEmpty){
      allowed=false;
    }
    for(int i=0;i<cartitems.length;i++){
      for(int j=0;j<_user['cart'].length;j++){
        if(cartitems[i].documentID==_user['cart'][j]['productid']){
          if(int.parse(_user['cart'][j]['quantity'].toString())>int.parse(cartitems[i]['unitsinstock'].toString())){
              allowed=false;
          }
        }
      }
    }
    setState(() {
      allowed=allowed;
    });
  }


  _shimmer(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index){
        return Container(
          width: AppTheme.fullWidth(context)-60,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 40,
                    width: AppTheme.fullWidth(context)-60,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 25,
                    width: AppTheme.fullWidth(context)-60,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 25,
                    width: AppTheme.fullWidth(context)/2,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}


class CartItem extends StatefulWidget {
  DocumentSnapshot Item;
  Function(String a) removewidget;
  DocumentSnapshot user;
  int index;
  CartItem(this.Item,this.user,this.index,this.removewidget(a));
  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    if(widget.user['cart'].isEmpty) return Container(alignment: Alignment.center,);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(15)
      ),
      padding: EdgeInsets.all(15),
      child: !(widget.Item==null)?GestureDetector(
        onTap: (){
          Navigator.push(context, PageTransition(
            child: Product(widget.Item),
            type: PageTransitionType.fade
          ));
        },
        child: Row(
          children: <Widget>[
             Column(
               children: <Widget>[
                 ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: widget.Item['pictures'][0],
                            placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                          )
                 ),
                 RaisedButton(
                   color: LightColor.orange,
                   child: Text("Remove",style: GoogleFonts.muli(color: LightColor.background),),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(5)
                   ),
                   onPressed: ()async{
                     if( await IsConnectedtoInternet()){
                       ShowInternetDialog(context);
                       return;
                     }
                     dynamic cartitem;
                     for(int i=0;i<widget.user['cart'].length;i++){
                       if(widget.user['cart'][i]['productid']==widget.Item.documentID){
                         cartitem=widget.user['cart'][i];
                       }
                     }
                     if(cartitem==null) return;
                     widget.removewidget(cartitem['productid']);
                     Firestore.instance.collection('user').document(widget.user.documentID).updateData({
                       'cart':FieldValue.arrayRemove([cartitem])
                     });
                     //TODO
                   },
                 )
               ],
             ),
            Expanded(
                child: ListTile(
                    title: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: <Widget>[
                        TitleText(
                          text: widget.Item['productname'],
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,size: 15,),
                            AutoSizeText(widget.Item['coins'].toString()+" coins",
                              minFontSize: 7,
                              maxFontSize: 13,
                              style: GoogleFonts.muli(color: LightColor.yellowColor),)
                          ],
                        ),
                      ],
                    ),
                    subtitle: _priceanddiscount(),
                    trailing: GestureDetector(
                      onTap: (){
                        showDialog(context: context,
                        builder: (context){
                          return AlertDialog(
                            title: Text("Change quantity",style: GoogleFonts.muli(color: LightColor.black),),
                            actions: <Widget>[
                              IconButton(
                                icon: Icon(Icons.plus_one),
                                onPressed: ()async{
    if( await IsConnectedtoInternet()){
    ShowInternetDialog(context);
    return;
    }
    List<dynamic> cart=widget.user['cart'];
    dynamic cartitem;
    for(int i=0;i<widget.user['cart'].length;i++){
        if(cart[i]['productid']==widget.Item.documentID){
          cartitem=cart[i];
        }
    }
    if(cartitem==null) return;
    LoaderDialog(context, false);
    cart.remove(cartitem);
    cart.insert(widget.index,{'productid':cartitem['productid'],'quantity':int.parse(cartitem['quantity'].toString())+1});
     Firestore.instance.collection('user').document(Home.user.documentID).updateData({
    'cart':cart
    });
    Navigator.pop(context);
    Navigator.pop(context);
    },),IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: ()async{
                                  if( await IsConnectedtoInternet()){
                                    ShowInternetDialog(context);
                                    return;
                                  }
                                  List<dynamic> cart=widget.user['cart'];
                                  dynamic cartitem;
                                  for(int i=0;i<widget.user['cart'].length;i++){
                                    if(cart[i]['productid']==widget.Item.documentID){
                                      cartitem=cart[i];
                                    }
                                  }
                                  if(cartitem['quantity']==1){
                                  Navigator.pop(context);
                                    return;
                                  }
                                  if(cartitem==null) return;
                                  LoaderDialog(context, false);
                                  cart.remove(cartitem);
                                  cart.insert(widget.index,{'productid':cartitem['productid'],'quantity':int.parse(cartitem['quantity'].toString())-1});
                                  Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                                    'cart':cart
                                  });
                                  Navigator.pop(context);
                                  Navigator.pop(context);

                                },
                              ),
                            ],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                          );
                        }
                        );
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: LightColor.lightGrey.withAlpha(150),
                            borderRadius: BorderRadius.circular(10)),
                        child: TitleText(
                          text: "Qty. "+widget.user['cart'][widget.index]['quantity'].toString(),
                          fontSize: 12,
                        ),
                      ),
                    )))
          ],
        ),
      ):SpinKitCircle(color: LightColor.orange,),
    );
  }

  _priceanddiscount(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Rs."+widget.Item['price'],style: TextStyle(color: LightColor.grey,decoration: TextDecoration.lineThrough,fontSize: 16),),
            Text(widget.Item['discount']+" %OFF",style: TextStyle(color: LightColor.orange,decoration: TextDecoration.underline,fontSize: 16),)
          ],
        ),
        (){
        if(int.parse(widget.Item['unitsinstock'].toString())<1){
          return Text("Out of stock",style: GoogleFonts.muli(color: LightColor.orange),);
        }else if(int.parse(widget.Item['unitsinstock'].toString())<widget.user['cart'][widget.index]['quantity']){
          return Text(widget.Item['unitsinstock'].toString()+" items left! Reduce quantity to continue",style: GoogleFonts.muli(color: LightColor.orange),);
        }
       return _price();
        }()
      ],
    );
  }

  _price(){
    return Text("Rs. ${
        double.parse(widget.Item['price'].toString())-((double.parse(widget.Item['price'].toString())*double.parse(widget.Item['discount'].toString()))/100)
    }",style: GoogleFonts.lato(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 14),);
  }

}

