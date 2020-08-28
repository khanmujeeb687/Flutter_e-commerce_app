import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/ui/addlocation.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/pages/category.dart';
import 'package:stsr/ui/widgets/ManPower/Requests.dart';
import 'package:stsr/ui/widgets/Start/register.dart';
import 'package:stsr/ui/widgets/product/payments.dart';
import 'package:stsr/ui/widgets/home/homepage.dart';
import 'package:stsr/ui/widgets/user/Earnings.dart';
import 'package:stsr/ui/widgets/user/MyAccount.dart';
import 'package:stsr/ui/widgets/user/MyOrders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mydrawer extends StatefulWidget {
List<DocumentSnapshot> allcat;
mydrawer(this.allcat);
  @override
  _mydrawerState createState() => _mydrawerState();
}

class _mydrawerState extends State<mydrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        alignment: Alignment.topCenter,
        color: LightColor.background,
        child: ListView(
          children: <Widget>[
            Container(
              height: 150,
              color: LightColor.lightGrey,
              child: ListTile(
                title: Text("Delivery Address",style:GoogleFonts.lato(color: LightColor.lightblack,fontSize: 12),),
                subtitle: (){
                  if(Home.user['address']==""){
                   return  RaisedButton(
                     color: LightColor.orange,
                     child: Text("Set address",style: GoogleFonts.muli(color: LightColor.background),),
                     shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15)
                     ),
                     onPressed: ()async{
                       Map addressdata=await Navigator.push(context, PageTransition(
                         child: AddLocation(),
                         type: PageTransitionType.fade
                       ));
                       if(addressdata!=null){
                         LoaderDialog(context, false,text: "Updating adress..");
                         Firestore.instance.collection('user').document(Home.user.documentID).updateData({
                           'address':addressdata['address'],
                           'city':addressdata['city'],
                           'pincode':addressdata['pincode'],
                           'sublocality':addressdata['sublocality'],
                           'lat':addressdata['lat'],
                           'long':addressdata['long'],
                         }).then((value){
                           Firestore.instance.collection('user').document(Home.user.documentID).get().then((value){
                             Home.user=value;
                             Navigator.pop(context);
                             Navigator.pop(context);
                           });

                         });
                       }
                     },
                   );
                  }
                    return Text("Purana Gunj Masjid loharan, rampur Gunj Masjid loharan, rampur U.P.",
                      style:GoogleFonts.lato(color: LightColor.black,fontSize: 15),);

                }(),
                isThreeLine: true,
              ),
            ),
            _categorydata(),
            Container(
              margin: EdgeInsets.all(8),
              decoration:BoxDecoration(
                color: LightColor.yellowColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40)
              ),
              child: ListTile(
                trailing: Wrap(
                  spacing: 6,
                  children: <Widget>[
                    Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
                    Text(Home.user['coins'].toString(),style: GoogleFonts.muli(color: LightColor.yellowColor),)
                  ],
                ),
                leading: Icon(FontAwesomeIcons.coins,color: LightColor.yellowColor,),
                title: Text("Earnings",style: GoogleFonts.muli(color: LightColor.yellowColor),),
                onTap: ()async{
                 await Navigator.push(context, PageTransition(
                      child: Earnings(),
                      type: PageTransitionType.leftToRight
                  ));
                 Navigator.pop(context);
                },
              ),
            ),ListTile(
              leading: Icon(Icons.card_travel,color: LightColor.orange,),
              title: Text("My orders",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: ()async{
               await Navigator.push(context, PageTransition(
                    child: MyOrders(),
                    type: PageTransitionType.leftToRight
                ));
               Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_input_antenna,color: LightColor.orange,),
              title: Text("Services",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: ()async{
               await Navigator.push(context, PageTransition(
                    child: Requests(),
                    type: PageTransitionType.leftToRight
                ));
               Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.user,color: LightColor.orange,),
              title: Text("My Account",style: GoogleFonts.muli(color: LightColor.grey),),
              onTap: ()async{
               await Navigator.push(context, PageTransition(
                    child: MyAccount(),
                    type: PageTransitionType.leftToRight
                ));
               Navigator.pop(context);
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
                      prefs.setString('stsruserlogin', "0");
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

  _categorydata(){
    if(widget.allcat==null) return Container(height: 0,width: 0,);
    return ExpansionTile(
      leading: Icon(Icons.category,color: LightColor.darkgrey,),
      title: Text("Shop by category",style: GoogleFonts.muli(color: LightColor.orange),),
      children:List.generate(widget.allcat.length, (index){
        return ExpansionTile(
          leading: CircleAvatar(
            radius: 15,
            backgroundColor: LightColor.background,
            child:CachedNetworkImage(
            imageUrl: widget.allcat[index]['image'],
            placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
            width: 30,
            height: 30,
          ),),
          title: Text(widget.allcat[index]['name'],style: GoogleFonts.muli(color: LightColor.orange),),
          children: List.generate(widget.allcat[index]['subcategories'].length, (i){
            return ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundColor: LightColor.background,
                child:CachedNetworkImage(
                  imageUrl: widget.allcat[index]['subcategories'][i]['image'],
                  placeholder: (context, url) => SpinKitCircle(color: LightColor.orange,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 30,
                  height: 30,
                ),),
              title: Text(widget.allcat[index]['subcategories'][i]['name'],style: GoogleFonts.muli(color: LightColor.orange),),
             onTap: (){
                Navigator.push(context, PageTransition(
                  child: Category(widget.allcat[index]['subcategoriesid'][i],widget.allcat[index]['subcategories'][i]['name'])
                ));
             },
            );
          }),
        );
      }),
    );
  }
}
