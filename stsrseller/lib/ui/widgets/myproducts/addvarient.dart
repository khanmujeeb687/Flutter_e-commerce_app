import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'package:stsrseller/resources/ui/title_text.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import '../../loaderdialog.dart';
import '../uploadimage.dart';

class AddVarient extends StatefulWidget {
  DocumentSnapshot data;
  AddVarient(this.data);
  @override
  _AddVarientState createState() => _AddVarientState();
}

class _AddVarientState extends State<AddVarient> {

  String productname;//
  List<dynamic> pictures=[];//
  List<dynamic> varients=[];//
  String discount;//
  String price;//
  String unitsinstock;//
  String coins;//
  String description;//
  Map rating={'value':0,'count':0};


  var _generalkey=new GlobalKey<FormState>();
  List<File> picturestoupload=[];
  int categoryitemcount;
  int subcategoryitemcount;
  bool _useexisimg=false;
  @override
  void initState() {
    productname=widget.data['productname'];
    discount=widget.data['discount'];
    price=widget.data['price'];
    description=widget.data['description'];
    varients=widget.data['varients'];
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: LightColor.background,
      appBar: AppBar(
        title: Text("Add varient"),
        backgroundColor: LightColor.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              !_useexisimg?_productimages():Container(alignment: Alignment.center,),
              _useexistingimages(),
              Divider(),
              _selectcategory(),
              Divider(),
              _selectsubcategory(),
              Divider(),
              _generalinfo(),
              _submit(),
            ],
          ),
        ),
      ),
    );
  }

  _useexistingimages(){
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: MediaQuery.of(context).size.width-90,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: LightColor.lightGrey,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Checkbox(
            value: _useexisimg,
            onChanged: (value){
              setState(() {
                _useexisimg=value;
              });
            },
          ),
          Text("Use existing images",style: GoogleFonts.lato(color: LightColor.black),),
        ],
      ),
    );
  }
