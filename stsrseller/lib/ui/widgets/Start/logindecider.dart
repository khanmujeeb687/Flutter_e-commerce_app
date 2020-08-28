import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:stsrseller/ui/widgets/Start/register.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';




class LoginDecider extends StatefulWidget {
  @override
  _LoginDeciderState createState() => _LoginDeciderState();
}

class _LoginDeciderState extends State<LoginDecider> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  bool _inter=false;


  @override
  void initState() {
    _checklogin();
    // TODO: implement initState
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _animation = Tween(begin: 0.0, end: 1.5).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInCirc));
    _animationController.forward();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:LightColor.black,
      body:  Center(
          child: _inter?_nointernet():
          ScaleTransition(
              scale: _animation,
              child: Center(
                  child:
                  SizedBox(height: 250.0, child:
                  Image.asset("assets/images/DOD_Logo.png",height: 200,width: 200,),)))
      )
    );
  }

  _checklogin()
  async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('sellerlogin'))
    {
      if(prefs.getString('sellerlogin')!="0")
      {
        _getuser(prefs.getString('sellerlogin'));
      }
      else if(prefs.getString('sellerlogin')=="0")
        {
          Navigator.push(context, PageTransition(
              child: Register(),
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 50)
          ));
        }
    }
    else{
      prefs.setString('sellerlogin', "0");
      Navigator.push(context, PageTransition(
          child: Register(),
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 50)
      ));
    }
  }


  _getuser(id)async{
    if(await IsConnectedtoInternet()){
      setState(() {
        _inter=true;
      });
      return;
    }
    Firestore.instance.collection("seller").document(id).get().then((value){
      if(!value.exists) {
        Navigator.push(context, PageTransition(
            child: Register(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50)
        ));
      }
      else{
        Navigator.push(context, PageTransition(
            child: Home(value),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50)
        ));
      }
    });


  }



  Widget _nointernet(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error,color: Colors.red,size: 70,),
          SizedBox(height: 7,),
          Text("No Internet"),
          SizedBox(height: 7,),
          OutlineButton(
            borderSide: BorderSide(color: Colors.blue.shade700),
            child: Text("Retry"),
            onPressed: (){
              setState(() {
                _inter=false;
              });
              _checklogin();
            },
          )
        ],
      ),
    );
  }
}



