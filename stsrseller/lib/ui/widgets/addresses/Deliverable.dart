import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import 'AddDeliverable.dart';

class Deliverable extends StatefulWidget {
  @override
  _DeliverableState createState() => _DeliverableState();
}

class _DeliverableState extends State<Deliverable> {
  List<DocumentSnapshot> addresses;
  StreamSubscription<QuerySnapshot> _subs;

  @override
  void initState() {
    _start();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffbfbfb),
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("Deliverable Addresses"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LightColor.black,
        child: Icon(Icons.add,color: LightColor.lightGrey,),
        onPressed: (){
          Navigator.push(context, PageTransition(
            child: AddDeliverable(),
            type: PageTransitionType.scale,
            alignment: Alignment.bottomRight
          ));
        },
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.topCenter,
        color: LightColor.lightGrey,
        child: (){
          if(addresses==null){
            return Center(
              child: SpinKitCircle(color: LightColor.orange,),
            );
          }else if(addresses.isEmpty){
            return Center(
              child: Center(child: Text("No address Yet!"))
            );
          }
          return ListView.builder(
            itemCount: addresses.length+1,
            itemBuilder: (context,index){
              if(index==addresses.length){
                return Center(
                  child: Text("Hold an item to remove it",style: GoogleFonts.muli(color: LightColor.darkgrey),),
                );
              }
              return Container(
                margin: EdgeInsets.all(8),
                width: AppTheme.fullWidth(context)-40,
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: LightColor.background
                ),
                child: ListTile(
                  onLongPress: (){
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Remove this item"),action:SnackBarAction(
                      label: "Yes",
                      onPressed: (){
                        Firestore.instance.collection('deliverableaddresses').document(addresses[index].documentID).delete();
                      },
                    ),));
                  },
                    title: Text("Sublocality: "+addresses[index]['sublocality']+", City: "+addresses[index]['city'],style: GoogleFonts.muli(color: LightColor.black),),
                    trailing: Text(addresses[index]['pincode'],style: GoogleFonts.muli(color: LightColor.black),),
                    subtitle:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(addresses[index]['time'].length+1, (i){
                        if(i==addresses[index]['time'].length){
                          return Text("Charge ${addresses[index]['charge']}",style: GoogleFonts.muli(color: LightColor.black),);
                        }
                        return  Text("Timeslot ${i+1}: "+addresses[index]['time'][i],style: GoogleFonts.muli(color: LightColor.black),);
                      }),
                    )
                ),
              );
            },
          );
        }(),
      ),
    );
  }

  _start() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    await Firestore.instance.collection('deliverableaddresses').getDocuments().then((value){
      if(!mounted) return;
      setState(() {
        addresses=value.documents;
      });
      _refresh();
    });
  }
_refresh() async{
  _subs=await Firestore.instance.collection('deliverableaddresses').snapshots().listen((value){
  if(!mounted) return;
  setState(() {
  addresses=value.documents;
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
