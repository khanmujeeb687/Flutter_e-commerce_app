import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';

class CarouselWithIndicatorDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  int _current = 0;
  List<DocumentSnapshot> banners=[];
  StreamSubscription<QuerySnapshot> _subscription;

  @override
  void initState() {
    _loadbanners();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CarouselSlider(
              items: banners.map((banner){
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, PageTransition(
                        child: Category(banner['subcategory'],banner['subcategory'],name: true,),
                        type: PageTransitionType.fade,
                      ));
                    },
                    child: CachedNetworkImage(
                      imageUrl: banner['imgurl'],
                      placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: AppTheme.fullWidth(context)-50,
                      height: 150,
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.4,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.map((banner) {
                int index = banners.indexOf(banner);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
          ]
    );
  }



  _loadbanners() async{
    if(Home.banners!=null){
      if(!mounted) return;
      setState(() {
        banners=Home.banners;
      });
      _refresh();
      return;
    }
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    Firestore.instance.collection('appbanners').getDocuments().then((value){
      if(!mounted) return;
      setState(() {
        banners=value.documents;
        Home.banners=banners;
      });
      _refresh();
    });
  }
  _refresh() async{
    _subscription=await Firestore.instance.collection('appbanners').snapshots().listen((event) {
      if(!mounted) return;
      setState(() {
        banners=event.documents;
        Home.banners=banners;
      });
    });
  }
  @override
  void dispose() {
    if(_subscription!=null){
      _subscription.cancel();
    }    // TODO: implement dispose
    super.dispose();
  }
}
