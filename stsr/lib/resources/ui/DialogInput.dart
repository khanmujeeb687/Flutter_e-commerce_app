import 'dart:ui';


import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String> DialogInput(context,text,TextInputType alfa) async{
  TextEditingController _controller=new TextEditingController();
  String a=await showDialog(context: context,barrierDismissible: false,
  builder: (context){
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),
      child: WillPopScope(
        onWillPop: (){},
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          backgroundColor: LightColor.lightGrey,
          title: Text("Enter $text",style: GoogleFonts.muli(color: LightColor.black),),
          content: Container(
            decoration:BoxDecoration(
                color: LightColor.background,
                borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            width: AppTheme.fullWidth(context)/1.5,
            height: 50,
            child: TextField(
              keyboardType: alfa,
              controller: _controller,
              decoration: InputDecoration(
                hintText: text,
                hintStyle: GoogleFonts.muli(color: LightColor.grey),
                border: InputBorder.none
              ),
              style: GoogleFonts.muli(color: LightColor.black),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: LightColor.orange,
              child: Text("Submit",style: GoogleFonts.muli(color: LightColor.background),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
              onPressed: (){
                if(alfa==TextInputType.number && _controller.text.isNotEmpty){
                  _controller.text=_controller.text.replaceAll("-", "");
                  _controller.text=_controller.text.replaceAll(",", "");
                  _controller.text=_controller.text.replaceAll(" ", "");
                  _controller.text=_controller.text.replaceAll(".", "");
                  if(double.parse(_controller.text)<0){
                    _controller.text=_controller.text.replaceAll("-", "");
                  }
                }
                Navigator.pop(context,_controller.text);
              },
            ),
            RaisedButton(
              color: LightColor.lightblack,
              child: Text("Cancel",style: GoogleFonts.muli(color: LightColor.background),),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
              onPressed: (){
                Navigator.pop(context,"");
              },
            ),
          ],
        ),
      ),
    );
  }
  );
  return a;
}