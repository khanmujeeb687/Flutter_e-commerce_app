
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/widgets/Start/register.dart';
import 'package:stsr/ui/widgets/Start/IntroScreen.dart';
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
  DateTime currentBackPressTime;

  @override
  void initState() {
    currentBackPressTime=DateTime.now();
    super.initState();
    _checklogin();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _animation = Tween(begin: 0.0, end: 1.5).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInCirc));
    _animationController.forward();
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
    if(!prefs.containsKey('intro')){
      Navigator.pushReplacement(context, PageTransition(
        child: IntroScreen(),
        type: PageTransitionType.leftToRight
      ));
      return;
    }
    if(prefs.containsKey('stsruserlogin'))
    {
      if(prefs.getString('stsruserlogin')!="0")
      {
        _getuser(prefs.getString('stsruserlogin'));
      }
      else if(prefs.getString('stsruserlogin')=="0")
        {
          Navigator.pushReplacement(context, PageTransition(
              child: Register(),
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 50)
          ));
        }
    }
    else{
      prefs.setString('stsruserlogin', "0");
      Navigator.pushReplacement(context, PageTransition(
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
    Firestore.instance.collection("user").document(id).get().then((value)async{
      if(!value.exists) {
        Navigator.pushReplacement(context, PageTransition(
            child: Register(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50)
        ));
      }
      else{
        DateTime now=DateTime.now();
        if(now.difference(currentBackPressTime)<Duration(milliseconds: 1200)){
         await  Future.delayed(Duration(milliseconds: 1200-now.difference(currentBackPressTime).inMilliseconds));
        }
        Navigator.pushReplacement(context, PageTransition(
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

@override
  void dispose() {
  _animationController.reset();
  // TODO: implement dispose
    super.dispose();
  }

}



