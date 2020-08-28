import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logindecider.dart';


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "stsr",
        description: "No need to go outside to buy groceries. We will get it for you at prices lower than the market. With absolutely free delivery.",
        pathImage: "assets/images/DOD_Logo.png",
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      new Slide(
        title: "Order by 11 pm.\n Get it tommorow morning.",
        description: "Planning groceries for tommorow ? Order as late as 9pm and we will deliver it in the morning.",
        pathImage: "assets/images/jam.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "Buy fresh daily,\nEat fresh daily,",
        description:"Order what you need not more not less. We will deliver it daily!",
        pathImage: "assets/images/box.png",
        backgroundColor: Color(0xff9932CC),
      ),
    );
  }

  void onDonePress() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('intro', 1);
    Navigator.pushReplacement(context, PageTransition(
      child: LoginDecider(),
      type: PageTransitionType.leftToRightWithFade
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: new IntroSlider(
        slides: this.slides,
        onDonePress: this.onDonePress,
      ),
    );
  }
}