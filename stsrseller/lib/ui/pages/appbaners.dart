import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'package:stsrseller/ui/loaderdialog.dart';
import 'package:stsrseller/ui/widgets/uploadimage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class AppBanners extends StatefulWidget {
  @override
  _AppBannersState createState() => _AppBannersState();
}

class _AppBannersState extends State<AppBanners> {

  List<DocumentSnapshot> banners;
  List<File> picturestoupload=[];
  StreamSubscription<QuerySnapshot> _subscription;
  List<String> _subcategories=[];


  @override
  void initState() {
    _start();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        backgroundColor: LightColor.black,
        title: Text("App banners"),
      ),
      body: Container(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
                    Text("Banners",style: GoogleFonts.muli(color: LightColor.orange,fontSize: 25,fontWeight: FontWeight.w400),),
                  (){
                if(banners==null){
                  return SpinKitCircle(color: LightColor.orange);
                }
                return _productimages();
              }(),
              SizedBox(height: 20,),
              Text("Upload new banners",style: GoogleFonts.muli(color: LightColor.lightblack,fontSize: 20,fontWeight: FontWeight.w300),),
              _productimagestoupload()
            ],
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LightColor.black,
        child: Icon(Icons.file_upload,color: LightColor.grey,),
        onPressed: (){
          if(picturestoupload.isEmpty) return;
          _upload();
        },
      ),
    );
  }

  _productimages(){
    if(banners.isEmpty){
      return Center(child: Text("No banners yet!",style: GoogleFonts.lato(color: LightColor.grey),));
    }
    return Container(
      alignment: Alignment.center,
      width: AppTheme.fullWidth(context),
      height: 160,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: banners.length,
          itemBuilder:(context,index){
            return SizedBox(
              width: 300,
              height: 150,
              child: Card(
                elevation: 10,
                color: LightColor.darkgrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: banners[index]['imgurl'],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.cancel),
                            iconSize: 30,
                            color: LightColor.black,
                            onPressed: (){
                              setState(() {
                                _deletevideo(banners[index]['imgurl'], banners[index].documentID);
                              });
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(banners[index]['subcategory'],style: GoogleFonts.muli(color: LightColor.darkgrey),)
                        ),

                      ],
                      fit: StackFit.expand,
                    )),
              ),
            );
          }
      ),
    );
  }

  _productimagestoupload(){
    return Container(
      alignment: Alignment.center,
      width: AppTheme.fullWidth(context),
      height: 160,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: picturestoupload.length+1,
          itemBuilder:(context,index){
            if(index==picturestoupload.length){
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){
                    _pickimage();
                  },
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Card(
                      elevation: 10,
                      color: LightColor.darkgrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Add App banners",style: GoogleFonts.lato(color: LightColor.lightblack,fontSize: 10),),
                          Icon(Icons.add,color: LightColor.orange,size: 30,),
                        ],
                      ),),
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              width: 300,
              height: 150,
              child: Card(
                elevation: 10,
                color: LightColor.darkgrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Image.file(picturestoupload[index],fit: BoxFit.cover,),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.cancel),
                            iconSize: 30,
                            color: LightColor.black,
                            onPressed: (){
                              setState(() {
                                picturestoupload.removeAt(index);
                                _subcategories.removeAt(index);
                              });
                            },
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(_subcategories[index],style: GoogleFonts.muli(color: LightColor.darkgrey),)
                        ),
                      ],
                      fit: StackFit.expand,
                    )),
              ),
            );
          }
      ),
    );
  }

  void _start() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }

    Firestore.instance.collection('appbanners').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        if(!mounted) return;
        setState(() {
          banners=value.documents;
        });
      }else{
        if(!mounted) return;
        setState(() {
          banners=[];
        });
      }
    });
    _refresh();
  }



  _pickimage()async{
    File _file=await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if(_file!=null){
      String text=await DialogInput(context,"subcategroy name (case sensitive)",TextInputType.text);
      if(text.isEmpty) return;
      if(!mounted) return;
      setState(() {
        picturestoupload.add(_file);
        _subcategories.add(text);
      });
    }
  }

  _upload() async{
    if(_subcategories.length!=picturestoupload.length){
      Toast.show("Please upload category name!!", context,duration: Toast.LENGTH_LONG);
      return;
    }
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
   LoaderDialog(context, false);
   String url;
   for(int i=0;i<picturestoupload.length;i++){
   url= await showDialog(context: context,barrierDismissible: false,
       builder: (context){return UploadVideo(picturestoupload[i],"appbanners");});
   if(url!=null){
    await Firestore.instance.collection('appbanners').add({
       'imgurl':url,
      'datetime':DateTime.now().millisecondsSinceEpoch.toString(),
      'subcategory':_subcategories[i]
     });
     url=null;
   }
   }
    if(!mounted) return;
    setState(() {
     picturestoupload=[];
     _subcategories=[];
   });
   Navigator.pop(context);
  }

  _deletevideo(imgurl,docid) async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    LoaderDialog(context, false,text: "Deleting..");
    StorageReference photoRef = await FirebaseStorage.instance.getReferenceFromUrl(imgurl);
      photoRef.delete().then((value){
        Firestore.instance.collection('appbanners').document(docid).delete().then((value){
          Toast.show("Banner deleted successfully", context,duration: Toast.LENGTH_LONG);
          Navigator.pop(context);
        });
      });
  }

  _refresh() async{
    _subscription =await Firestore.instance.collection('appbanners').snapshots().listen((event) {
      if(event.documents.isNotEmpty){
        if(!mounted) return;
        setState(() {
          banners=event.documents;
        });
      }else{
        if(!mounted) return;
setState(() {
  banners=[];
});
      }
    });
  }

  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }
    // TODO: implement dispose
    super.dispose();
  }
}
