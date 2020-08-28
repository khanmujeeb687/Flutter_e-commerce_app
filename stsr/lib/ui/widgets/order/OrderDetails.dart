import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/DialogInput.dart';
import 'package:stsr/resources/ui/addlocation.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/widgets/product/payments.dart';
import 'package:stsr/ui/widgets/user/MyOrders.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';

class OrderDetails extends StatefulWidget {
  List<dynamic> pids;
  String price;
  VoidCallback clearall;
  OrderDetails(this.pids,this.price,this.clearall);
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {

  String address;
  String charge="0";
  String time="Select a delivery timeslot";
  String pincode=Home.user['pincode'];
  String phone=Home.user['phone'];
  String name=Home.user['name'];
  String houseandbuilding="";
  String temp="";
  String lat="";
  String long="";

  List<dynamic> timeoptions=[];


  @override
  void initState() {
    address=Home.user['address'] ;
    houseandbuilding=Home.user['house'];
    if(address.isNotEmpty){
      _laodadressdata();
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.lightGrey,
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
              _headings("Delivery address"),
              _showvalue(address==""?"Set delivery address":address,()async{
                Map addressdata=await Navigator.push(context, PageTransition(
                    child: AddLocation(),
                    type: PageTransitionType.fade
                ));
                if(addressdata!=null){
                  time="Select a delivery timeslot";
                  timeoptions.clear();
                  setState(() {
                    address=addressdata['address'];
                    charge=addressdata['charge'];
                    timeoptions=addressdata['time'];
                    pincode=addressdata['pincode'];
                    lat=addressdata['lat'];
                    long=addressdata['long'];
                  });
                }
              },trail: true),
              _headings("Pincode"),
              _showvalue(pincode,(){}),
              _headings("Floor & House/Building no."),
              _showvalue(houseandbuilding.isEmpty?"Enter Floor and House/Building no.":houseandbuilding,()async{
                temp=await DialogInput(context, "Floor and House/Building no.", TextInputType.text);
                if(temp.isNotEmpty){
                  setState(() {
                    houseandbuilding=temp;
                  });
                }
              },trail: true),
              _headings("Name"),
              _showvalue(name.isEmpty?"Enter name":name,()async{
                temp=await DialogInput(context, "name", TextInputType.text);
                if(temp.isNotEmpty){
                  setState(() {
                    name=temp;
                  });
                }
              },trail: true),
              _headings("Phone no."),
              _showvalue(phone,()async{
                temp=await DialogInput(context, "phone no.", TextInputType.number);
                if(temp.isNotEmpty && temp.length==10){
                  setState(() {
                    phone=temp;
                  });
                }
              },trail: true),
              SizedBox(height: 15,),
              Divider(),
              _headings("Products."),
              _showvalue(widget.pids.length.toString(),(){}),
              _headings("Delivery Time"),
              _showtime(),
              Container(height: 300,)
            ],
          ),
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
           height: 150,
           alignment: Alignment.bottomCenter,
           child: Column(
             children: <Widget>[
               _headings("Payment"),
               _chargeandprice()
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
      ),
    );
  }
  
  _headings(text){
    return Container(
        margin: EdgeInsets.all(8),
        alignment: Alignment.topLeft,
        child: Text(text,style: GoogleFonts.muli(color:LightColor.lightblack),));
  }