_selectcategory(){
    return Container(
      width: MediaQuery.of(context).size.width-90,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: LightColor.lightGrey,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text("Category : "+widget.data['categoryname'],style: GoogleFonts.lato(color: LightColor.black),),
    );
  }

  _selectsubcategory(){
    return Container(
      width: MediaQuery.of(context).size.width-90,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: LightColor.lightGrey,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text("Subcategory : "+widget.data['subcategoryname'],style: GoogleFonts.lato(color: LightColor.black),),
    );
  }

  Widget _generalinfo(){
    return Form(
      key: _generalkey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(30, 2, 30, 5),
              child: new TextFormField(
                style: TextStyle(
                    color: LightColor.black
                ),
                keyboardType: TextInputType.text,
                initialValue: productname,
                decoration: new InputDecoration(
                  counterText: "",
                  labelText: "Product name",
                  border: new OutlineInputBorder(
                    gapPadding: 7,
                    borderRadius: new BorderRadius.circular(5),
                  ),
                ),
                // ignore: missing_return
                validator: (value){
                  if(value.isEmpty)
                  {
                    return "Please enter product name";
                  }
                  else{
                    productname=value;
                    return null;
                  }
                },
                onChanged: (v){
                  productname=v;
                },
              ),
            ),SizedBox(height: 10),
            Padding(padding: EdgeInsets.fromLTRB(30, 2, 30, 5),
              child: new TextFormField(
                style: TextStyle(
                    color: LightColor.black
                ),
                decoration: new InputDecoration(
                  counterText: "",
                  labelText: "Units in stock",
                  border: new OutlineInputBorder(
                    gapPadding: 7,
                    borderRadius: new BorderRadius.circular(5),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -]'))],
                maxLength: 10,
                // ignore: missing_return
                validator: (value){
                  if(value.isEmpty)
                  {
                    return "Please enter your available stock";
                  }
                  else{
                    value=value.replaceAll("-", "");
                    value=value.replaceAll(",", "");
                    value=value.replaceAll(".", "");
                    value=value.replaceAll(" ", "");
                    unitsinstock=value;
                    return null;
                  }
                },
                onChanged: (v){
                  v=v.replaceAll("-", "");
                  v=v.replaceAll(",", "");
                  v=v.replaceAll(".", "");
                  v=v.replaceAll(" ", "");
                  unitsinstock=v;
                },
              ),
            ),SizedBox(height: 10),
            Padding(padding: EdgeInsets.fromLTRB(30, 2, 30, 5),
              child: new TextFormField(
                initialValue: description,
                style: TextStyle(
                    color: LightColor.black
                ),
                keyboardType: TextInputType.text,
                maxLines: 4,
                decoration: new InputDecoration(
                  counterText: "",
                  labelText: "Product description",
                  border: new OutlineInputBorder(
                    gapPadding: 7,
                    borderRadius: new BorderRadius.circular(5),
                  ),
                ),
                // ignore: missing_return
                validator: (value){
                  if(value.isEmpty)
                  {
                    return "Please enter product description";
                  }
                  else{
                    description=value;
                    return null;
                  }
                },
                onChanged: (v){
                  description=v;
                },
              ),
            ),SizedBox(height: 10),
            _showprice(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width/2),
                  padding: EdgeInsets.fromLTRB(30, 2, 2, 5),
                  child: new TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -]'))],
                    initialValue: price,
                    style: TextStyle(
                        color: LightColor.black
                    ),
                    decoration: new InputDecoration(
                      counterText: "",
                      labelText: "Selling price",
                      border: new OutlineInputBorder(
                        gapPadding: 7,
                        borderRadius: new BorderRadius.circular(5),
                      ),
                    ),
                    // ignore: missing_return
                    validator: (value){
                      if(value.isEmpty)
                      {
                        return "Please enter price";
                      }
                      else{
                        value=value.replaceAll("-", "");
                        value=value.replaceAll(",", "");
                        value=value.replaceAll(".", "");
                        value=value.replaceAll(" ", "");
                        price=value;
                        return null;
                      }
                    },
                    onChanged: (v){
                      v=v.replaceAll("-", "");
                      v=v.replaceAll(",", "");
                      v=v.replaceAll(".", "");
                      v=v.replaceAll(" ", "");
                      if(v.isEmpty)
                      {
                        v="0";
                      }
                      setState(() {
                        price=v;

                      });
                    },
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width/2)-45,
                  padding: EdgeInsets.fromLTRB(2, 2, 30, 5),
                  child: new TextFormField(
                    initialValue: discount,
                    style: TextStyle(
                        color: LightColor.black
                    ),
                    maxLength: 2,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -]'))],
                    decoration: new InputDecoration(
                      counterText: "",
                      labelText: "Discount",
                      border: new OutlineInputBorder(
                        gapPadding: 7,
                        borderRadius: new BorderRadius.circular(5),
                      ),
                    ),
                    // ignore: missing_return
                    validator: (value){
                      if(value.isEmpty)
                      {
                        return "Please enter discount(0 if no discount)";
                      }
                      else{
                        value=value.replaceAll("-", "");
                        value=value.replaceAll(",", "");
                        value=value.replaceAll(".", "");
                        value=value.replaceAll(" ", "");
                        discount=value;
                        return null;
                      }
                    },
                    onChanged: (v){
                      v=v.replaceAll("-", "");
                      v=v.replaceAll(",", "");
                      v=v.replaceAll(".", "");
                      v=v.replaceAll(" ", "");
                      if(v.isEmpty)
                      {
                        v="0";
                      }
                      setState(() {
                        discount=v;

                      });
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _productimages(){
    return Container(
      alignment: Alignment.center,
      width: AppTheme.fullWidth(context),
      height: 160,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: picturestoupload.length+1,
          itemBuilder:(context,index){
            if(index==picturestoupload.length){
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){
                    _pickimage();
                  },
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Card(
                      elevation: 10,
                      color: LightColor.darkgrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Add Product images",style: GoogleFonts.lato(color: LightColor.lightblack,fontSize: 10),),
                          Icon(Icons.add,color: LightColor.orange,size: 30,),
                        ],
                      ),),
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              width: 150,
              height: 150,
              child: Card(
                elevation: 10,
                color: LightColor.darkgrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Image.file(picturestoupload[index],fit: BoxFit.cover,),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.cancel),
                            iconSize: 30,
                            color: LightColor.black,
                            onPressed: (){
                              setState(() {
                                picturestoupload.removeAt(index);
                              });
                            },
                          ),
                        )
                      ],
                      fit: StackFit.expand,
                    )),
              ),
            );
          }
      ),
    );
  }

  _showprice(){
    return  Container(
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width-90,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: LightColor.lightGrey,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text(price!=null && discount!=null?"Price : Rs.${
          double.parse(price)-((double.parse(price)*double.parse(discount))/100)
      }":"Price Rs. 0.0",style: GoogleFonts.lato(color: LightColor.black),),
    );
  }
  _submit() {
    return Container(
      width: MediaQuery.of(context).size.width-100,
      child: RaisedButton(
        color: LightColor.black,
        child: Text("Submit",style: GoogleFonts.lato(color:LightColor.orange),),
        onPressed: ()async{
          if(await IsConnectedtoInternet()){
            ShowInternetDialog(context);
            return;
          }

          if(_generalkey.currentState.validate()){
            if(picturestoupload.isEmpty && !_useexisimg){
              Toast.show("Select product images", context,gravity: Toast.TOP,duration: Toast.LENGTH_LONG);
              return;
            }
            coins=await DialogInput(context, "coins", TextInputType.number);
            if(coins.isEmpty){
              MyToast('Please enter coins', context);
              return;
            }
            LoaderDialog(context,false,text: "Submitting...");
            String address;
            if(_useexisimg){
              pictures.clear();
              pictures=widget.data['pictures'];
            }else{
              for(int i=0;i<picturestoupload.length;i++){
                address=await showDialog(context: context,barrierDismissible: false,child: UploadVideo(picturestoupload[i],"products"));
                if(address!=null){
                  pictures.add(address);
                  address=null;
                }
              }
            }
            varients.add(widget.data.documentID);
            await Firestore.instance.collection('products').add({
              'categoryid':widget.data['categoryid'],
              'categoryname':widget.data['categoryname'],
              'subcategoryid':widget.data['subcategoryid'],
              'subcategoryname':widget.data['subcategoryname'],
              'productname':productname,
              'hasvarients':true,
              'varients':varients,
              'pictures':pictures,
              'discount':discount,
              'price':price,
              'unitsinstock':int.parse(unitsinstock),
              'description':description,
              'rating':rating,
              'reviews':[],
              'unitssold':0,
              'sellerid':Home.user.documentID,
              'productid':"",
              'coins':int.parse(coins)
            }).then((value)async{
              await Firestore.instance.collection('products').document(value.documentID).updateData({
                'productid':value.documentID
              });
             await Firestore.instance.collection('categories').document(widget.data['categoryid']).updateData({
                'itemcount':FieldValue.increment(1)
              });
             await Firestore.instance.collection('subcategories').document(widget.data['subcategoryid']).updateData({
                'itemcount':FieldValue.increment(1)
              });
             for(int j=0;j<varients.length;j++){
               if(varients[j]==value.documentID) continue;
               await Firestore.instance.collection('products').document(varients[j]).updateData({
                 'hasvarients':true,
                 'varients':FieldValue.arrayUnion([value.documentID])
               });
             }
              Toast.show('product uploaded successfully', context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            });
          }
        },
      ),
    );
  }
  _pickimage()async{
    File _file=await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if(_file!=null){
      setState(() {
        picturestoupload.add(_file);
      });
    }
  }
}
