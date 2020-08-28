import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'Requests.dart';

class ManPowerCategory extends StatefulWidget {
  DocumentSnapshot data;
  ManPowerCategory(this.data);
  @override
  _ManPowerCategoryState createState() => _ManPowerCategoryState();
}

class _ManPowerCategoryState extends State<ManPowerCategory> {
  int man=0;
  int labour=0;
  String _address="";
  String _comment="";
  String _phone;
  TextEditingController _con=new TextEditingController();

  @override
  void initState() {
    _phone=Home.user['phone'];
    _getcurrentlocation();
    // TODO: implement initState
    super.initState();
  }
  var _key=new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("Get "+widget.data['name'],style: GoogleFonts.muli(),),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _needone(),
              _getnums("man"),
              _getnums("labour"),
              Form(
                key: _key,
                child: _otherdetails(),
              )
            ],
          ),
        ),
      ),
    );
  }


  _needone(){
    return Container(
      alignment: Alignment.center,
      width: AppTheme.fullWidth(context)-30,
      decoration: BoxDecoration(
        color: LightColor.black,
        borderRadius: BorderRadius.circular(20)
      ),
      padding: EdgeInsets.all(10),
      child: Wrap(
        spacing: 10,
        runSpacing: 5,
        children: <Widget>[
          Text("Need a ${widget.data['name']} ?",style: GoogleFonts.muli(color: LightColor.orange,fontSize: 25),),
          RaisedButton(
            color: LightColor.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Text("See details",
              style: GoogleFonts.muli(color: LightColor.background),),
            onPressed: (){
              _seedetails();
            },
          )
        ],
      ),
    );
  }

  _getnums(selection){
    return Container(
      margin: EdgeInsets.fromLTRB(0, 7, 0, 7),
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: LightColor.lightGrey,
        borderRadius: BorderRadius.circular(30)
      ),
      child:ListTile(
        title: Text(selection=="man"?widget.data['name']:"Helper",style: GoogleFonts.muli(color: LightColor.darkgrey),),
        subtitle:  Text("Requirement : ${selection=="man"?man.toString():labour.toString()}",style: GoogleFonts.muli(color: LightColor.black),),
        trailing:  Wrap(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_upward,color: LightColor.orange,),
              onPressed: (){
                switch(selection){
                  case "man":setState(() {
                    man++;
                  });
                  break;
                  case "labour":setState(() {
                    labour++;
                  });
                  break;
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward,color: LightColor.orange,),
              onPressed: (){
                switch(selection){
                  case "man":{
                    setState(() {
                      man=man>0?man-1:man;
                    });
                  }
                  break;
                  case "labour":{
                    setState(() {
                      labour=labour>0?labour-1:labour;
                    });
                  }
                  break;
                }
              },
            )
          ],
        ),
      )
    );
  }


  _otherdetails(){
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: <Widget>[
          Text("Complete details", style: GoogleFonts.muli(),),
          Container(
            child: TextFormField(
              controller: _con,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Address",suffixIcon: IconButton(
                icon: Icon(Icons.location_on,color: LightColor.orange,),
                onPressed: (){
                  _getcurrentlocation();
                },
              )),
              style: GoogleFonts.muli(),
              validator: (a) {
                if (a.isEmpty) {
                  return "Please enter address";
                }
                _address=a;
                return null;
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10,bottom: 16),
            child: TextFormField(
              maxLines: 3,
              decoration: InputDecoration(labelText: "comment"),
              style: GoogleFonts.muli(),
              validator: (a) {
                _comment=a;
                return null;
              },
            ),
          ),

          TextFormField(
            keyboardType: TextInputType.phone,
            initialValue: _phone,
            maxLength: 10,
            decoration: InputDecoration(
                labelText: "Phone no."),
            style: GoogleFonts.muli(),
            validator: (a) {
              a = a.replaceAll(" ", "");
              a = a.replaceAll("-", "");
              a = a.replaceAll(".", "");
              a = a.replaceAll(",", "");
              if (a.isEmpty) {
                return "Please enter phone no.";
              }
              _phone=a;
              return null;
            },
          ),
          RaisedButton(
            color: LightColor.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Text("submit",
              style: GoogleFonts.muli(color: LightColor.background),),
            onPressed: () {
              if (_key.currentState.validate()) {
                if(man==0 && labour==0){
                  MyToast("Set number of people ", context);
                  return;
                }
                _addtorequest();
              }
            },
          )
        ],
      ),
    );
  }


  _getcurrentlocation() async {
    Position _position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    if (_position == null) {
      _position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
    }
    if(_position==null) return;
    _getgeocodedaddress(_position);
  }




  _getgeocodedaddress(Position position)async{
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    if(!mounted) return;
    setState(() {
      _address=addresses.first.addressLine;
      _con.text=_address;
    });
  }

  void _seedetails() {
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        builder: (context){
      return Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                title: Text("Name of category",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text(widget.data['name'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ), ListTile(
                title: Text("Work hours for ${widget.data['name']}",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text(widget.data['manhours'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ), ListTile(
                title: Text("Charge per day for ${widget.data['name']}",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text("Rs. "+widget.data['mancharge'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ), ListTile(
                title: Text("Charge for each extra hour for ${widget.data['name']}",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text("Rs. "+widget.data['manovercharge'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ), ListTile(
                title: Text("Work hours for helper",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text(widget.data['labourhours'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ), ListTile(
                title: Text("Charge per day for helper",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text("Rs. "+widget.data['labourcharge'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ), ListTile(
                title: Text("Charge for each extra hour for helper",style: GoogleFonts.muli(color: LightColor.black),),
                subtitle: Text("Rs. "+widget.data['labourovercharge'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _addtorequest() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    LoaderDialog(context, false);
    Firestore.instance.collection('servicerequest').add({
      'datetime':DateTime.now().millisecondsSinceEpoch,
      'man':man,
      'helper':labour,
      'address':_address,
      'comment':_comment,
      'phone':_phone,
      'userid':Home.user.documentID,
      'manpowerid':widget.data.documentID,
      'categoryname':widget.data['name'],
      'image':widget.data['image']
    }).then((value){
      Navigator.pop(context);
      Navigator.pushReplacement(context, PageTransition(
        child: Requests(),
        type: PageTransitionType.downToUp
      ));
    });
  }
}
