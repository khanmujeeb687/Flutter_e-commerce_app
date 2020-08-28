import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CantDeliverHere extends StatelessWidget {
  String value="";

  CantDeliverHere(this.value);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:BorderRadius.circular(15)
      ),
      backgroundColor: LightColor.black,
      title: ListTile(
          leading:Icon(Icons.error,color: LightColor.orange,),
          title:Text("Sorry we don't deliver at $value!",style: GoogleFonts.lato(color: LightColor.grey),)
      ),
      actions: <Widget>[
        RaisedButton(
          color: LightColor.lightGrey,
          child: Text("Continue shopping",style: GoogleFonts.muli(color: LightColor.black),),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
