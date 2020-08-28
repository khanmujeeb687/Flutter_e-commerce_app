import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'package:stsrseller/ui/loaderdialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';

import 'addlocation.dart';

class AddDeliverable extends StatefulWidget {
  @override
  _AddDeliverableState createState() => _AddDeliverableState();
}

class _AddDeliverableState extends State<AddDeliverable> {
  String sublocality="";
  String city="";
  String pincode="";
  List<String> time=[];
  String charge="";
  String lat="";
  String long="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("Complete order"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.topCenter,
        color: LightColor.lightGrey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _headings("Delivery sublocality"),
              _address(),
              _headings("Delivery city"),
              _showvalue(city,false),
              _headings("Delivery Pincode"),
              _showvalue(pincode,false),
              _headings("Time to deliver here"),
              _showtime(),
              _headings("Delivery charge"),
              _showvalue(charge,true),
              RaisedButton(
                color: LightColor.orange,
                child: Text("Submit",style: GoogleFonts.muli(color: LightColor.background),),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
                onPressed: (){
                  _submit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _headings(text){
    return Container(
        margin: EdgeInsets.all(8),
        alignment: Alignment.topLeft,
        child: Text(text,style: GoogleFonts.muli(color:LightColor.lightblack),));
  }

  _address(){
    return Container(
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        title: Text(sublocality==""?"Set delivery sublocality":sublocality,style: GoogleFonts.muli(color: LightColor.black,fontSize: 13),),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: ()async{
            Map addressdata=await Navigator.push(context, PageTransition(
                child: AddLocation(),
                type: PageTransitionType.fade
            ));
            if(addressdata!=null){
             setState(() {
               sublocality=addressdata['sublocality'];
               city=addressdata['city'];
               pincode=addressdata['pincode'];
               lat=addressdata['lat'];
               long=addressdata['long'];
             });
            }
          },
        ),

      ),
    );
  }

_showtime(){
  return Container(
    alignment: Alignment.center,
    decoration:BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(10)
    ),
    child: ListTile(
      onLongPress: (){
        setState(() {
          time.removeLast();
        });
      },
      title: Column(
        children: List.generate(time.length, (index){
          return Text(time[index].toString(),style: GoogleFonts.muli(color: LightColor.black,fontSize: 13),);
        }),
      ),
      trailing:IconButton(
            icon: Icon(Icons.edit,color: LightColor.grey,),
            onPressed: ()async{
              String a=await DialogInput(context, "Delivery timeslot(Example:Tommorow 7am to 8 am etc.)",TextInputType.text);
              if(a.isEmpty)return;
                setState(() {
                  time.add(a);
                });

            },
          )
        ),
  );
}

  _showvalue(text,bool trailing){
    return Container(
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        title: Text(text.toString(),style: GoogleFonts.muli(color: LightColor.black,fontSize: 13),),
        trailing: (){
          if(trailing){
            return IconButton(
              icon: Icon(Icons.edit,color: LightColor.grey,),
              onPressed: ()async{
                String a=await DialogInput(context,"Delivery charge",TextInputType.number);
                if(a.isEmpty)return;
                  if(int.parse(a)<0){
                    a=a.replaceAll('-', "");
                  }
                  setState(() {
                    charge=a;
                  });
              },
            );
          }
          return Container(alignment: Alignment.center,width: 0,height: 0,);
        }(),
      ),
    );
  }

  void _submit() {
    if(city.isEmpty){
      Toast.show("Please enter city", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(pincode.isEmpty){
      Toast.show("Please enter pincode", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(sublocality.isEmpty || sublocality==null){
      Toast.show("Please enter sublocality", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;

     }
     if(charge.isEmpty){
      Toast.show("Please enter charge", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
     }
     if(time.isEmpty){
      Toast.show("Please enter time", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
     }
     LoaderDialog(context, false);
     Firestore.instance.collection('deliverableaddresses').add({
       'sublocality':sublocality,
       'city':city,
       'pincode':pincode,
       'charge':charge,
       'time':time,
       'lat':lat,
       'long':long,
       'radius':1000
     }).then((value){
       Navigator.pop(context);
       Navigator.pop(context);
     });
  }
}
