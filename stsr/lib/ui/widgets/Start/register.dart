import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../loaderdialog.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  Color black=Colors.black;
  String myvarificationid;
  static var firebaseAuth = FirebaseAuth.instance;
  String phone;
  TextEditingController _controller = new TextEditingController();
  TextEditingController _refcontroller = new TextEditingController();
  TextEditingController _controllerotp = new TextEditingController();
  double pinpilltop;
  double pinpilltopotp;
  double pinpillloading;
  String status;
  @override
  void initState() {
    status="";
    pinpilltop=1;
    pinpilltopotp=-500;
    pinpillloading=-500;
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: Scaffold(
          body:Container(
            decoration: BoxDecoration(
                color: LightColor.background
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 6,sigmaX: 6),
              child: Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[

                           Container(
                            margin: EdgeInsets.only(top: 50),
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height/2,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  height: MediaQuery.of(context).size.width/2,
                                  child: ClipOval(
                                      child: Image.asset("assets/images/DOD_Logo.png",fit: BoxFit.cover,),
                                  ),
                                ),
                                Text("S.T.S.R.",style: GoogleFonts.alef(color: LightColor.orange,fontSize:40),),
                              ],
                            ),
                          ),

                        ],
                      ),

                    ),


                    //getting login
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: pinpilltop,
                      child: GestureDetector(
                        child: Container(
                          height: MediaQuery.of(context).size.height/2,
                          width: MediaQuery.of(context).size.width,
                          child:   ListView(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: Text("Login",textAlign: TextAlign.center,
                                style: GoogleFonts.muli(
                                  color: LightColor.lightblack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30
                                ),
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height/2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      margin: EdgeInsets.all(20),
                                      elevation: 10,
                                      color: Colors.white,
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        child: TextField(
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          style: GoogleFonts.muli(color: LightColor.grey),
                                          decoration: InputDecoration(
                                            counterText: "",
                                              hintText: "Phone",
                                              hintStyle: GoogleFonts.muli(
                                                  color: black
                                              ),
                                              border: InputBorder.none,
                                          ),
                                          controller: _controller,
                                        ),
                                      ),
                                    ), Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      margin: EdgeInsets.fromLTRB(40,0,40,10),
                                      elevation: 10,
                                      color: Colors.white,
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        child: TextField(
                                          keyboardType: TextInputType.text,
                                          style: GoogleFonts.muli(color: LightColor.grey),
                                          decoration: InputDecoration(
                                            counterText: "",
                                              hintText: "Referal code",
                                              hintStyle: GoogleFonts.muli(
                                                  color: black
                                              ),
                                              border: InputBorder.none,
                                          ),
                                          controller: _refcontroller,
                                        ),
                                      ),
                                    ),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      color: LightColor.orange,
                                      child: Text("Send OTP", style: GoogleFonts.muli(color: LightColor.background),),
                                      onPressed: () async{
                                        if (_controller.text == "") return;
                                        if(_refcontroller.text.isNotEmpty){
                                          LoaderDialog(context, false,text: "Verifying referal ID...");
                                          await FirebaseAuth.instance.signInAnonymously();
                                          QuerySnapshot abcd= await Firestore.instance.collection('user').where('referalid',isEqualTo: _refcontroller.text).getDocuments();
                                        if(abcd.documents.isEmpty){
                                          MyToast("Invalid referal id", context);
                                         await FirebaseAuth.instance.signOut();
                                          Navigator.pop(context);
                                          return;
                                        }else{
                                          if(abcd.documents.first['phone']==_controller.text){
                                            MyToast("Invalid referal id", context);
                                            await FirebaseAuth.instance.signOut();
                                            Navigator.pop(context);
                                            return;
                                          }else{
                                            await FirebaseAuth.instance.signOut();
                                            Navigator.pop(context);
                                            startPhoneAuth(_controller.text);
                                          }
                                        }
                                        }else{
                                          startPhoneAuth(_controller.text);
                                        }
                                      },

                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: (){
             },
                      ),
                    ),


                    //getting otp
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: pinpilltopotp,

                      child: GestureDetector(
                        child: Container(
                          height: MediaQuery.of(context).size.height/2,
                          width: MediaQuery.of(context).size.width,
                          child:   ListView(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                alignment: Alignment.center,
                                child: Material(
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Change number",style: GoogleFonts.muli(color: LightColor.grey),),
                                    ),
                                    onTap: (){
                                      setState(() {
                                        pinpilltopotp=-500;
                                        pinpilltop=1;
                                        pinpillloading=-500;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height/2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      margin: EdgeInsets.all(20),
                                      elevation: 10,
                                      color: Colors.white,
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        child: TextField(
                                          keyboardType: TextInputType.phone,
                                          maxLength: 6,
                                          style: GoogleFonts.muli(color: LightColor.grey),
                                          decoration: InputDecoration(
                                            counterText: "",
                                              hintText: "OTP",
                                              hintStyle: TextStyle(
                                                  color: black
                                              ),
                                              border: InputBorder.none
                                          ),
                                          controller: _controllerotp,
                                        ),
                                      ),
                                    ),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      color: LightColor.orange,
                                      child: Text("submit", style:GoogleFonts.muli(color: LightColor.background),),
                                      onPressed: () {
                                        if(_controllerotp.text.length<6){
                                          Toast.show("Please enter 6 digit code", context);
                                          return;
                                        }
                                        if(_controllerotp.text.isEmpty) return;
                                        _signInWithPhoneNumber(_controllerotp.text);
                                      },

                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: (){

                        },
                      ),
                    ),


                //loading
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: pinpillloading,

                      child: GestureDetector(
                        child: Container(
                          height: MediaQuery.of(context).size.height/2,
                          width: MediaQuery.of(context).size.width,
                          child:   Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(status,style: TextStyle(fontSize:25,color: LightColor.lightblack)),
                              SpinKitWave(color: LightColor.lightblack)
                            ],
                          )
                        ),
                        onTap: (){

                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      )
    );
  }

  startPhoneAuth(phone) async{
    this.phone=phone;
    FocusScope.of(context).requestFocus(FocusNode());
    if(await IsConnectedtoInternet()){
    ShowInternetDialog(context);
    return;
    }
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91" + phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    setState(() {
      pinpilltop=-500;
      pinpillloading=1;
      status="Sending OTP";
    });
  }


  codeSent(String verificationId, [int forceResendingToken]) async {
    myvarificationid=verificationId;
    phone=_controller.text;
    Toast.show("code sent",context);
    setState(() {
      pinpillloading=-500;
      pinpilltopotp=1;
      pinpillloading=-500;
    });
  }

  codeAutoRetrievalTimeout(String verificationId) {
    Toast.show("code auto retrival timeout",context);
  }
  verificationFailed (AuthException authException) {
    setState(() {
      pinpilltopotp=-500;
      pinpilltop=1;
      pinpillloading=-500;
    });
    if (authException.message.contains('not authorized')){
      setState(() {
        pinpilltopotp=-500;
        pinpilltop=1;
        pinpillloading=-500;
      });
      Toast.show('Something has gone wrong, please try later',context);}
    else if (authException.message.contains('Network')){
      setState(() {
        pinpilltopotp=-500;
        pinpilltop=1;
        pinpillloading=-500;
      });
      Toast.show('Please check your internet connection and try again',context);}
    else{
      setState(() {
        pinpilltopotp=-500;
        pinpilltop=1;
        pinpillloading=-500;
      });
      Toast.show('Something has gone wrong, please try later',context);}
  }

 _OnAuthSuccess() async{
LoaderDialog(context, false);
    _checkuserindatabase();
    }


  void verificationCompleted(AuthCredential phoneAuthCredential) async{

    firebaseAuth.signInWithCredential(phoneAuthCredential)
        .then((AuthResult value) {
      if (value.user != null) {
        Toast.show('Authentication successful',context);
        _OnAuthSuccess();
      } else {
        setState(() {
          pinpilltopotp=-500;
          pinpilltop=1;
          pinpillloading=-500;
        });
        Toast.show('Invalid code/invalid authentication',context);
      }
    }).catchError((error) {
      setState(() {
        pinpilltopotp=-500;
        pinpilltop=1;
        pinpillloading=-500;
      });
      Toast.show('Something has gone wrong, please try later',context);
    });
  }



  void _signInWithPhoneNumber(String smsCode) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    setState(() {
      pinpilltopotp=-500;
      pinpilltop=-500;
      pinpillloading=1;
      status="Verifying OTP";
    });
    if(myvarificationid==""){ Toast.show("wrong pin", context); return;}
    var _authCredential = await PhoneAuthProvider.getCredential(
        verificationId: myvarificationid, smsCode: smsCode);
    firebaseAuth.signInWithCredential(_authCredential).catchError((error) {
      setState(() {
        setState(() {
          pinpilltopotp=-500;
          pinpilltop=1;
          pinpillloading=-500;
        });
        Toast.show("Something has gone wrong, please again",context);

      });

    }).then((user) async {
      if(user==null){
        setState(() {
          status="Wrong Otp";
          Toast.show("wrong OTP", context);
          pinpilltopotp=-500;
          pinpilltop=1;
          pinpillloading=-500;
        });
        return;
      }
      if(user.user!=null){
        setState(() {
          pinpilltopotp=-500;
          pinpilltop=-500;
          pinpillloading=1;
          status="Loging in";
        });
        _OnAuthSuccess();
      }
      else{
        setState(() {
          status="Wrong Otp";
          Toast.show("wrong OTP", context);
          pinpilltopotp=-500;
          pinpilltop=1;
          pinpillloading=-500;
        });
      }

    });
  }



  _checkuserindatabase()async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    final QuerySnapshot result=await

    Firestore.instance.collection("user").where("phone",isEqualTo: this.phone).getDocuments();

    final List<DocumentSnapshot> documents= result.documents;

    if(documents.length==0)
    {
      Firestore.instance.collection("user").add({
        'address':"",
        'cart':[],
        'city':"",
        'coins':0,
        'coinshistory':[],
        'phone':phone,
        "datetime":DateTime.now().millisecondsSinceEpoch.toString(),
        'email':"",
        'house':"",
        'name':"",
        'notify':[],
        'orders':[],
        'pincode':"",
        'referalid':DateTime.now().millisecondsSinceEpoch.toString().substring(1,4)+phone.substring(1,5),
        'sublocality':"",
        'wishlist':[],
        'lat':"",
        'long':"",
        'referredby':_refcontroller.text
      }).then((value)async{
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.setString('stsruserlogin', value.documentID.toString());
        value.get().then((value){
        _startActivity(value);
        });

      });
    }
    else{

      if(_refcontroller.text.isNotEmpty){      MyToast("Referal Id already exists!", context);}
      Firestore.instance.collection('user').document(documents[0].documentID).updateData({
        "datetime":DateTime.now().millisecondsSinceEpoch.toString()
      }).then((value)async{
        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.setString('stsruserlogin', documents[0].documentID.toString());
        _startActivity(documents[0]);
      });
    }

  }

  Future<void> _startActivity(DocumentSnapshot value) async {
    await _getTokens(value.documentID);
        Navigator.pop(context);
        Navigator.push(context, PageTransition(
            child: Home(value),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 10)
        ));

  }

  final FirebaseMessaging _firebaseMessaging=new FirebaseMessaging();

  _getTokens(id) async{
    _firebaseMessaging.getToken().then((value){
      Firestore.instance.collection('user').document(id).updateData({
        'token':value
      });
    });
  }



}