  _showtime(){
    return Container(
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
          title:Text(time.toString(),style: GoogleFonts.muli(color: LightColor.black,fontSize: 13),),
          trailing:IconButton(
            icon: Icon(Icons.edit,color: LightColor.grey,),
            onPressed: ()async{
              _selecttime();
            },
          )
      ),
    );
  }

  _selecttime(){
    showDialog(context: context,
    builder: (context){
      return AlertDialog(
        title: Text("Select a delivery timeslot",style: GoogleFonts.alef(color: LightColor.grey),),
        content: Container(
          width: AppTheme.fullWidth(context)*.7,
          height: AppTheme.fullHeight(context)*.5,
          child: ListView.builder(
              itemCount: timeoptions.length,
              itemBuilder: (context,index){
            return ListTile(
              leading: Icon(Icons.timelapse,color: LightColor.orange,),
              title: Text(timeoptions[index],style: GoogleFonts.alef(color: LightColor.darkgrey),),
              onTap: (){
                setState(() {
                  time=timeoptions[index];
                });
                Navigator.pop(context);
              },
            );
          }),
        ),
      );
    }
    );
  }

  _showvalue(text,VoidCallback onclick,{bool trail=false}){
    return Container(
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        onTap: onclick,
        title: Text(text,style: GoogleFonts.muli(color: LightColor.black,fontSize: 13),),
        trailing: trail?Icon(Icons.edit):Container(height: 0,width: 0,),
      ),
    );
  }
 _chargeandprice(){
    return Container(
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        title: Text("Order value: Rs."+widget.price,style: GoogleFonts.muli(color: LightColor.black,fontSize: 13),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Delivery charge: Rs."+charge,style: GoogleFonts.muli(color: LightColor.black,fontSize: 12),),
            Divider(),
            Text("Payable amount: Rs.${(double.parse(charge)+double.parse(widget.price)).toStringAsFixed(2)}",style: GoogleFonts.muli(color: LightColor.orange,fontSize: 16),),
          ],
        ),
        trailing: RaisedButton(
          color: LightColor.orange,
          child: Text("Place order",style: GoogleFonts.muli(color: LightColor.background),),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          onPressed: (){
          _validateform();
          },
        ),
      ),
    );
  }

  _laodadressdata() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    LoaderDialog(context, false);
    Firestore.instance.collection('deliverableaddresses').where('pincode',isEqualTo: Home.user['pincode']).getDocuments().then((value) async{
      if(value.documents.isNotEmpty){
        if(await _IfDeliver(Position(latitude: double.parse(Home.user['lat'].toString()),longitude: double.parse(Home.user['long'].toString())), value.documents)){
          setState(() {
            charge=value.documents.first['charge'];
            timeoptions=value.documents.first['time'];
            lat=Home.user['lat'];
            long=Home.user['long'];
          });
        }else{
          setState(() {
            address="Currently we are not delivering to your default address! Click here to change address!";
            pincode="";
            charge="0";
          });
        }
      }else{
        setState(() {
          address="Currently we are not delivering to your default address! Click here to change address!";
          pincode="";
          charge="0";
        });
      }
      Navigator.pop(context);
    });
  }

  Future<bool> _IfDeliver(Position position,List<DocumentSnapshot> ourlocation) async{
    if(position==null) return false;
    for(int i=0;i<ourlocation.length;i++){
      double distanceInMeters = await new Geolocator().distanceBetween(position.latitude,position.longitude,
          double.parse(ourlocation[i]['lat'].toString()), double.parse(ourlocation[i]['long'].toString()));
      if(distanceInMeters!=null){
        if(distanceInMeters<=1000){
          return true;
        }
      }
    }
    return false;
  }

  _validateform(){
    if(address.isEmpty){
      Toast.show("Please enter your address", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(pincode.isEmpty){
      Toast.show("Please enter your address", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(houseandbuilding.isEmpty){
      Toast.show("Please enter your floor and house or building no.", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(name.isEmpty){
      Toast.show("Please enter your name", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(phone.isEmpty){
      Toast.show("Please enter your phone", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
     if(phone.length>10 ||phone.length<10){
      Toast.show("Please enter valid phone number", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
      if(charge.isEmpty){
      Toast.show("Please enter your phone", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
      if(time=="Select a delivery timeslot" || time.isEmpty){
      Toast.show("Please select a delivery timeslot", context,gravity: Toast.CENTER,backgroundColor: LightColor.black,textColor: LightColor.orange);
      return;
    }
      Map<String,dynamic> tosend={
        'name':name,
        'phone':phone,
        'productid':"",
        'sellerid':"",
        'userid':Home.user.documentID,
        'quantity':"",
        'orderdatetime':DateTime.now().millisecondsSinceEpoch.toString(),
        'deliveryaddress':houseandbuilding+" ,"+address,
        'deliverycharge':(double.parse(charge)/widget.pids.length).toStringAsFixed(2),
        'status':"order placed",
        'orderprice':"",
        'history':false,
        'deliverbefore':time,
        'ifprepaid':false,
        'productname':"",
        'image':"",
        'ifreviewed':false,
        'reason':"",
        'paymentdetails':{},
        'lat':lat,
        'long':long,
        'coins':0
      };
      Navigator.push(context, PageTransition(
        child: Payments(widget.pids,tosend,charge.toString(),widget.clearall,widget.price),
        type: PageTransitionType.downToUp
      ));

  }




}

