import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stsr/resources/Internet/check_network_connection.dart';
import 'package:stsr/resources/Internet/internetpopup.dart';
import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/ui/loaderdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

import 'Addressbox.dart';

class AddLocation extends  StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {


  Position _position;
  String _address;
  String _city;
  double pinpill;
  int a;
  bool move=true;
  String _pincode;
  String _sublocality;
  bool candeliver=false;
  Address _first;
  String charge;
  List<dynamic> time;

  static const LatLng _center = const LatLng(28.555229, 77.285257);
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _mapController = Completer();
  MapType _currentMapType = MapType.satellite;
  GoogleMapController _mapcontroller;


  @override
  void initState() {
    pinpill=-500;
    a=0;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set<Marker>.of(_markers.values),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            onCameraMove: _oncameramove,
            mapType: _currentMapType,
            onCameraIdle: (){
              if(a==1){
                setState(() {
                  _getgeocodedaddress(_position);
                  pinpill=80;
                });
                a=0;
              }

            },
          ),

          Addressbox(_address,pinpill)
          ,
          Align(
            alignment: Alignment.centerRight,
            child:  Container(
              padding: EdgeInsets.all(20),
              child: FloatingActionButton(
                backgroundColor: LightColor.background,
                child: Icon(Icons.arrow_forward,color: LightColor.orange,),
                onPressed: ()async{
                  if(await IsConnectedtoInternet()){
                    ShowInternetDialog(context);
                    return;
                  }
                  if(_first==null) return;
                  LoaderDialog(context,false);
                    await Firestore.instance.collection('deliverableaddresses').where('pincode',isEqualTo: _first.postalCode).getDocuments().then((value)async{
                      if(value.documents.isNotEmpty){
                    if(await _IfDeliver(_position,value.documents)){
                      setState(() {
                      charge=value.documents.first['charge'];
                      time=value.documents.first['time'];
                      candeliver=true;
                      });
                      }else{
                      setState(() {
                      candeliver=false;
                      });
                      }
                      }else{
                        setState(() {
                          candeliver=false;
                        });
                      }
                    });
                  Navigator.pop(context);
                  bool waiter=await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context){
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          title: ListTile(
                              subtitle: Text(candeliver?"Delivers here!":"Does Not delivers here",style: GoogleFonts.muli(
                                color: candeliver?LightColor.black:LightColor.orange
                              ),),
                              title: Text("Are you sure you wants to submit this address?",style: GoogleFonts.lato(color: LightColor.grey),)),
                          actions: <Widget>[
                            !candeliver? Container(alignment: Alignment.center,):OutlineButton(
                              child: Text("Yes",style: GoogleFonts.lato(color: LightColor.orange),),
                              onPressed: (){
                                if(_city!=null && _address!=null && _position!=null){
                                  Navigator.pop(context,true);
                                }else{
                                  Toast.show("Please select a location!", context);
                                }
                              },
                            ),
                            OutlineButton(
                              child: Text("Cancel",style: GoogleFonts.lato(color: LightColor.lightGrey),),
                              onPressed: (){
                                Navigator.pop(context,false);
                              },
                            ),
                          ],
                        );
                      }

                  );
                  if(waiter==null){
                    waiter=false;
                  }
                  if(waiter){
                    Navigator.pop(context,{
                      'lat':_position.latitude.toString(),
                      'long':_position.longitude.toString(),
                      "address":_address,
                      "city":_city,
                      "pincode":_pincode.toString(),
                      "sublocality":_sublocality.toString(),
                      "charge":charge,
                      "time":time
                    });
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child:Container(
              margin: EdgeInsets.all(20),
              child: IconButton(
    icon: Icon(Icons.map,color: LightColor.orange,),
    iconSize: 50,
    onPressed: (){
    setState(() {
    _currentMapType=_currentMapType==MapType.normal?MapType.satellite:MapType.normal;
    });
    },
    ),
            ),
          )
        ],
      ),

    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }







  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    _mapcontroller=controller;
    getcurrentlocation();
  }

  _addusermarker(Position position)
  {
    MarkerId markerId = MarkerId("mid");
    Marker marker = Marker(
        markerId: markerId,
        position: LatLng(position.latitude,position.longitude),
        draggable: false,
        icon: BitmapDescriptor.fromAsset("assets/images/marker.png")
    );
    if(!mounted) return;
    setState(() {
      _markers[markerId] = marker;
    });

  }


  getcurrentlocation() async {

    _position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (_position == null) {
      _position = await Geolocator().getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.best);
    }
    _getgeocodedaddress(_position);
  }




  _getgeocodedaddress(Position position)async{
    _position=Position(latitude:position.latitude,longitude: position.longitude);
    debugPrint(_position.latitude.toString());
    debugPrint(_position.longitude.toString());
    if(!mounted) return;
    if(move){
      _mapcontroller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_position.latitude,_position.longitude),
            zoom: 18,
          ),
        ),
      );
      move=false;
    }
    if(!mounted) return;
    final coordinates = new Coordinates(
        position.latitude, position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        coordinates);
    var first = addresses.first;
    if(!mounted) return;
    setState(() {
      _first=first;
      _pincode=first.postalCode;
      if(first.subLocality==null){
        _sublocality="";
      }else{
        _sublocality=first.subLocality;
      }
      pinpill=80;
      _address= first.addressLine;
      _address=_address.replaceAll("null", "");
    });
    _city=first.locality;
    _addusermarker(_position);

  }


  void _oncameramove(CameraPosition position) {
    a=1;
    _position=Position(latitude: position.target.latitude,longitude: position.target.longitude);
    if(_markers.length > 0) {
      MarkerId markerId = MarkerId("mid");
      Marker marker = _markers[markerId];
      Marker updatedMarker = marker.copyWith(
        positionParam: position.target,
      );
      if(!mounted) return;
      setState(() {
        pinpill=-500;
        _markers[markerId] = updatedMarker;
      });

    }
  }

  Future<bool> _IfDeliver(Position position,List<DocumentSnapshot> ourlocation) async{
    if(position==null) return false;
    for(int i=0;i<ourlocation.length;i++){
      double distanceInMeters = await new Geolocator().distanceBetween(position.latitude,position.longitude,
          double.parse(ourlocation[i]['lat'].toString()), double.parse(ourlocation[i]['long'].toString()));
      if(distanceInMeters!=null){
        if(distanceInMeters<=1000){
          return true;
        }
      }
    }
    return false;
  }

}
