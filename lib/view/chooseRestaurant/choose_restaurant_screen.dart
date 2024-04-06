import 'dart:convert';

import 'package:honchos_restaurant_app/constants.dart';
//import 'package:honchos_restaurant_app/dashBoard/dashboard_screen.dart';
import 'package:honchos_restaurant_app/model/cartModel.dart';
import 'package:honchos_restaurant_app/model/get_cart_model.dart';
import 'package:honchos_restaurant_app/model/product_model.dart';
import 'package:honchos_restaurant_app/model/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:honchos_restaurant_app/view/auth/signUp/sign_up_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin;

import 'package:shared_preferences/shared_preferences.dart';

class ChosseRestaurantScreen extends StatefulWidget {
  final String phone;
  const ChosseRestaurantScreen({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  _ChosseRestaurantScreenState createState() => _ChosseRestaurantScreenState();
}

class _ChosseRestaurantScreenState extends State<ChosseRestaurantScreen> {
  List<RestaurantModel> restaurantList = [];
  List<RestaurantModel> restaurantListWithDMS = [];
  String selectedIndexCollect = '';
  String selectedIndexDeliver = '';
  bool isLoading = false;
  String selectedIndex = '';
  String selectedIndexmark = '\'';
  String selectedIndexDistance = '';
  String selectedIndexID = '';
  String selectedRestaurantID = '';
  List<CartModel> cartList = [];
  List<ProductModel> productList = [];

  @override
  void initState() {
    // TODO: implement initState
    // if(widget.status == 'delete') {
    //   getAddedCart();
    //
    // }

    setState(() {
      selectedRestaurantID = '';
      selectedIndexCollect = '';
      selectedIndexDeliver = '';
      isLoading = true;
      selectedIndex = '';
      selectedIndexDistance = '';
      selectedIndexID = '';
    });
    getRestaurants();
    super.initState();
  }

  bool checkDpo(String latLong) {
    String pattern =
        "^[-+]?([0-9]|[1-8][0-9]|90)°([0-9]|[1-5][0-9])\'([0-9]|[1-5][0-9])(\.\d+)?\"?";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(latLong))
      return false;
    else
      return true;
  }

  getRestaurants() async {
    var headers = {

    'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}restaurants'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    //json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        restaurantList = List<RestaurantModel>.from(
            json.decode(responseData).map((x) => RestaurantModel.fromJson(x)));
        isLoading = false;
      });

      print('location Inserted');
    } else if (response.statusCode == 302) {
      setState(() {
        isLoading = false;
      });
      var snackBar = SnackBar(
        content: Text(
          'Something went wrong',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      var snackBar = SnackBar(
        content: Text(
          await response.stream.bytesToString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  bool isDmsFormat(String latLngString) {
    RegExp dmsRegExp =
        RegExp(r'^\s*[+-]?\d{1,3}°\s\d{1,2}\s\d{1,2}(\.\d+)?\"[NSEW]\s*$');
    return dmsRegExp.hasMatch(latLngString);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:0)));
              // Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Image.asset(
                'assets/images/arrow_back.png',
                height: 20,
                width: 20,
                fit: BoxFit.scaleDown,
              ),
            )),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightRedColor.withOpacity(0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            'assets/images/locationIcon.png',
                            fit: BoxFit.scaleDown,
                            height: 30,
                            width: 30,
                            // height: 80,
                            // width: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.025,
                  ),
                  Container(
                    width: size.width * 0.7,
                    child: Center(
                        child: Text(
                      'Choose your favourite restaurant and continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFF585858),
                          fontSize: 15,
                          wordSpacing: 2,
                          height: 1.4),
                    )),
                  ),
                  SizedBox(
                    height: size.height * 0.025,
                  ),
                  restaurantList.isEmpty
                      ? Center(
                          child: Container(
                            child: Column(
                              children: [
                                Text(
                                  'No Restaurants Found Nearby',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF585858),
                                      fontSize: 15,
                                      wordSpacing: 2,
                                      height: 1.4),
                                ),
                                SizedBox(
                                  height: size.height * 0.05,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 4),
                                            blurRadius: 5.0)
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
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  Size(size.width, 50)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                          // elevation: MaterialStateProperty.all(3),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          //
                                        },
                                        child:
                                            Text('Back', style: buttonStyle)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                    height: size.height*0.55,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: restaurantList.length,
                            itemBuilder: (BuildContext context, index) {
                              print(restaurantList.length.toString() +
                                  'Res length');
                              return GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    selectedIndex = index.toString();
                                    selectedRestaurantID = restaurantList[index].id.toString();
                                  });
                                  prefs.setString('restaurantName',
                                      restaurantList[index].name.toString());
                                  prefs.setString(
                                      'restaurantImage',
                                      imageConstUrlRes +
                                          restaurantList[index].image.toString());
                                  prefs.setString('selectedRestaurant',
                                      restaurantList[index].id.toString());

                                },
                                child: Container(

                                  decoration: BoxDecoration(
                                    color: selectedIndex == index.toString() ? Colors.greenAccent.withOpacity(0.5) : Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(0),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: size.height * 0.015,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Container(
                                          width: size.width,
                                          child: Row(
                                            children: [
                                              Container(
                                                height: size.height * 0.1,
                                                width: size.width * 0.28,
                                                decoration: BoxDecoration(
                                                  color: lightButtonGreyColor,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Image.network(
                                                    '${baseUrlMain}image/restaurants/' +
                                                        restaurantList[index]
                                                            .image
                                                            .toString(),
                                                    fit: BoxFit.cover,
                                                    height: size.height * 0.1,
                                                    width: size.width * 0.28,
                                                    // height: 80,
                                                    // width: 80,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: Container(
                                                  // height: size.height*0.1,
                                                  width: size.width * 0.6,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              size.height * 0.01,
                                                        ),
                                                        Text(
                                                          restaurantList[index]
                                                              .name
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              color: Color(
                                                                  0xFF585858),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),

                                                        SizedBox(
                                                          height:
                                                              size.height * 0.01,
                                                        ),


                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.015,
                                      ),
                                      Container(
                                        width: size.width * 0.8,
                                        child: Divider(
                                          color: darkGreyTextColor,
                                          height: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.height * 0.015,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  restaurantList.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 5.0)
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
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  minimumSize: MaterialStateProperty.all(
                                      Size(size.width, 50)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                  // elevation: MaterialStateProperty.all(3),
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                onPressed: () {
                                  if (selectedIndex == '') {
                                    var snackBar = SnackBar(
                                      content: Text(
                                        'Kindly choose one of the restaurant.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {

                                    Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (context) => SignUpScreen(phone: widget.phone, restaurantId: selectedRestaurantID.toString(),)
                                    ));

                                  }

                                  //
                                },
                                child: Text('Continue', style: buttonStyle)),
                          ),
                        ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                ],
              ),
            ),
    );
  }
}
