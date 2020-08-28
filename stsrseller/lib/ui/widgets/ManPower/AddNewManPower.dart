import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/resources/ui/title_text.dart';
import 'package:stsrseller/ui/loaderdialog.dart';
import 'package:stsrseller/ui/widgets/uploadimage.dart';

class AddNewManPower extends StatefulWidget {
  @override
  _AddNewManPowerState createState() => _AddNewManPowerState();
}

class _AddNewManPowerState extends State<AddNewManPower> {
  String catname;
  String manworkperday;
  String labourworkperday;
  String manchargeperday;
  String labourchargeperday;
  String labourovercharge;
  String manovercharge;
  File _image;

  var _key = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.lightGrey,
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("Add Manpower", style: GoogleFonts.muli(),),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        color: LightColor.lightGrey,
        alignment: Alignment.topCenter,
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "categoryname"),
                  style: GoogleFonts.muli(),
                  validator: (a) {
                    if (a.isEmpty) {
                      return "Please enter categoryname";
                    }
                    catname = a;
                    return null;
                  },
                ),
                SizedBox(height: 15,),
                _imagewiget(),
                SizedBox(height: 15,),
                _person(),
                SizedBox(height: 15,),
                _helper(),
                RaisedButton(
                  color: LightColor.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text("Submit",
                    style: GoogleFonts.muli(color: LightColor.background),),
                  onPressed: () {
                    if (_key.currentState.validate()) {
                      if(_image==null){
                        MyToast("Please add an image", context);
                        return;
                      }
                      _addmanpower();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _person() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: <Widget>[
          Text("For person", style: GoogleFonts.muli(),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: (AppTheme.fullWidth(context) / 2) - 50,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "hours a day"),
                  style: GoogleFonts.muli(),
                  validator: (a) {
                    a = a.replaceAll(" ", "");
                    a = a.replaceAll("-", "");
                    a = a.replaceAll(".", "");
                    a = a.replaceAll(",", "");
                    if (a.isEmpty) {
                      return "Please enter something";
                    }
                    manworkperday = a;
                    return null;
                  },
                ),
              ),
              Container(
                width: (AppTheme.fullWidth(context) / 2) - 50,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "charge"),
                  style: GoogleFonts.muli(),
                  validator: (a) {
                    a = a.replaceAll(" ", "");
                    a = a.replaceAll("-", "");
                    a = a.replaceAll(".", "");
                    a = a.replaceAll(",", "");
                    if (a.isEmpty) {
                      return "Please enter something";
                    }
                    manchargeperday = a;
                    return null;
                  },
                ),
              ),

            ],
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: "charge for each extra hour(in Rs.)"),
            style: GoogleFonts.muli(),
            validator: (a) {
              a = a.replaceAll(" ", "");
              a = a.replaceAll("-", "");
              a = a.replaceAll(".", "");
              a = a.replaceAll(",", "");
              if (a.isEmpty) {
                return "Please enter something";
              }
              manovercharge = a;
              return null;
            },
          ),

        ],
      ),
    );
  }


  _helper() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: <Widget>[
          Text("For helper", style: GoogleFonts.muli(),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: (AppTheme.fullWidth(context) / 2) - 50,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "hours a day"),
                  style: GoogleFonts.muli(),
                  validator: (a) {
                    a = a.replaceAll(" ", "");
                    a = a.replaceAll("-", "");
                    a = a.replaceAll(".", "");
                    a = a.replaceAll(",", "");
                    if (a.isEmpty) {
                      return "Please enter something";
                    }
                    labourworkperday = a;
                    return null;
                  },
                ),
              ),
              Container(
                width: (AppTheme.fullWidth(context) / 2) - 50,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "charge"),
                  style: GoogleFonts.muli(),
                  validator: (a) {
                    a = a.replaceAll(" ", "");
                    a = a.replaceAll("-", "");
                    a = a.replaceAll(".", "");
                    a = a.replaceAll(",", "");
                    if (a.isEmpty) {
                      return "Please enter something";
                    }
                    labourchargeperday = a;
                    return null;
                  },
                ),
              ),

            ],
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: "charge for each extra hour(in Rs.)"),
            style: GoogleFonts.muli(),
            validator: (a) {
              a = a.replaceAll(" ", "");
              a = a.replaceAll("-", "");
              a = a.replaceAll(".", "");
              a = a.replaceAll(",", "");
              if (a.isEmpty) {
                return "Please enter something";
              }
              labourovercharge = a;
              return null;
            },
          ),

        ],
      ),
    );
  }

  _imagewiget() {
    return GestureDetector(
      onTap: ()async{
        File ab=await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);
        if(ab!=null){
          setState(() {
            _image=ab;
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: AppTheme.fullHeight(context)/3,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: LightColor.background,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Wrap(
          children: <Widget>[
            Text("Image",style: GoogleFonts.muli(),),
            _image==null?Icon(Icons.add,color: LightColor.orange,size: 50,):Image.file(_image,fit: BoxFit.contain,)
          ],
        )
      ),
    );
  }

  void _addmanpower() async{
    if(await IsConnectedtoInternet()) {
      ShowInternetDialog(context);
      return;
    }
    String text=await showDialog(context: context,builder: (context){return UploadVideo(_image,'manpower');});
    if(text.isNotEmpty){
      LoaderDialog(context, false);
      Firestore.instance.collection('manpower').add({
        'name':catname,
        'image':text,
        'manhours':manworkperday,
        'mancharge':manchargeperday,
        'manovercharge':manovercharge,
        'labourhours':labourworkperday,
        'labourcharge':labourchargeperday,
        'labourovercharge':labourovercharge,
        'datetime':DateTime.now().millisecondsSinceEpoch
      }).then((value){
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }
}
