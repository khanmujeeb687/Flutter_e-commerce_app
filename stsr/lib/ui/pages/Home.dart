import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/notdeliverable.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/pages/Wishlist.dart';
import 'package:stsr/ui/pages/search_page.dart';
import 'package:stsr/ui/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:stsr/ui/widgets/category/SubCategoryOnly.dart';
import 'package:stsr/ui/widgets/home/homepage.dart';
import 'package:stsr/ui/widgets/home/myappdrawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../loaderdialog.dart';
import '../widgets/home/cart.dart';

class Home extends StatefulWidget {
 static DocumentSnapshot user;
 static List<DocumentSnapshot> banners;
 static List<DocumentSnapshot> myordersdata;
 static List<DocumentSnapshot> allcats;
 static List<DocumentSnapshot> manpowerdata;

 Home(userdata){
   user=userdata;
 }
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _scoffoldkey = new GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> allcats;
  StreamSubscription<QuerySnapshot> _subscription;
  int pageindex=0;
  @override
  void initState() {
    _getAllCat();
    _configurfirebaseListeners();
    // TODO: implement initState
    super.initState();
  }


  _configurfirebaseListeners(){
    FirebaseMessaging().configure(
      onLaunch: (data) async{

      },
      onMessage: (data) async{

      },
      onResume: (data) async{

      },

    );
  }


  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("Press again to exit",context);
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: _appBar(),
        key: _scoffoldkey,
        drawer: mydrawer(allcats),
        backgroundColor:( pageindex==2 || pageindex==1)?LightColor.black:Color(0xfffbfbfb),
        body: Container(
          decoration: BoxDecoration(
          ),
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInToLinear,
                      switchOutCurve: Curves.easeOutBack,
                      child:(){
                         if(pageindex==0){
                           return MyHomePage(allcats);
                         }
                         else if(pageindex==1){
                           return SearchPage();
                         }
                         else if(pageindex==2){
                           return Cart();

                         }
                         else if(pageindex==3){
                           return WishList();
                         }
                         else{
                           return MyHomePage(allcats);
                         }
                      }()
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CustomBottomNavigationBar(
                  onIconPresedCallback: onBottomIconPressed,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }




  Widget _appBar() {
    return AppBar(
      elevation: 0,
      title: Text("STSR",style: GoogleFonts.alef(color: LightColor.orange),),
      leading: IconButton(
        icon:   RotatedBox(
            quarterTurns: 4,
            child: Icon(Icons.sort, color: (pageindex==2 || pageindex==1)?LightColor.lightGrey:Colors.black,size: 30,),),
        onPressed: (){
          _scoffoldkey.currentState.openDrawer();
        },
      ),
        backgroundColor: (pageindex==2 || pageindex==1)?LightColor.black:Color(0xfffbfbfb),
    );
  }

  void onBottomIconPressed(int index) {
    setState(() {
      pageindex=index;
    });
  }


  _getAllCat() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    await  Firestore.instance.collection('categories').orderBy('soldcount',descending: true).getDocuments().then((value){
      if(!mounted) return;

      setState(() {
        allcats=value.documents;
      });
      Home.allcats=allcats;
      _refresh();

    });
    _checkfirst();
  }
  _refresh() async{
    _subscription= Firestore.instance.collection('categories').orderBy('soldcount',descending: true).snapshots().listen((event) {
      if(!mounted) return;

      setState(() {
        allcats=event.documents;
      });
      Home.allcats=allcats;

    });
  }

  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }    // TODO: implement dispose
    super.dispose();
  }



  _checkfirst() async{
    SharedPreferences _prefs=await SharedPreferences.getInstance();
    if(_prefs.containsKey('ifirst')){
      if(_prefs.getInt('ifirst')==0){
        await _getcurrentlocation();
        _prefs.setInt('ifirst', 1);
      }
    }else{
      await _getcurrentlocation();
      _prefs.setInt('ifirst', 1);
    }
  }

  _getcurrentlocation() async {

    Position _position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (_position == null) {
      _position = await Geolocator().getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.best);
    }
    if(_position==null) return;
    _getgeocodedaddress(_position);
  }




  _getgeocodedaddress(Position position)async{
    final coordinates = new Coordinates(
        position.latitude, position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
      await Firestore.instance.collection('deliverableaddresses').where('pincode',isEqualTo: first.postalCode).getDocuments().then((value)async{
        if(value.documents.isNotEmpty){
          if(await _IfDeliver(position,value.documents)){
            _candeliver(first.addressLine,first.subLocality,first.locality,first.postalCode,position);
            return;
          }
        }
          showDialog(context: context,builder: (context){
            return CantDeliverHere(first.postalCode);
          });

      });


  }
  _candeliver(address,sublocality,city,pincode,Position position) async{
    if(sublocality==null){
      sublocality="";
    }
    showDialog(context: context,builder: (Context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        backgroundColor: LightColor.black,
        title: ListTile(
            title: Text("Yes we deliver at your location",style: GoogleFonts.lato(color: LightColor.grey),)),
        content: Container(
          width: AppTheme.fullWidth(context)/1.5,
          height: AppTheme.fullWidth(context)/2,
          child: Text(address,style: GoogleFonts.lato(color: LightColor.background),),
        ),
        actions: <Widget>[
          RaisedButton(
            color: LightColor.lightGrey,
            child: Text("Continue without saving",style: GoogleFonts.muli(color: LightColor.black),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          RaisedButton(
            color: LightColor.orange,
            child: Text("Save address",style: GoogleFonts.muli(color: LightColor.background),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
            onPressed: ()async{
              LoaderDialog(context, false);
              await Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                'address':address,
                'sublocality':sublocality,
                'pincode':pincode,
                'city':city,
                'lat':position.latitude.toString(),
                'long':position.longitude.toString(),
              }).then((value){
                Firestore.instance.collection('user').document(Home.user.documentID).get().then((value){
                  Home.user=value;
                });
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }


  Future<bool> _IfDeliver(Position position,List<DocumentSnapshot> ourlocation) async{
    if(position==null) return false;
    for(int i=0;i<ourlocation.length;i++){
      double distanceInMeters = await new Geolocator().distanceBetween(position.latitude,position.longitude,
          double.parse(ourlocation[i]['lat'].toString()), double.parse(ourlocation[i]['long'].toString()));
      if(distanceInMeters!=null){
        if(distanceInMeters<=1000){
          return true;
        }
      }
    }
    return false;
  }

}
