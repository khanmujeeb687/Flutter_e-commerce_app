import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/DialogInput.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:toast/toast.dart';

class SingleOrderManage extends StatefulWidget {
  DocumentSnapshot item;
  SingleOrderManage(this.item);
  @override
  _SingleOrderManageState createState() => _SingleOrderManageState();
}

class _SingleOrderManageState extends State<SingleOrderManage> {
String formatted ;
@override
  void initState() {
  formatted = formatTime(int.parse(widget.item['orderdatetime'].toString()));
  // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: LightColor.black,
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                    onPressed: (){
                      LoaderDialog(context, false);
                      Firestore.instance.collection('products').document(widget.item['productid']).get().then((value){
                        if(!value.exists){
                          Navigator.pop(context);
                          return;
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(context, PageTransition(
                            child: Product(value),
                            type: PageTransitionType.downToUp
                        ));
                      });
                    },
                    color: LightColor.orange,
                    icon:Icon(Icons.card_travel,color: LightColor.orange,)
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title:  Text(widget.item['productname'],
                      style: GoogleFonts.lato(
                        color: LightColor.darkgrey,
                        fontSize: 16.0,
                      )),
                  background: CachedNetworkImage(
                    imageUrl: widget.item['image'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
      body:Container(
        alignment: Alignment.center,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.location_on,color: LightColor.orange,),
                  title: Text("Delivery address",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['deliveryaddress'],style: GoogleFonts.muli(color: LightColor.lightblack),),
                ),
                ListTile(
                  leading: Icon(Icons.access_time,color: LightColor.orange,),
                  title: Text("Ordered ${formatted}",style: GoogleFonts.muli(color: LightColor.lightblack),),
                ),
                ListTile(
                  leading: Icon(Icons.monochrome_photos,color: LightColor.orange,),
                  title: Text("Order value",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text("Rs. "+widget.item['orderprice'],style: GoogleFonts.muli(color: Colors.green,fontWeight: FontWeight.w600),),
                ), ListTile(
                  leading: Icon(FontAwesomeIcons.moneyBillAlt,color: LightColor.orange,),
                  title: Text("Delivery charge",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text("Rs. "+widget.item['deliverycharge'],style: GoogleFonts.muli(color: LightColor.orange),),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.sortNumericDown,color: LightColor.orange,),
                  title: Text("Product quantity",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['quantity'].toString(),style: GoogleFonts.muli(color: LightColor.orange),),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
                  title: Text(" coins${widget.item['status']=="delivered"?" added to your wallet":" to be rewarded"}",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['coins'].toString(),style: GoogleFonts.muli(color: LightColor.orange),),
                ),

                ListTile(
                  leading: Icon(Icons.done_outline,color: LightColor.orange,),
                  title: Text("Delivery duration",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['deliverbefore'],style: GoogleFonts.muli(color: LightColor.lightblack),),
                ),
                ListTile(
                  leading: Icon(Icons.transfer_within_a_station,color: LightColor.orange,),
                  title: Text("Status",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['status'],style: GoogleFonts.muli(color: LightColor.lightblack),),
                ),
                ListTile(
                  leading: Icon(Icons.phone,color: LightColor.orange,),
                  title: Text("Reciever phone no.",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['phone'],style: GoogleFonts.muli(color: LightColor.lightblack),),
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.user,color: LightColor.orange,),
                  title: Text("Reciever name",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  subtitle: Text(widget.item['name'],style: GoogleFonts.muli(color: LightColor.lightblack),),
                ),(){
                  if (widget.item['status']=="refund generated"
                      || widget.item['status']=="refunded"
                      || widget.item['status']=="cancelled"
                  ){
                    return ListTile(
                      leading: Icon(FontAwesomeIcons.userAltSlash,color: LightColor.orange,),
                      title: Text("Cancel reason",style: GoogleFonts.muli(color: LightColor.lightblack),),
                      subtitle: Text(widget.item['reason'],style: GoogleFonts.muli(color: LightColor.lightblack),),
                    );
                  }
                  return Container(alignment: Alignment.center,);
                }(),(){
                  if (widget.item['ifprepaid']){
                    return ExpansionTile(
                      leading: Icon(FontAwesomeIcons.userAltSlash,color: LightColor.orange,),
                      title: Text("Payment details",style: GoogleFonts.muli(color: LightColor.lightblack),),
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.info,color: LightColor.orange,),
                          title:Text("Transaction id",style: GoogleFonts.muli(color: LightColor.black),) ,
                          subtitle:Text(widget.item['paymentdetails']['transactionid'],style: GoogleFonts.muli(color: LightColor.black),) ,
                        ),
                        ListTile(
                          leading: Icon(Icons.info,color: LightColor.orange,),
                          title:Text("Transaction reference",style: GoogleFonts.muli(color: LightColor.black),) ,
                          subtitle:Text(widget.item['paymentdetails']['transactionref'],style: GoogleFonts.muli(color: LightColor.black),) ,
                        ),
                        ListTile(
                          leading: Icon(Icons.info,color: LightColor.orange,),
                          title:Text("Transaction status",style: GoogleFonts.muli(color: LightColor.black),) ,
                          subtitle:Text(widget.item['paymentdetails']['status'],style: GoogleFonts.muli(color: LightColor.black),) ,
                        ),
                      ],
                    );
                  }
                  return Container(alignment: Alignment.center,);
                }(),(){
                  if (widget.item['ifprepaid']){
                    return ListTile(
                      leading: Icon(FontAwesomeIcons.userAltSlash,color: LightColor.orange,),
                      title: Text("Payment type",style: GoogleFonts.muli(color: LightColor.lightblack),),
                      subtitle: Text("Prepaid order",style: GoogleFonts.muli(color: LightColor.lightblack),),
                    );
                  }
                  return ListTile(
                    leading: Icon(FontAwesomeIcons.moneyCheck,color: LightColor.orange,),
                    title: Text("Payment type",style: GoogleFonts.muli(color: LightColor.lightblack),),
                    subtitle: Text("Cash on delivery",style: GoogleFonts.muli(color: LightColor.lightblack),),
                  );
                }(),
                (widget.item['status']!="refund generated"
                    && widget.item['status']!="refunded"
                    && widget.item['status']!="cancelled"
                    && widget.item['status']!="delivered"
                    && DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.item['orderdatetime'])))<Duration(hours: 1)
                )?RaisedButton(
                  color: LightColor.orange,
                  child: Text("Cancel order",style: GoogleFonts.muli(color: LightColor.background),),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                  onPressed: ()async{
                   await showDialog(context: context,
                        builder: (context){
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                            backgroundColor: LightColor.background,
                            title: ListTile(
                                title: Text("Alert: If you cancel this order then other items you ordered with this product may get cancelled. If their value is less than Rs. 100",
                                style: GoogleFonts.muli(color: LightColor.darkgrey),
                                )),
                            actions: <Widget>[
                              RaisedButton(
                                color: LightColor.orange,
                                child: Text("Cancel order",style: GoogleFonts.muli(color: LightColor.background),),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                onPressed: (){
                                  Navigator.pop(context);
                                  _cancelorder();
                                },
                              )
                            ],
                          );
                        }
                    );
                  },
                ):(){
                if(widget.item['status']=="delivered"){
                  return Container(
                    alignment: Alignment.center,
                    width: AppTheme.fullWidth(context)/1.5,
                    height: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          color: LightColor.darkgrey,
                          child: Text("Feedback",style: GoogleFonts.muli(color: LightColor.background),),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          onPressed: (){
                          },
                        ),
                        RaisedButton(
                          color: LightColor.orange,
                          child: Text("Review",style: GoogleFonts.muli(color: LightColor.background),),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          onPressed: (){
                            if(widget.item['ifreviewed']){
                              Toast.show("Review submitted successfully", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
                            }else{
                              _review();
                            }
                          },
                        )
                      ],
                    ),
                  );
                }
                return Container(alignment: Alignment.center,);
                }()
              ],
            ),

          ),

        ),
      ),


    )
    );
  }

  _cancelorder()async{
    String reason="";
  await showDialog(context: context,
  builder: (context){
    return AlertDialog(
      backgroundColor: LightColor.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Container(
        decoration:BoxDecoration(
            color: LightColor.background,
            borderRadius: BorderRadius.circular(10)
        ),
        alignment: Alignment.center,
        width: AppTheme.fullWidth(context)/1.5,
        height: 50,
        child: ListTile(
          title: Text(reason.isEmpty?"Enter reason":reason,style: GoogleFonts.muli(color: LightColor.grey),),
          onTap: ()async{

            reason=await DialogInput(context, "Cancellation Reason", TextInputType.text);
            setState(() {
              reason=reason;
            });
          },
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          color: LightColor.orange,
          child: Text("Confirm cancel",style: GoogleFonts.muli(color: LightColor.background),),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          onPressed: ()async{

            String categoryid="";
            String subcategoryid="";
            if(reason.isEmpty){
              Toast.show("Please enter a reason for cancellation", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
              return;
            }
            if(await IsConnectedtoInternet()){
              ShowInternetDialog(context);
              return;
            }
            LoaderDialog(context, false,text: "Cancelling order");
            String status=widget.item['ifprepaid']?"refund generated":"cancelled";
            Firestore.instance.collection('orders').document(widget.item.documentID).updateData({
              'status':status,
              'reason':reason,
              'history':true
            }).then((value){
              Firestore.instance.collection('products').document(widget.item['productid']).updateData({
                'unitsinstock':FieldValue.increment(int.parse(widget.item['quantity'].toString()))
              }).then((value)async{
               await Firestore.instance.collection('products').document(widget.item['productid']).get().then((value){
                  categoryid=value['categoryid'];
                  subcategoryid=value['subcategoryid'];
                }).then((value){
                  Firestore.instance.collection('categories').document(categoryid).updateData({
                    'soldcount':FieldValue.increment(-int.parse(widget.item['quantity'].toString())),
                    'totalearning':FieldValue.increment(-double.parse(widget.item['orderprice'].toString()))
                  });
                  Firestore.instance.collection('subcategories').document(subcategoryid).updateData({
                    'soldcount':FieldValue.increment(-int.parse(widget.item['quantity'].toString())),
                    'totalearning':FieldValue.increment(-double.parse(widget.item['orderprice'].toString()))
                  });
                });
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              });
            });
          },
        )
      ],
    );
  }
  );
  }
_headings(text){
  return Container(
      margin: EdgeInsets.all(8),
      alignment: Alignment.topLeft,
      child: Text(text,style: GoogleFonts.muli(color:LightColor.lightblack),));
}


_review() async{
    String review="";
    double rating=3;
    await showDialog(context: context,
        builder: (context){
      return AlertDialog(
        backgroundColor: LightColor.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _headings("Scroll horizontally to rate"),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(0),
                child: RatingBar(
                initialRating: rating,
                itemCount: 5,
                itemBuilder: (context, index) {
                switch (index) {
                case 0:
                return Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
                );
                case 1:
                return Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
                );
                case 2:
                return Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
                );
                case 3:
                return Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
                );
                case 4:
                return Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
                );
                  default:{
                   return Icon(Icons.error);
                  }
                }
                },
                onRatingUpdate: (r) {
                rating=r;
                },
                  glow: true,
                )
              ),
              _headings("write a review"),
              Container(
                decoration:BoxDecoration(
                    color: LightColor.background,
                    borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                width: AppTheme.fullWidth(context)/1.5,
                height: 50,
                child: ListTile(
                  title: Text(review.isEmpty?"Enter review":review,style: GoogleFonts.muli(color: LightColor.grey),),
                  onTap: ()async{
                    review=await DialogInput(context, "review", TextInputType.text);
                    setState(() {
                      review=review;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            color: LightColor.orange,
            child: Text("Submit review",style: GoogleFonts.muli(color: LightColor.background),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
            onPressed: ()async{
              if(review.isEmpty){
                Toast.show("Please enter a review", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
                return;
              }
              if(await IsConnectedtoInternet()){
                ShowInternetDialog(context);
                return;
              }
              LoaderDialog(context, false,text: "Submitting review");
              Firestore.instance.collection('orders').document(widget.item.documentID).updateData({
                'ifreviewed':true,
              }).then((value){
                Firestore.instance.collection('products').document(widget.item['productid']).updateData({
                  'reviews':FieldValue.arrayUnion([{
                    'datetime':DateTime.now().millisecondsSinceEpoch.toString(),
                    'review':review,
                    'userid':Home.user.documentID,
                    'username':Home.user['name'].isEmpty?"unknown":Home.user['name'],
                  }])
                }).then((value) async{
                  await increaserating(rating);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              });
            },
          )
        ],
      );
    }
    );
  }

  increaserating(double rating) async{
  Firestore.instance.collection('products').document(widget.item['productid']).get().then((value){
    double ratingvalue=double.parse(value['rating']['value'].toString());
    double ratingcount=double.parse(value['rating']['count'].toString());
    double finalrating=((ratingvalue*ratingcount)+rating)/(ratingcount+1);
    Firestore.instance.collection('products').document(widget.item['productid']).updateData({
      'rating':{
        'value':finalrating,
        'count':ratingcount+1
      }
    });
  });
  }
}
