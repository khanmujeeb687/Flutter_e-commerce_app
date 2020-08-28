import 'package:stsrseller/ui/widgets/Start/logindecider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



void main() {
  runApp(
    new MaterialApp(
      debugShowCheckedModeBanner: false,
      title:"stsrseller",
      home:LoginDecider()
    )
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
