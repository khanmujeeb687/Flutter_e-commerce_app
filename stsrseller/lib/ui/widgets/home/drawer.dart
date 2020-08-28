import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/ui/pages/additem.dart';
import 'package:stsrseller/ui/pages/appbaners.dart';
import 'package:stsrseller/ui/widgets/ManPower/ManPower.dart';
import 'package:stsrseller/ui/widgets/ManPower/Requests.dart';
import 'package:stsrseller/ui/widgets/Start/register.dart';
import 'package:stsrseller/ui/widgets/addresses/Deliverable.dart';
import 'package:stsrseller/ui/widgets/addresses/admins.dart';
import 'package:stsrseller/ui/widgets/myproducts/mycategories.dart';
import 'package:stsrseller/ui/widgets/orders/Earnings.dart';
import 'package:stsrseller/ui/widgets/orders/HistoryOrders.dart';
import 'package:stsrseller/ui/widgets/orders/MyOrders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mydrawer extends StatefulWidget {
  @override
  _mydrawerState createState() => _mydrawerState();
}

class _mydrawerState extends State<mydrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        alignment: Alignment.topCenter,
        color: LightColor.black,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Menu",style: GoogleFonts.muli(color: LightColor.orange,fontSize: 20),),
            ),
            Divider(height: 2,color: LightColor.grey,),
            ListTile(
              leading: Icon(Icons.add,color: LightColor.orange,),
              title: Text("Add Product",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: AddItem(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.photo,color: LightColor.orange,),
              title: Text("App banners",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: AppBanners(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.card_travel,color: LightColor.orange,),
              title: Text("My products",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: Mycategories(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),ListTile(
              leading: Icon(FontAwesomeIcons.snowman,color: LightColor.orange,),
              title: Text("ManPower",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: ManPower(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.call,color: LightColor.orange,),
              title: Text("Requests",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: Requests(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            Container(
              margin: EdgeInsets.all(8),
              decoration:BoxDecoration(
                  color: LightColor.yellowColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40)
              ),
              child: ListTile(
                leading: Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
                title: Text("Coins transactions",style: GoogleFonts.muli(color: LightColor.yellowColor),),
                onTap: ()async{
                  await Navigator.push(context, PageTransition(
                      child: Earnings(),
                      type: PageTransitionType.leftToRight
                  ));
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on,color: LightColor.orange,),
              title: Text("Deliverable address",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: Deliverable(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite_border,color: LightColor.orange,),
              title: Text("Manage Orders",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: MyOrders(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.timeline,color: LightColor.orange,),
              title: Text("Orders history",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: HistoryOrders(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.crown,color: LightColor.orange,),
              title: Text("Admins",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: (){
                Navigator.push(context, PageTransition(
                  child: Admins(),
                  duration: Duration(milliseconds: 100),
                  type: PageTransitionType.leftToRight
                ));
              },
            ),
            ExpansionTile(
              title: Text("Logout",style: GoogleFonts.lato(color: LightColor.grey),),
              leading: Icon(FontAwesomeIcons.signOutAlt,color: LightColor.grey,),
              children: <Widget>[
                ListTile(
                  title: Text("Are you sure!",style: GoogleFonts.lato(color:LightColor.orange),),
                  leading: Icon(Icons.exit_to_app,color: LightColor.orange,),
                  trailing: OutlineButton(
                    color: LightColor.orange,
                    borderSide: BorderSide(color: LightColor.orange),
                    child: Text("Yes",style: GoogleFonts.lato(color: LightColor.orange),),
                    onPressed: ()async{
                      SharedPreferences prefs=await SharedPreferences.getInstance();
                      prefs.setString('sellerlogin', "0");
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(context, PageTransition(
                          child: Register(),
                          duration: Duration(milliseconds: 10),
                          type: PageTransitionType.fade
                      ));
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
