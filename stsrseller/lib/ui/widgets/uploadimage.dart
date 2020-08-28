import 'dart:convert';
import 'dart:io';
import 'dart:ui';


import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class UploadVideo extends StatefulWidget {
  File photo;
  String folder;
  UploadVideo(this.photo,this.folder);
  @override
  _UploadVideoState createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {

  Widget cent;
  String photo;
  @override
  void initState() {
    cent=Text("Starting...");
    uploadFile();
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){},
      child: Container(
        height: MediaQuery.of(context).size.width/4,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 5,sigmaX: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            title: cent,
            content: Container(
              height: MediaQuery.of(context).size.width/5,
              alignment: Alignment.center,
              child: CircularProgressIndicator()
            ),
          ),
        ),
      ),
    );
  }


  Future uploadFile() async {
    if(await IsConnectedtoInternet()){
      Navigator.pop(context);
      ShowInternetDialog(context);
      return;
    }

    String date=DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference photorefrence = FirebaseStorage.instance
        .ref()
        .child('${widget.folder}/$date.jpeg');
    StorageUploadTask photouploadtask = photorefrence.putFile(widget.photo);
    cent=_uploadStatus(photouploadtask);
    await photouploadtask.onComplete;
    photorefrence.getDownloadURL().then((fileURL) async{
      photo=fileURL;
        if(photo==null){
          Toast.show("Some error occured", context);
          Navigator.pop(context);
        }else{
          Navigator.pop(context,photo);
        }
    });

  }



  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    double res = snapshot.bytesTransferred / 1024.0;
    double res2 = snapshot.totalByteCount / 1024.0;
    double percentage=(res*100)/res2;
    return percentage.toStringAsFixed(2);
  }

  Widget _uploadStatus(StorageUploadTask task,) {
    return StreamBuilder(
      stream: task.events,
      builder: (BuildContext context, snapshot) {
        Widget subtitle;
        if (snapshot.hasData) {
          final StorageTaskEvent event = snapshot.data;
          final StorageTaskSnapshot snap = event.snapshot;
          subtitle = Text('${_bytesTransferred(snap)}%');
        } else {
          subtitle = const Text('Starting...');
        }
        return ListTile(
          title: task.isComplete && task.isSuccessful
              ? Text(
            'Finishing...',
            style: GoogleFonts.lato(),
          )
              : Text(
            'Uploading..',
            style: GoogleFonts.lato(),
          ),
          subtitle: subtitle,
        );
      },
    );
  }


}
