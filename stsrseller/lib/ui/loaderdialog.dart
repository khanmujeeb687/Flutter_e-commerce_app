
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';


   LoaderDialog(context,bool dismiss,{String text}) {
     FocusScope.of(context).requestFocus(FocusNode());
    showDialog(context: context,
     barrierDismissible: dismiss,
    builder: (context){
      return StatefulBuilder(
        builder: (context,setstate){
          return WillPopScope(
            onWillPop: (){
              if(dismiss){
                Navigator.pop(context);
                return Future.value(true);
              }
            },
            child: AlertDialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: (){
                if(text!=null){
                  return Text(text,style: GoogleFonts.lato(color: LightColor.orange),textAlign: TextAlign.center,);
                }
                return Center(child: SpinKitCircle(color: LightColor.orange,),);
              }(),
            ),
          );
        },
      );
    }
    );
  }

