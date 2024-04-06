import 'dart:convert';

import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/session_model.dart';
import 'package:honchos_restaurant_app/view/chooseRestaurant/choose_restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:io' show Platform;


import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';

class EnableLocationScreen extends StatefulWidget {
  const EnableLocationScreen({Key? key}) : super(key: key);

  @override
  _EnableLocationScreenState createState() => _EnableLocationScreenState();
}

class _EnableLocationScreenState extends State<EnableLocationScreen> {


  bool positionStreamStarted = false,  isLoading = false;
  String token = '';
  double lat = 0.0,long =0.0;
  int y=0;
  bool isLoadingLocation = false;

  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() => _currentPosition = position);



      if(_currentPosition != null) {



        var headers = {
          'Content-Type': 'application/json',
          'Cookie': 'restaurant_session=$cookie'
        };
        var request = http.Request('POST', Uri.parse('${apiBaseUrl}location_insert?longitude=${_currentPosition!.latitude.toDouble()}&latitude=${_currentPosition!.longitude.toDouble()}'));
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        if (response.statusCode == 200) {
          //getRestaurants();
          print('location Inserted');
          setState(() {
            isLoadingLocation = false;
          });

          var snackBar = SnackBar(content: Text('Location inserted'
            ,style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => ChosseRestaurantScreen(long: _currentPosition!.longitude,lat: _currentPosition!.latitude,  status: '', )));

        }
        else if (response.statusCode == 302) {
          setState(() {
            isLoadingLocation = false;
          });
        }
        else {
          setState(() {
            isLoadingLocation = false;
          });
          print(response.reasonPhrase);
          var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
            ,style: TextStyle(color: Colors.white),),
              backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }







      }
      print(_currentPosition!.latitude.toString() + ' This is lat ');
      print(_currentPosition!.longitude.toString()+ ' This is long ');
      prefs.setDouble('lat', _currentPosition!.latitude);
      prefs.setDouble('long',_currentPosition!.longitude);
      _getAddressFromLatLng(position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(52.2165157, 6.9437819);
    await geocoding.placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<geocoding.Placemark> placemarks) {
      geocoding.Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.street}, ${place.subLocality},${place.subAdministrativeArea} ${place.postalCode}';
      });
      prefs.setString('userAddress', _currentAddress.toString());
    }).catchError((e) {
      debugPrint(e);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoadingLocation = false;
      lat = 0.0;
      long =0.0;
      y=0;
      token = '';
    });

     _getGeoLocationPosition();
    super.initState();
  }



  Future<Position> _getGeoLocationPosition() async {

    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();





    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        var snackBar = SnackBar(content: Text('Please give location permission otherwise you will not be able to move further. '
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
      else if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {



      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    } else {
      print(  ' Get Current Location we are in else');
      _getCurrentPosition();
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {

     // Position position;
      setState(() => _currentPosition = value);
      print(_currentPosition!.latitude.toString() + ' This is lat ');
      print(_currentPosition!.longitude.toString()+ ' This is long ');
      _getAddressFromLatLng(value);

      return value;

    });

  }


  // void getSessionToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var headers = {
  //     'Content-Type': 'application/json',
  //     'Cookie': 'restaurant_session=$cookie'
  //   };
  //   var request = http.Request('POST', Uri.parse('${apiBaseUrl}get_session'));
  //
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //   final responseData = await response.stream.bytesToString();
  //   if (response.statusCode == 200) {
  //     SessionModel model = SessionModel.fromJson(json.decode(responseData));
  //     prefs.setString('token', model.session!.token.toString());
  //     print('Session Token ${model.session!.token.toString()}');
  //   }
  //   else if (response.statusCode == 302) {
  //     print(response.reasonPhrase);
  //     print('token 302');
  //   }
  //   else {
  //     print(response.reasonPhrase);
  //     print('token else');
  //
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    // if(y==0) {
    //   setState(() {
    //     myPosition();
    //     y=1;
    //   });
    // }
    // getSessionToken();

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height*0.15,
            ),

            Center(
                child: Text('Enable Location', style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xFF585858), fontSize: 25,fontWeight: FontWeight.bold),)
            ),

            SizedBox(
              height: size.height*0.025,
            ),

            Container(
              width: size.width*0.8,
              child: Center(
                  child: Text('Turn on your location services so we can fetch your exact location for delivery.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: darkGreyTextColor, fontSize: 14,),)
              ),
            ),

            SizedBox(
              height: size.height*0.025,
            ),


            Center(
              child: SizedBox(
                // height: size.height*0.5,
                width: size.width*0.8,
                child: Image.asset('assets/images/enable_location_image.png', fit: BoxFit.scaleDown,
                  // height: size.height*0.5,
                  width: size.width*0.8,
                  // height: 80,
                  // width: 80,
                ),
              ),
            ),



            SizedBox(
              height: size.height*0.12,
            ),
            isLoadingLocation ? Center(child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            )) :
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Container(

                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [
                      darkRedColor,
                      lightRedColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(Size(size.width, 50)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      // elevation: MaterialStateProperty.all(3),
                      shadowColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),

                    onPressed: () async {
                      setState(() {
                        isLoadingLocation = true;
                      });
                      _getCurrentPosition();




                      // _getCurrentPosition().then((value) {
                      //
                      //
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => ChosseRestaurantScreen(long: _currentPosition!.longitude,lat: _currentPosition!.latitude,  status: '', )));
                      //
                      // });
                      // LocationPermission permission;
                      //
                      // permission = await Geolocator.checkPermission();
                      //
                      //
                      //
                      //
                      // if (permission == LocationPermission.denied) {
                      //   permission = await Geolocator.requestPermission();
                      //   if (permission == LocationPermission.denied) {
                      //     var snackBar = SnackBar(content: Text('Please give location permission otherwise you will not be able to move further. '
                      //       ,style: TextStyle(color: Colors.white),),
                      //       backgroundColor: Colors.red,
                      //     );
                      //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      //     // Permissions are denied, next time you could try
                      //     // requesting permissions again (this is also where
                      //     // Android's shouldShowRequestPermissionRationale
                      //     // returned true. According to Android guidelines
                      //     // your App should show an explanatory UI now.
                      //    // return Future.error('Location permissions are denied');
                      //   }
                      // }
                      // else {
                      //   print(permission.toString()+' wwe are');
                      //   if (permission == LocationPermission.whileInUse || permission == LocationPermission.always ) {
                      //
                      //     myPosition().whenComplete(() {
                      //       var snackBar = SnackBar(content: Text('Location Enabled Successfully '
                      //         ,style: TextStyle(color: Colors.white),),
                      //         backgroundColor: Colors.green,
                      //       );
                      //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(builder: (context) => ChosseRestaurantScreen(long: long,lat: lat,)));
                      //     });
                      //
                      //
                      // }
                      //
                      // }

                     // _getGeoLocationPosition();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => ChosseRestaurantScreen()));
                      //
                    }, child: Text('Next', style: buttonStyle)),
              ),
            ),
            SizedBox(
              height: size.height*0.05,
            ),
            GestureDetector(
              onTap: () {
                // if(way == 'email') {
                //   setState(() {
                //     way = 'phone';
                //   });
                // } else {
                //   setState(() {
                //     way = 'email';
                //   });
                // }
              },
              child: Center(
                  child: Text('Not now', style: TextStyle(color: Color(0xFF585858), fontSize: 15,fontWeight: FontWeight.bold),)
              ),
            ),
            SizedBox(
              height: size.height*0.05,
            ),


          ],
        ),
      ),
    );
  }
}
