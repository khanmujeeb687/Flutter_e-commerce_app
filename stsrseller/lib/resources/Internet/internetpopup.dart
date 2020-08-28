import 'package:flutter/material.dart';


void ShowInternetDialog(context){
  showDialog(context: context,
  builder: (context){
    return AlertDialog(
      actions: <Widget>[
        RaisedButton(
          elevation: 0,
          color: Colors.white,
          child: Text("Ok"),
          onPressed: ()=>Navigator.pop(context),
        )
      ],
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      title: Text("No internet connection!"),
      content: Container(height: 100,
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline,size: 30,color: Colors.red,),
            Text("Please connect to internet and try again" ,style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.w400
            ),)
          ],
        ),
      ),
    );
  }
  );
}