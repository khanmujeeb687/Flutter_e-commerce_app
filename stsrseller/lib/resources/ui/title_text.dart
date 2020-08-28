import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  const TitleText(
      {Key key,
      this.text,
      this.fontSize = 18,
      this.color = LightColor.titleTextColor,
      this.fontWeight = FontWeight.w800
      })
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.lato(
            fontSize: fontSize, fontWeight: fontWeight, color: color));
  }
}

MyToast(text,context){
  Toast.show(text, context,backgroundRadius: 5,backgroundColor: LightColor.black,textColor: LightColor.grey,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
}