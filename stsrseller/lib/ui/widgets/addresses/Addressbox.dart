import 'dart:ui';

import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class Addressbox extends StatefulWidget {
  double top;
  String address;
  String dest;
  Addressbox(this.address,this.top);
  @override
  _AddressboxState createState() => _AddressboxState();
}

class _AddressboxState extends State<Addressbox> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top:widget.top,
      right: 10,
      left: 10,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: LightColor.background,
                borderRadius: BorderRadius.circular(30)
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(Icons.location_on,color: LightColor.orange,size: 30,),
                Flexible(
                  child: Text(
                    widget.address!=null?
                    widget.address
                    :"locate marker at your workshop"
                    ,style: GoogleFonts.lato(color:LightColor.grey),
                    maxLines: 3
                    ,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
