import 'dart:ui';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'package:stsrseller/ui/widgets/myproducts/product.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../loaderdialog.dart';

class SingleOrderManage extends StatefulWidget {
  DocumentSnapshot item;
  SingleOrderManage(this.item);
  @override
  _SingleOrderManageState createState() => _SingleOrderManageState();
}

class _SingleOrderManageState extends State<SingleOrderManage> {
String formatted ;
Position _position;
@override
  void initState() {
  formatted = formatTime(int.parse(widget.item['orderdatetime'].toString()));
  getcurrentlocation();
  // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
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
        body: Container(
          width: AppTheme.fullWidth(context)/1.5,
          height: AppTheme.fullHeight(context)/1.5,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ListTile(
                    trailing: IconButton(
                      icon: Icon(Icons.navigation,color: LightColor.orange,),
                      onPressed: (){
                        _launchMapsUrl();
                      },
                    ),
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
                    leading: Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
                    title: Text(" coins${widget.item['status']=="delivered"?" added to your wallet":" to be rewarded"}",style: GoogleFonts.muli(color: LightColor.lightblack),),
                    subtitle: Text(widget.item['coins'].toString(),style: GoogleFonts.muli(color: LightColor.orange),),
                  ),

                  ListTile(
                    leading: Icon(FontAwesomeIcons.sortNumericDown,color: LightColor.orange,),
                    title: Text("Product quantity",style: GoogleFonts.muli(color: LightColor.lightblack),),
                    subtitle: Text(widget.item['quantity'].toString(),style: GoogleFonts.muli(color: LightColor.orange),),
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
                  ),
                      (){
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
                  }(),
                  (){
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
                  }(), (){
        if (widget.item['ifprepaid']){
        return ListTile(
        leading: Icon(FontAwesomeIcons.userAltSlash,color: LightColor.orange,),
        title: Text("Payment type",style: GoogleFonts.muli(color: LightColor.lightblack),),
        subtitle: Text("Prepaid order",style: GoogleFonts.muli(color: LightColor.lightblack),),
        );
        }
        return ListTile(
        leading: Icon(FontAwesomeIcons.userAltSlash,color: LightColor.orange,),
        title: Text("Payment type",style: GoogleFonts.muli(color: LightColor.lightblack),),
        subtitle: Text("Cash on delivery",style: GoogleFonts.muli(color: LightColor.lightblack),),
        );
        }(),
                  (widget.item['status']!="refund generated"
                      && widget.item['status']!="refunded"
                      && widget.item['status']!="cancelled"
                      && widget.item['status']!="delivered"
                  )?Row(
                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      RaisedButton(
                        color: LightColor.orange,
                        child: Text("Change status",style: GoogleFonts.muli(color: LightColor.background),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        onPressed: (){
                          _changestatus();
                        },
                      ),
                      RaisedButton(
                        color: LightColor.orange,
                        child: Text("Cancel order",style: GoogleFonts.muli(color: LightColor.background),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        onPressed: (){
                          _cancelorder();
                        },
                      ),
                    ],
                  ):Container(alignment: Alignment.center,),
                  (widget.item['status']=="refund generated")?RaisedButton(
                    color: LightColor.orange,
                    child: Text("Refunded",style: GoogleFonts.muli(color: LightColor.background),),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    onPressed: ()async{
                      if(await IsConnectedtoInternet()){
                        ShowInternetDialog(context);
                        return;
                      }
                      Firestore.instance.collection('orders').document(widget.item.documentID).updateData({
                        'status':"refunded"
                      });
                      Navigator.pop(context);
                    },
                  ):Container(alignment: Alignment.center,),

                ],
              ),
            ),
          ),
        ),
      ),
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
            })..then((value){
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

  void _changestatus() async{
  showDialog(context: context,
  builder: (context){
    return  AlertDialog(
      backgroundColor: LightColor.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: SingleChildScrollView(
        child: Container(
          decoration:BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(10)
          ),
          alignment: Alignment.center,
          width: AppTheme.fullWidth(context)/1.5,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Change status",style: GoogleFonts.muli(color: LightColor.grey),),
              ),
              (){
              if(widget.item['status']=="order placed"){
                return _buttonwidget("confirmed");
              }
              if(widget.item['status']=="confirmed"){
                return _buttonwidget("shipped");
              }
              if(widget.item['status']=="shipped"){
                return _buttonwidget("out for delivery");
              }
              if(widget.item['status']=="out for delivery"){
                return _buttonwidget("delivered");
              }
              }()
            ],
          ),
        ),
      ),
    );
  }
  );
  }

  _buttonwidget(text){
  return RaisedButton(
    color: LightColor.orange,
    child: Text(text,style: GoogleFonts.muli(color: LightColor.background),),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
    ),
    onPressed: (){
      _updatestatus(text);
    },
  );
  }


  void _updatestatus(text) async{
  LoaderDialog(context, false);
  Firestore.instance.collection('orders').document(widget.item.documentID).updateData({
    'status':text,
    'history':text=="delivered"?true:false
  }).then((value){
    if(text=="delivered" && widget.item['coins']>0){
      Firestore.instance.collection('user').document(widget.item['userid']).get().then((value)async{
        if(value.exists){
          Firestore.instance
             .collection('user')
             .document(value.documentID)
             .updateData({'coins':FieldValue.increment(widget.item['coins'])});
          Firestore.instance.collection('coinstransactions').add({
           'userid':value.documentID,
           'coins':widget.item['coins'],
           'datetime':DateTime.now().millisecondsSinceEpoch,
           'status':'added',
           'shopping':true,
           'referal':false,
           'referalid':"",
            'orderid':widget.item.documentID
         });
         if(value['referredby'].isNotEmpty){
           Firestore.instance.collection('user').where('referalid',isEqualTo: value['referredby']).getDocuments().then((valuea)async{
             if(valuea.documents.isNotEmpty){
                   Firestore.instance
                       .collection('user')
                       .document(valuea.documents.first.documentID)
                       .updateData({'coins':FieldValue.increment(widget.item['coins'])});
                Firestore.instance.collection('coinstransactions').add({
                 'userid':valuea.documents.first.documentID,
                 'coins':widget.item['coins'],
                  'datetime':DateTime.now().millisecondsSinceEpoch,
                 'status':'added',
                 'shopping':false,
                 'referal':true,
                 'referalid':value.documentID,
                  'orderid':widget.item.documentID
                });
             }
           });
         }
        }
      });
    }
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  });
  }

void _launchMapsUrl() async{
  if(await IsConnectedtoInternet()){
    ShowInternetDialog(context);
    return;
  }
  if(widget.item['lat'].isEmpty){
    Toast.show("lat long is empty", context);
    return;
  }
  if(_position==null){
    Toast.show("Try after a bit", context);
    return;
  }

  final url = 'https://www.google.com/maps/dir/?api=1&origin=${_position.latitude},${_position.longitude}&destination=${widget.item['lat']},${widget.item['long']}&travelmode=driving';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


getcurrentlocation() async{
  _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  if(_position==null){
    _position=await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
  }
}


}
