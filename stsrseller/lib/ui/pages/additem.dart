import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsrseller/resources/Internet/check_network_connection.dart';
import 'package:stsrseller/resources/Internet/internetpopup.dart';
import 'package:stsrseller/resources/themes/light_color.dart';
import 'package:stsrseller/resources/themes/theme.dart';
import 'package:stsrseller/resources/ui/DialogInput.dart';
import 'package:stsrseller/resources/ui/title_text.dart';
import 'package:stsrseller/ui/loaderdialog.dart';
import 'package:stsrseller/ui/pages/home.dart';
import 'package:stsrseller/ui/widgets/uploadimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  String categoryid;
  String categoryname;//
  String subcategoryid;
  String subcategoryname;//
  String productname;//
  List<String> pictures=[];//
  String discount;//
  String price;//
  String unitsinstock;//
  String description;//
  String coins;//
  Map rating={'value':0,'count':0};


  var _generalkey=new GlobalKey<FormState>();
  List<DocumentSnapshot> categories;
  List<DocumentSnapshot> subcategories;
  List<File> picturestoupload=[];
  File categoryimg;
  File subcategoryimg;
  String subcategoryimgurl;
  List<dynamic> subcategoriesidlist=[];
  List<dynamic> subcategorylist=[];
  int categoryitemcount;
  int subcategoryitemcount;

  @override
  void initState() {
    _loadcategories();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: LightColor.background,
      appBar: AppBar(
        title: Text("Add Item"),
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
              _productimages(),
              Divider(),
              _selectcategory(),
              _categoryimage(),
              Divider(),
              _selectsubcategory(),
              _subcategoryimage(),
              Divider(),
              _generalinfo(),
              _submit(),
            ],
          ),
        ),
      ),
    );
  }

  _selectcategory(){
    TextEditingController _controller=new TextEditingController();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          if(categories==null){
            LoaderDialog(context,true,text: "Loading categories cancel and try again..");
            return;
          }
          showDialog(context: context,
            builder: (context){
            return StatefulBuilder(
              builder: (context,setstate){
                return  AlertDialog(
                  backgroundColor: LightColor.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  title: Text("Create a category or select from existing",style: GoogleFonts.lato(color: LightColor.lightGrey,fontSize: 15),),
                  content: Container(
                    height: AppTheme.fullHeight(context)/2,
                    width: AppTheme.fullWidth(context)/2,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            style: GoogleFonts.lato(color: LightColor.lightGrey,fontSize: 15),
                            controller: _controller,
                            decoration: InputDecoration(
                                hintText: "Category name",
                                hintStyle:  GoogleFonts.lato(color: LightColor.darkgrey,fontSize: 15),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.send,color: LightColor.orange,),
                                  onPressed: ()async{
                                    if(_controller.text.isEmpty) return;
                                    categoryid=null;
                                    subcategoryid=null;
                                    subcategoryname=null;
                                    categoryname=_controller.text;
                                    LoaderDialog(context,true);
                                    await _loadsubcategories();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                )
                            ),
                          ),
                          Divider(),
                          categories.isEmpty?Center(child: Text("No categories yet",style: GoogleFonts.lato(color:LightColor.grey),),):Container(alignment: Alignment.center,),
                          Container(
                            height: AppTheme.fullHeight(context)/3,
                            width: AppTheme.fullWidth(context)/3,
                            child: ListView.builder(
                                itemCount: categories.length,
                                itemBuilder: (context,index){
                                  return ListTile(
                                    title: Text(categories[index]['name'],style: GoogleFonts.lato(color: LightColor.grey),),
                                    onTap: ()async{
                                      categoryid=categories[index].documentID;
                                      categoryname=categories[index]['name'];
                                      subcategoriesidlist=categories[index]['subcategoriesid'];
                                      subcategorylist=categories[index]['subcategories'];
                                      categoryitemcount=categories[index]['itemcount'];
                                      LoaderDialog(context,true);
                                      await _loadsubcategories();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
            }
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width-90,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: LightColor.lightGrey,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Text(categoryname==null?"Enter category":categoryname,style: GoogleFonts.lato(color: LightColor.black),),
        ),
      ),
    );
  }

  _selectsubcategory(){
    TextEditingController _controller=new TextEditingController();
    return InkWell(
      onTap: ()async{
        if(subcategories==null){
          LoaderDialog(context,true,text: "select a category and try again..");
          return;
        }
        showDialog(context: context,
            builder: (context){
              return StatefulBuilder(
                builder: (context,setstate){
                  return  AlertDialog(
                    backgroundColor: LightColor.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    title: Text("Create a subcategory or select from existing",style: GoogleFonts.lato(color: LightColor.lightGrey,fontSize: 15),),
                    content: Container(
                      height: AppTheme.fullHeight(context)/2,
                      width: AppTheme.fullWidth(context)/2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            TextField(
                              style: GoogleFonts.lato(color: LightColor.lightGrey,fontSize: 15),
                              controller: _controller,
                              decoration: InputDecoration(
                                  hintText: "Sub category name",
                                  hintStyle:  GoogleFonts.lato(color: LightColor.darkgrey,fontSize: 15),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.send,color: LightColor.orange,),
                                    onPressed: (){
                                      if(_controller.text.isEmpty) return;
                                      subcategoryid=null;
                                      subcategoryimgurl=null;
                                      subcategoryitemcount=0;
                                      subcategoryname=_controller.text;
                                      Navigator.pop(context);
                                    },
                                  )
                              ),
                            ),
                            Divider(),
                            subcategories.isEmpty?Center(child: Text("No subcategories yet",style: GoogleFonts.lato(color:LightColor.grey),),):Container(alignment: Alignment.center,),
                            Container(
                              height: AppTheme.fullHeight(context)/3,
                              width: AppTheme.fullWidth(context)/3,
                              child: ListView.builder(
                                  itemCount: subcategories.length,
                                  itemBuilder: (context,index){
                                    return ListTile(
                                      title: Text(subcategories[index]['name'],style: GoogleFonts.lato(color: LightColor.grey),),
                                      onTap: (){
                                        setState(() {
                                          subcategoryid=subcategories[index].documentID;
                                          subcategoryname=subcategories[index]['name'];
                                          subcategoryimgurl=subcategories[index]['image'];
                                          subcategoryitemcount=subcategories[index]['itemcount'];
                                          Navigator.pop(context);
                                        });

                                      },
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width-90,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: LightColor.lightGrey,
            borderRadius: BorderRadius.circular(5)
        ),
        child: Text(subcategoryname==null?"Enter subcategory":subcategoryname,style: GoogleFonts.lato(color: LightColor.black),),
      ),
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
                ),keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -]'))],
                decoration: new InputDecoration(
                  counterText: "",
                  labelText: "Units in stock",
                  border: new OutlineInputBorder(
                    gapPadding: 7,
                    borderRadius: new BorderRadius.circular(5),
                  ),
                ),
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[ -]'))],
                    style: TextStyle(
                        color: LightColor.black
                    ),
                    maxLength: 2,
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

  _categoryimage(){
    if(categoryid!=null){
      return Container(alignment: Alignment.center,);
    }
    return InkWell(
      onTap: ()async{
        File _file=await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);
        if(_file!=null){
          setState(() {
            categoryimg=_file;
          });
        }
      },
      child: SizedBox(
        width: 180,
        height: 180,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          ),
          color: LightColor.darkgrey,
          child: categoryimg==null?Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Add Category image",style: GoogleFonts.lato(color: LightColor.lightblack,fontSize: 10),),
                Icon(Icons.add,color: LightColor.orange,size: 30,),
              ],
            ),
          ):ClipRRect(
              borderRadius: BorderRadius.circular(5),
            child: Image.file(categoryimg,fit: BoxFit.cover,)),
        ),
      ),
    );
  }

  _subcategoryimage(){
    if(subcategoryid!=null){
      return Container(alignment: Alignment.center,);
    }
    return InkWell(
      onTap: ()async{
        File _file=await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);
        if(_file!=null){
          setState(() {
            subcategoryimg=_file;
          });
        }
      },
      child: SizedBox(
        width: 180,
        height: 180,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          ),
          color: LightColor.darkgrey,
          child: subcategoryimg==null?Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Add subcategory image",style: GoogleFonts.lato(color: LightColor.lightblack,fontSize: 10),),
                Icon(Icons.add,color: LightColor.orange,size: 30,),
              ],
            ),
          ):ClipRRect(
              borderRadius: BorderRadius.circular(5),
            child: Image.file(subcategoryimg,fit: BoxFit.cover,)),
        ),
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
          if(categoryname==null){
              Toast.show("Enter a category", context,gravity: Toast.TOP,duration: Toast.LENGTH_LONG);
              return;
          }
          if(subcategoryname==null){
              Toast.show("Enter a subcategory", context,gravity: Toast.TOP,duration: Toast.LENGTH_LONG);
              return;
          }
          if(categoryid==null && categoryimg==null){
            Toast.show("select category image", context,gravity: Toast.TOP,duration: Toast.LENGTH_LONG);
            return;
          }
          if(subcategoryid==null && subcategoryimg==null){
            Toast.show("select subcategory image", context,gravity: Toast.TOP,duration: Toast.LENGTH_LONG);
            return;
          }
          if(picturestoupload.isEmpty){
            Toast.show("Select product images", context,gravity: Toast.TOP,duration: Toast.LENGTH_LONG);
            return;
          }
          coins=await DialogInput(context, "coins", TextInputType.number);
          if(coins.isEmpty){
            MyToast('Please enter coins', context);
            return;
          }
          LoaderDialog(context,false,text: "Submitting...");
          if(categoryid==null){
            String _image=await showDialog(context: context,barrierDismissible: false,child: UploadVideo(categoryimg,"category"));
            if(_image==null) {
              Navigator.pop(context);
              return;
            }
            Firestore.instance.collection('categories').add({
              'name':categoryname,
              'subcategoriesid':[],
              'subcategories':[],
              'itemcount':0,
              'soldcount':0,
              'discount':0,
              'image':_image,
              'totalearning':0
            }).then((value){
              categoryid=value.documentID;
              categoryitemcount=0;
              subcategoriesidlist=[];
              subcategorylist=[];
            });
          }
          if(subcategoryid==null){
            String _image=await showDialog(context: context,barrierDismissible: false,child: UploadVideo(subcategoryimg,"subcategory"));
            if(_image==null) {
              Navigator.pop(context);
              return;
            }
            Firestore.instance.collection("subcategories").add({
              'name':subcategoryname,
              'categoryid':categoryid,
              'image':_image,
              'soldcount':0,
              'itemcount':1,
              'totalearning':0,
              'discount':0
            }).then((value){
              subcategoryid=value.documentID;
              subcategoryimgurl=_image;
              subcategoryitemcount=0;
            });
          }
          String address;
          for(int i=0;i<picturestoupload.length;i++){
            address=await showDialog(context: context,barrierDismissible: false,child: UploadVideo(picturestoupload[i],"products"));
            if(address!=null){
              pictures.add(address);
              address=null;
            }
          }
          Firestore.instance.collection('products').add({
            'categoryid':categoryid,
            'categoryname':categoryname,
            'subcategoryid':subcategoryid,
            'subcategoryname':subcategoryname,
            'productname':productname,
            'hasvarients':false,
            'varients':[],
            'pictures':pictures,
            'discount':discount,
            'price':double.parse(price).toStringAsFixed(2),
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
            subcategoryitemcount++;
            categoryitemcount++;
            if(subcategoryitemcount==1){
              subcategorylist.add({'name':subcategoryname,'image':subcategoryimgurl});
              subcategoriesidlist.add(subcategoryid);
            }
            Firestore.instance.collection('categories').document(categoryid).updateData({
              'subcategoriesid':subcategoriesidlist,
              'subcategories':subcategorylist,
              'itemcount':categoryitemcount
            }).then((value){
              Firestore.instance.collection('subcategories').document(subcategoryid).updateData({
                'itemcount':subcategoryitemcount
              });
            }).then((value){
              Toast.show('product uploaded successfully', context);
              Navigator.pop(context);
              Navigator.pop(context);
            });
          });
          }
        },
      ),
    );
  }
  _loadcategories()async{
    if(await IsConnectedtoInternet()){
    ShowInternetDialog(context);
    return;
    }

    Firestore.instance.collection('categories').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        if(!mounted) return;
        setState(() {
          categories=value.documents;
        });
      }
      else{
        if(!mounted) return;
        setState(() {
          categories=[];
        });
      }
    });
  }

  _loadsubcategories() async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }

    if(categoryid==null){
      if(!mounted) return;
      setState(() {
        subcategories=[];
      });
      return;
    }
    Firestore.instance.collection('subcategories').where('categoryid',isEqualTo: categoryid).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        if(!mounted) return;
        setState(() {
          subcategories=value.documents;
        });
      }
      else{
        if(!mounted) return;
        setState(() {
          subcategories=[];
        });
      }
    });
  }

  _pickimage()async{
    File _file=await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);
    if(_file!=null){
      if(!mounted) return;
      setState(() {
        picturestoupload.add(_file);
      });
    }
  }
}
