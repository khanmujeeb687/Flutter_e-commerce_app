import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/widgets/order/SingleOrderManage.dart';
import 'package:time_formatter/time_formatter.dart';
class singleearning extends StatefulWidget {
  DocumentSnapshot refuser;
  singleearning(this.refuser);
  @override
  _singleearningState createState() => _singleearningState();
}

class _singleearningState extends State<singleearning> {
  List<DocumentSnapshot> _earnings;
  DocumentSnapshot _user;
  ScrollController _controller=new ScrollController();
  bool hasmore=true;
  @override
  void initState() {
    _user=Home.user;
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
        title: Text(widget.refuser['phone'],style: GoogleFonts.muli(),),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.topCenter,
        child: (){
          if(_earnings==null) return _shimmer();
          else if(_earnings.isEmpty) return Center(child: Text("No transactions yet!",style: GoogleFonts.muli(color: LightColor.darkgrey),),);
          return ListView.builder(
              controller: _controller,
              itemCount: _earnings.length+1,
              itemBuilder: (context,index){
                if(index==_earnings.length){
                  if(!hasmore || _earnings.length<10){
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
    String _formatted = formatTime(int.parse(_earnings[index]['datetime'].toString()));
    return  Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(15)
      ),
      padding: EdgeInsets.all(15),
      child: Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
          Expanded(
              child: ListTile(
                title: TitleText(
                  text: _earnings[index]['coins'].toString()+" coins "+_earnings[index]['status'],
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_formatted,style: GoogleFonts.muli(color: LightColor.grey),),
                    Text(_earnings[index]['shopping']?"Shopping reward":"Referal reward",style: GoogleFonts.muli(color: LightColor.orange),),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward,color: LightColor.orange,),
                  onPressed: ()async{
                    if(await IsConnectedtoInternet()){
                      ShowInternetDialog(context);
                      return;
                    }
                    if(_earnings[index]['shopping']){
                      if(_earnings[index]['orderid'].isNotEmpty){
                        LoaderDialog(context, false);
                        Firestore.instance.collection('orders').document(_earnings[index]['orderid']).get().then((value){
                          Navigator.pop(context);
                          if(value.exists){
                            Navigator.push(context, PageTransition(
                                child: SingleOrderManage(value),
                                type:PageTransitionType.leftToRightWithFade
                            ));
                          }
                        });
                      }
                    }else if(_earnings[index]['referal']){
                      LoaderDialog(context, false);
                      Firestore.instance.collection('user').document(_earnings[index]['referalid']).get().then((value){
                        Navigator.pop(context);
                        if(value.exists){
                          showModalBottomSheet(context: context, builder: (context){
                            return Container(
                              height: 80,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(FontAwesomeIcons.user,color: LightColor.orange,),
                                      title: Text(value['name'].isEmpty?"User":value['name']),
                                      subtitle: Text(value['phone']),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        }
                      });
                    }
                  },
                ),
              )
          )
        ],
      ),
    );
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
    Firestore.instance.collection('coinstransactions')
        .where('userid',isEqualTo: Home.user.documentID)
        .where('referalid',isEqualTo: widget.refuser.documentID)
        .orderBy('datetime',descending: true)
        .limit(10)
        .getDocuments().then((value){
      setState(() {
        _earnings=value.documents;
      });
      if(_earnings.isNotEmpty){
        _controller.addListener(() {
          if(_controller.position.pixels == _controller.position.maxScrollExtent){
            _loadmore();
          }
        });
      }
    });
    _user=await Firestore.instance.collection('user').document(Home.user.documentID).get();
    Home.user=_user;
  }

  void _loadmore() {
    if(!hasmore) return;
    hasmore=false;
    Firestore.instance.collection('coinstransactions')
        .where('userid',isEqualTo: Home.user.documentID)
        .where('referalid',isEqualTo: widget.refuser.documentID)
        .orderBy('datetime',descending: true)
        .startAfterDocument(_earnings.last)
        .limit(10)
        .getDocuments().then((value){
      if(value.documents.isNotEmpty){
        setState(() {
          _earnings.addAll(value.documents);
          hasmore=true;
        });
      }});
  }
}
