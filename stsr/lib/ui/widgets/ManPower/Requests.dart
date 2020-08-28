import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class Requests extends StatefulWidget {
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<DocumentSnapshot> _servicedata;
  ScrollController _controller=new ScrollController();
  bool hasmore=true;
  @override
  void initState() {
    _getearnings();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: LightColor.grey,
        title: Text("Service",style: GoogleFonts.muli(),),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.topCenter,
        child: (){
          if(_servicedata==null) return _shimmer();
          else if(_servicedata.isEmpty) return Center(child: Text("No data yet!",style: GoogleFonts.muli(color: LightColor.darkgrey),),);
          return ListView.builder(
              controller: _controller,
              itemCount: _servicedata.length+1,
              itemBuilder: (context,index){
                if(index==_servicedata.length){
                  if(!hasmore || _servicedata.length<10){
                    return Center(
                        child: Icon(Icons.timelapse,color: LightColor.grey,size: 40,)
                    );
                  }
                  return Center(
                      child: SpinKitCircle(color: LightColor.orange,)
                  );
                }
                return _item(index);
              });
        }(),
      ),
    );
  }


  _item(index){
    String _formatted = formatTime(int.parse(_servicedata[index]['datetime'].toString()));
    return  Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(15)
      ),
      padding: EdgeInsets.all(15),
      child: Row(
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: _servicedata[index]['image'],
                placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              )
          ),
          Expanded(
              child: ListTile(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TitleText(
                      text: _servicedata[index]['categoryname'].toString(),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    Text("${_servicedata[index]['man']} ${_servicedata[index]['categoryname']} & ${_servicedata[index]['helper']} helpers",style: GoogleFonts.muli(color: LightColor.grey),),
                  ],
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_formatted,style: GoogleFonts.muli(color: LightColor.grey),),
                    Text(_servicedata[index]['address'],style: GoogleFonts.muli(color: LightColor.orange),),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.more_vert,color: LightColor.orange,),
                  onPressed: (){
                    _seedetails(index);
                  },
                ),
              )
          )
        ],
      ),
    );
  }

  void _seedetails(index) async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    LoaderDialog(context, false);
    String phone="";
    await Firestore.instance.collection('appdata').document('e3hddFWLhgKh3EV3E4ZP').get().then((value){
      phone=value['phone'];
    });
    Navigator.pop(context);
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        builder: (context){
          return Container(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    title: Text("Comment",style: GoogleFonts.muli(color: LightColor.black),),
                    subtitle: Text(_servicedata[index]['comment'].isEmpty?"No comment!":_servicedata[index]['comment'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
                  ), ListTile(
                    title: Text("Phone no.",style: GoogleFonts.muli(color: LightColor.black),),
                    subtitle: Text(_servicedata[index]['phone'],style: GoogleFonts.muli(color: LightColor.darkgrey),),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: <Widget>[

                      Card(
                        child: Container(
                          child: IconButton(
                            icon: Icon(Icons.call,color: LightColor.background,),
                            onPressed: ()async{
                              String url = "tel:${phone}";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue.shade300,
                          ),
                          width: 50,
                          height: 50,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      Card(
                        child: Container(
                          child: IconButton(
                            icon: Icon(Icons.sms,color: LightColor.background,),
                            onPressed: ()async{
                              String url = "sms:+91 ${phone}";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: LightColor.grey,
                          ),
                          width: 50,
                          height: 50,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      Card(
                        child: Container(
                          child: IconButton(
                            icon: Icon(FontAwesomeIcons.whatsapp,color: LightColor.background,),
                            onPressed: () async{
                              String url = "whatsapp://send?phone=+91 ${phone}";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green[300],
                          ),
                          width: 50,
                          height: 50,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  _shimmer(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index){
        return Container(
          width: AppTheme.fullWidth(context)-60,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 50,
                    width: AppTheme.fullWidth(context)-60,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 35,
                    width: AppTheme.fullWidth(context)-60,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: LightColor.grey,
                highlightColor: LightColor.lightGrey,
                child: Card(
                  child: Container(
                    height: 35,
                    width: AppTheme.fullWidth(context)/2,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _getearnings() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    Firestore.instance.collection('servicerequest')
        .where('userid',isEqualTo: Home.user.documentID)
        .orderBy('datetime',descending: true)
        .limit(10)
        .getDocuments().then((value){
      setState(() {
        _servicedata=value.documents;
      });
      if(_servicedata.isNotEmpty){
        _controller.addListener(() {
          if(_controller.position.pixels == _controller.position.maxScrollExtent){
            _loadmore();
          }
        });
      }
    });

  }

  void _loadmore() async{
    if(!hasmore) return;
    hasmore=false;
    await Firestore.instance.collection('servicerequest')
        .where('userid',isEqualTo: Home.user.documentID)
        .orderBy('datetime',descending: true)
        .startAfterDocument(_servicedata.last)
        .limit(10)
        .getDocuments().then((value){
      if(value.documents.isNotEmpty){
        setState(() {
          _servicedata.addAll(value.documents);
          hasmore=true;
        });
      }});
    setState(() {
      hasmore=hasmore;
    });
  }
}
