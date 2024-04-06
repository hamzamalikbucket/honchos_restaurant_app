import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/driverModel.dart';
import 'package:honchos_restaurant_app/model/order_model.dart';
import 'package:honchos_restaurant_app/model/restaurant_model.dart';
import 'package:honchos_restaurant_app/view/home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChooseDriverScreen extends StatefulWidget {
  final RestaurantOrdersModel orderModel;
  final String resId;
  const ChooseDriverScreen(
      {super.key, required this.orderModel, required this.resId});

  @override
  State<ChooseDriverScreen> createState() => _ChooseDriverScreenState();
}

class _ChooseDriverScreenState extends State<ChooseDriverScreen> {
  int total = 0;
  List<DriversModel> restaurantList = [];
  String selectedIndexID = '', driverExisted = '', isListEmpty = '';
  String selectedIndex = '';
  String selectedRestaurantID = '';
  String currentRestaurantID = '';
  String distance = '', address = '';
  double distanceInKm = 0.0;
  bool isLoading = false;
  bool assigning = false;

  getDrivers() async {
    print(widget.resId.toString() + ' Driver Id');
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request =
        http.Request('GET', Uri.parse('${apiBaseUrl}restaurant/drivers'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    //json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        restaurantList = List<DriversModel>.from(
            json.decode(responseData).map((x) => DriversModel.fromJson(x)));
      });

      for (int i = 0; i < restaurantList.length; i++) {
        if (restaurantList[i].restaurantId.toString() == widget.resId) {
          setState(() {
            driverExisted = 'yes';
          });
        }
      }

      if (restaurantList.isEmpty) {
        setState(() {
          isListEmpty = 'yes';
          isLoading = false;
        });
      } else {
        setState(() {
          isListEmpty = 'no';
          isLoading = false;
        });
      }

      // print('location Inserted');
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

  Future<int> updateStatus(String status, String driverId) async {
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${apiBaseUrl}restaurant/order_update_status/${widget.orderModel.id}'));
    request.fields.addAll({
      'status': status,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return 200;
    } else {
      setState(() {
        assigning = false;
      });
      print(response.reasonPhrase);
      var snackBar = SnackBar(
        content: Text(
          'Something went wrong. Check your internet',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return 600;
    }
  }

  assignDriver(String driverId) async {
    var headers = {'Cookie': 'restaurant_session=$cookie'};

    var request = http.MultipartRequest(
        'POST', Uri.parse('${apiBaseUrl}restaurant/assign_driver'));
    request.fields.addAll({
      'order_id': widget.orderModel.id.toString(),
      'driver_id': driverId.toString()
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        assigning = false;
      });

      Fluttertoast.showToast(
          msg: "Status successfully changed and driver assigned ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      // var snackBar = SnackBar(content: Text('Status successfully changed and driver assigned ',style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.green,);
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RestaurantHomeScreen()),
      ).then((value) {});
    } else {
      setState(() {
        assigning = false;
      });

      Fluttertoast.showToast(
          msg: "Something went wrong while assigning driver ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      // var snackBar = SnackBar(content: Text(' ',style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.green,);
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoading = true;
      driverExisted = '';
      isListEmpty = '';
    });
    getDrivers();
    super.initState();
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
              Navigator.of(context).pop();
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
      body: SingleChildScrollView(
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
                'Choose Driver',
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
            isLoading && isListEmpty == ''
                ? Center(
                    child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 2,
                  ))
                : (restaurantList.isEmpty && isListEmpty == 'yes') ||
                        driverExisted == ''
                    ? Center(
                        child: Container(
                          child: Text('No Drivers Found'),
                        ),
                      )
                    : Container(
                        height: size.height * 0.55,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: restaurantList.length,
                          itemBuilder: (BuildContext context, index) {
                            print(restaurantList.length.toString() +
                                'Res length');
                            return restaurantList[index]
                                        .restaurantId
                                        .toString() ==
                                    widget.resId
                                ? GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      setState(() {
                                        selectedIndex = index.toString();
                                        selectedRestaurantID =
                                            restaurantList[index].id.toString();
                                        print(selectedRestaurantID);
                                      });
                                      prefs.setString(
                                          'restaurantName',
                                          restaurantList[index]
                                              .name
                                              .toString());
                                      prefs.setString(
                                          'restaurantImage',
                                          imageConstUrlRes +
                                              restaurantList[index]
                                                  .image
                                                  .toString());
                                      prefs.setString('selectedRestaurant',
                                          restaurantList[index].id.toString());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectedIndex == index.toString()
                                            ? Colors.greenAccent
                                                .withOpacity(0.5)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(0),
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
                                                      color:
                                                          lightButtonGreyColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: Image.network(
                                                        '${baseUrlMain}image/driver/' +
                                                            restaurantList[
                                                                    index]
                                                                .image
                                                                .toString(),
                                                        fit: BoxFit.cover,
                                                        height:
                                                            size.height * 0.1,
                                                        width:
                                                            size.width * 0.28,
                                                        // height: 80,
                                                        // width: 80,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Container(
                                                      // height: size.height*0.1,
                                                      width: size.width * 0.6,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  size.height *
                                                                      0.01,
                                                            ),
                                                            Text(
                                                              restaurantList[
                                                                      index]
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
                                                                  size.height *
                                                                      0.01,
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
                                  )
                                : SizedBox();
                          },
                        ),
                      ),
            SizedBox(
              height: size.height * 0.05,
            ),
            isLoading && isListEmpty == '' ||
                    ((restaurantList.isEmpty && isListEmpty == 'yes') ||
                        driverExisted == '') ||
                    (widget.orderModel.status.toString() !=
                        'Preparing your meal')
                ? Container()
                : assigning
                    ? Center(
                        child: CircularProgressIndicator(
                        color: darkRedColor,
                        strokeWidth: 2,
                      ))
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
                                      'Kindly choose one of the driver.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  if (widget.orderModel.deliveryType
                                          .toString() ==
                                      'Driver') {
                                    if (widget.orderModel.status.toString() ==
                                        'Preparing your meal') {
                                      setState(() {
                                        assigning = true;
                                      });
                                      updateStatus(
                                              'Waiting for driver to collect',
                                              selectedRestaurantID)
                                          .then((value) {
                                        if (value == 200) {
                                          assignDriver(
                                              selectedRestaurantID.toString());
                                        } else {
                                          print(
                                              'Something went wrong. Check your internet update status');
                                        }
                                      });
                                    }
                                  }
                                }

                                //
                              },
                              child: Text('Assign order', style: buttonStyle)),
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
