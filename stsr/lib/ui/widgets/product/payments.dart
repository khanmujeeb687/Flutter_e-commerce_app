import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/resources/themes/theme.dart';
import 'package:stsr/resources/ui/title_text.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:stsr/ui/pages/Home.dart';
import 'package:stsr/ui/widgets/user/MyOrders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toast/toast.dart';
import 'package:upi_india/upi_india.dart';

class Payments extends StatefulWidget {
  Map<String, dynamic> orderdata;
  List<dynamic> pids;
  String charge;
  VoidCallback clearall;
  String price;
  Payments(this.pids,this.orderdata,this.charge,this.clearall,this.price);
  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  UpiResponse _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp> apps;
  String upiid="your upi id here : to recieve payments";


  String notif="";
  IconData notificon=Icons.payment;
  Color notifcolor=LightColor.orange;

  @override
  void initState() {
    _upiIndia.getAllUpiApps().then((value) {
      setState(() {
        apps = value;
      });
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(String app) async {

    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: upiid,
      receiverName: 'Mujeenb khan',
      transactionRefId: 'OrderFromstsr',
      transactionNote: 'Ordering from drop and door',
      amount: double.parse(widget.price)+double.parse(widget.charge),
    );
  }

  Widget displayUpiApps() {
    if (apps == null)
      return Center(child: CircularProgressIndicator());
    else if (apps.length == 0)
      return Center(child: Text("No apps found to handle transaction."));
    else
      return Center(
        child: Wrap(
          children: apps.map<Widget>((UpiApp app) {
            return GestureDetector(
              onTap: (){
                _handleTransaction(app.app);
              },
              child: Container(
                height: 100,
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.memory(
                      app.icon,
                      height: 60,
                      width: 60,
                    ),
                    Text(app.name,style: GoogleFonts.muli(color: LightColor.grey),),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
  }

  _headings(text){
    return Container(
        margin: EdgeInsets.all(14),
        alignment: Alignment.topLeft,
        child: Text(text,style: GoogleFonts.muli(color:LightColor.lightblack,fontSize: 16),));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.black,
      appBar: AppBar(
        backgroundColor: LightColor.darkgrey,
        title: Text('Payment'),
      ),
      body: upiid.isEmpty?
          Center(child: SpinKitCircle(color: LightColor.orange,))
          :Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _showvalue(notif, notificon,notifcolor ),
          _headings("Pay Rs. ${double.parse(widget.price)+double.parse(widget.charge)} with"),
          displayUpiApps(),
          Stack(
            children: <Widget>[
              Divider(color: LightColor.grey,),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5,0,5,10),
                      color: LightColor.black,
                      child: Text("OR",style: GoogleFonts.muli(color: LightColor.grey,fontSize: 20),)))
            ],
          ),
          _submitButton(context),
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return FlatButton(
        onPressed: () {
          setState(() {
            notif="";
          });
          widget.orderdata['paymentdetails']={};
          widget.orderdata['ifprepaid']=false;
          _placeorder(widget.orderdata);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: LightColor.orange,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 12),
          width: AppTheme.fullWidth(context) * .7,
          child: TitleText(
            text: 'Place order with Cash on delivery',
            color: LightColor.background,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  void _chekresult(UpiResponse _upiResponse){
      if (_upiResponse.error != null) {
        String text = '';
        switch (_upiResponse.error) {
          case UpiError.APP_NOT_INSTALLED:
            text = "Requested app not installed on device";
            break;
          case UpiError.INVALID_PARAMETERS:
            text = "Requested app cannot handle the transaction";
            break;
          case UpiError.NULL_RESPONSE:
            text = "requested app didn't returned any response";
            break;
          case UpiError.USER_CANCELLED:
            text = "You cancelled the transaction";
            break;
        }
        setState(() {
          notif=text;
          notifcolor=Colors.redAccent;
          notificon=Icons.error;
        });
        return;
      }
      String txnId = _upiResponse.transactionId;
      String resCode = _upiResponse.responseCode;
      String txnRef = _upiResponse.transactionRefId;
      String status = _upiResponse.status;
      String approvalRef = _upiResponse.approvalRefNo;
      switch (status) {
        case UpiPaymentStatus.SUCCESS:
          {
            setState(() {
              notifcolor=LightColor.lightBlue;
              notif="Completing order do not press back.";
              notificon=Icons.fiber_manual_record;
            });
            widget.orderdata['paymentdetails']={
              'transactionid':txnId,
              'responsecode':resCode,
              'transactionref':txnRef,
              'status':status,
              'approvalref':approvalRef
            };
            widget.orderdata['ifprepaid']=true;
             _placeorder(widget.orderdata);
          }
          break;
        case UpiPaymentStatus.SUBMITTED:
          {
            setState(() {
              notif="Transaction went in pending state, We will refund you if we recieve payment."
                  "\nIf you do not recieve refund by 24 hours. Contact us";
              notifcolor=LightColor.orange;
              notificon=FontAwesomeIcons.download;
            });
          }
          break;
        case UpiPaymentStatus.FAILURE:
          {
            setState(() {
              notif="Transaction Failed";
              notifcolor=Colors.redAccent;
              notificon=Icons.error;
            });
          }
          break;
        default:
          print('Received an Unknown transaction status');
      }
  }


  _showvalue(text,icon,color){
    if(text.isEmpty) return Container(alignment: Alignment.center,);
    return Container(
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        leading: Icon(icon,color: color,),
        title: Text(text,style: GoogleFonts.muli(color: notifcolor,fontSize: 13),),
      ),
    );
  }

  _handleTransaction(app) async{
    if(upiid.isEmpty){
      Toast.show("Please try a bit later", context);
      return;
    }
    _transaction = await initiateTransaction(app);
    _chekresult(_transaction);
    setState(() {});
  }

  _placeorder(Map orderdata) async{
    if(await IsConnectedtoInternet()){
      ShowInternetDialog(context);
      return;
    }
    DocumentSnapshot pro;
    LoaderDialog(context, false,text:"Placing your order\n Do not press back.");
    for(int i=0;i<widget.pids.length;i++){
      await Firestore.instance.collection('products').document(widget.pids[i]['productid']).get().then((value) async{
        if(value.exists){
          pro=value;
          orderdata['productid']=widget.pids[i]['productid'];
          orderdata['sellerid']=value['sellerid'];
          orderdata['quantity']=widget.pids[i]['quantity'];
          orderdata['orderprice']=((double.parse(value['price'])*widget.pids[i]['quantity'])+(double.parse(widget.charge)/widget.pids.length)).toStringAsFixed(2);
          orderdata['productname']=value['productname'];
          orderdata['image']=value['pictures'][0];
          orderdata['coins']=value['coins'];
          await  Firestore.instance.collection('orders').add(orderdata).then((value)async{
            await Firestore.instance.collection('products').document(widget.pids[i]['productid']).updateData({
              'unitsinstock':FieldValue.increment(-int.parse(widget.pids[i]['quantity'].toString()))
            }).then((value){
              Firestore.instance.collection('categories').document(pro['categoryid']).updateData(
                  {
                    'soldcount':FieldValue.increment(int.parse(widget.pids[i]['quantity'].toString())),
                    'totalearning':FieldValue.increment((double.parse(pro['price'])*widget.pids[i]['quantity'])+(double.parse(orderdata['deliverycharge'].toString())/widget.pids.length))
                  }
              ).then((value){
                Firestore.instance.collection('subcategories').document(pro['subcategoryid']).updateData(
                    {
                      'soldcount':FieldValue.increment(int.parse(widget.pids[i]['quantity'].toString())),
                      'totalearning':FieldValue.increment((double.parse(pro['price'])*widget.pids[i]['quantity'])+(double.parse(orderdata['deliverycharge'].toString())/widget.pids.length))
                    });
              });
            });
          });
        }
      });
    }
    Firestore.instance.collection('user').document(Home.user.documentID).updateData({
      'cart':[],
      'orders':FieldValue.arrayUnion([pro.documentID])
    }).then((value){
      widget.clearall();
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(context, PageTransition(
          child: MyOrders(),
          type: PageTransitionType.upToDown
      ));
    });
  }

}