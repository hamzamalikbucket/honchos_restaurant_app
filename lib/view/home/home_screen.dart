import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/order_model.dart';
import 'package:honchos_restaurant_app/model/session_model.dart';
import 'package:honchos_restaurant_app/view/auth/login/login_screen.dart';
import 'package:honchos_restaurant_app/view/home/orderDetail/order_detail_screen.dart';
import 'package:honchos_restaurant_app/view/splash/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _RestaurantHomeScreenState createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  int y = 0;
  String? renterEmail = '',
      renterName = '',
      renterUid = '',
      readyToCollect = '',
      collect = '',
      delivered = '',
      preparing = '',
      acceptingOrder = '';
  List<RestaurantOrdersModel> ordersList = [];
  bool isLoading = false;
  String isListEmpty = '';

  // git init
  // git add README.md
  // git commit -m "23 June 2023 commit"
  // git branch -M main
  // git remote add origin https://github.com/junaid4jd/honchos_restaurant_app.git
  // git push -f origin main

  SessionModel? model;
  void getSessionToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('POST', Uri.parse('${apiBaseUrl}get_session'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      model = SessionModel.fromJson(json.decode(responseData));
      prefs.setString('token', model!.session!.token.toString());
      prefs.setString('userName', model!.session!.name.toString());
      prefs.setString('userId', model!.session!.restaurantId.toString());
      print('Session Token ${model!.session!.token.toString()}');
      print('Session Token ${prefs.getString('userId').toString()}');

      //cartController.fetchCartItems();
    } else if (response.statusCode == 302) {
      print(response.reasonPhrase);
      print('Session Token 302 ${prefs.getString('userId').toString()}');
    } else {
      print(response.reasonPhrase);
      print('Session Token else ${prefs.getString('userId').toString()}');
    }
  }

  getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userId') == null) {
      getSessionToken();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getId();
    setState(() {
      y = 0;
      isListEmpty = '';
      isLoading = true;
      renterName = '';
      renterEmail = '';
      renterUid = '';
      preparing = '';
      acceptingOrder = '';
      readyToCollect = '';
      collect = '';
      delivered = '';
    });
    getOrders();
    super.initState();
  }

  getOrders() async {
    setState(() {
      y = 1;
    });
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request =
        http.Request('GET', Uri.parse('${apiBaseUrl}restaurant/orders'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      setState(() {
        ordersList = List<RestaurantOrdersModel>.from(json
            .decode(responseData)
            .map((x) => RestaurantOrdersModel.fromJson(x)));

        if (ordersList.isEmpty) {
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
      });

      for (int i = 0; i < ordersList.length; i++) {
        if (ordersList[i].status.toString() == 'Accepting order') {
          setState(() {
            acceptingOrder = 'yes';
          });
        } else if (ordersList[i].status.toString() == 'Preparing your meal') {
          setState(() {
            preparing = 'yes';
          });
        } else if (ordersList[i].status.toString() == 'Ready for collection') {
          setState(() {
            readyToCollect = 'yes';
          });
        } else if (ordersList[i].status.toString() == 'Collected') {
          setState(() {
            collect = 'yes';
          });
        } else if (ordersList[i].status.toString() == 'Delivered') {
          setState(() {
            delivered = 'yes';
          });
        }
      }
    } else if (response.statusCode == 420) {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      await preferences.remove('userEmail').then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });

      Fluttertoast.showToast(
          msg: "Session expires login to continue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // var snackBar = SnackBar(content: Text(''
      //   ,style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.red,
      // );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print(response.reasonPhrase);
      setState(() {
        isListEmpty = 'yes';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (y == 0) {
      getOrders();
    }

    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 5,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
          onWillPop: showExitPopup,
          child: Scaffold(
            backgroundColor: lightButtonGreyColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              // iconTheme: IconThemeData(color: Colors.white),

              actions: [
                IconButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    await prefs.remove('userEmail').then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    });
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),
              ],
              // git remote add origin https://github.com/junaid4jd/honchos_restaurant_app.git
              // git push -f origin main
              backgroundColor: lightRedColor,
              bottom: TabBar(
                isScrollable: true,
                unselectedLabelColor: darkGreyTextColor,
                indicatorColor: Colors.white,
                labelStyle: TextStyle(fontSize: 15),
                onTap: (index) {
                  // Tab index when user select it, it start from zero
                },
                tabs: [
                  Tab(
                    text: 'New',
                  ),
                  Tab(
                    text: 'Preparing Meal',
                  ),
                  Tab(
                    text: 'Ready',
                  ),
                  Tab(
                    text: 'Collected',
                  ),
                  Tab(
                    text: 'Delivered',
                  ),
                ],
              ),
              centerTitle: true,
              title: Text('Restaurant'),
            ),
            body: TabBarView(
              children: [
                isLoading && isListEmpty == ''
                    ? Center(
                        child: CircularProgressIndicator(
                        color: darkRedColor,
                        strokeWidth: 1,
                      ))
                    : (ordersList.isEmpty && isListEmpty == 'yes') ||
                            acceptingOrder == ''
                        ? RefreshIndicator(
                            onRefresh: () => getOrders(),
                            child: new ListView(
                              children: <Widget>[
                                Container(
                                    height: size.height * 0.5,
                                    width: size.width * 0.9,
                                    child: Center(
                                        child: new Text('No Orders Found'))),
                              ],
                            ))
                        : SizedBox(
                            // height: size.height*0.25,
                            child: RefreshIndicator(
                              onRefresh: () => getOrders(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: ordersList.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, index) {
                                  // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                                  //   totalAmount = totalAmount +
                                  // }

                                  return ordersList[index].status.toString() ==
                                          "Accepting order"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                        orderModel:
                                                            ordersList[index],
                                                      )),
                                            ).then((value) {
                                              setState(() {
                                                y = 0;
                                                isListEmpty = 'yes';
                                              });
                                              getOrders();
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Container(
                                                  width: size.width * 0.9,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              lightButtonGreyColor,
                                                          spreadRadius: 2,
                                                          blurRadius: 3)
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: size.height *
                                                              0.08,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                              'assets/images/order.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              height:
                                                                  size.height *
                                                                      0.08,
                                                              width:
                                                                  size.width *
                                                                      0.25,
                                                              // height: 80,
                                                              // width: 80,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.6,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
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
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Order Number: ${ordersList[index].orderNo.toString()}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Items : ${ordersList[index].ordersItems!.length}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString() +
                                                                          ' ' +
                                                                          DateFormat.jm()
                                                                              .format(DateTime.parse(ordersList[index].createdAt.toString()))
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF585858),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              color: Colors.blue),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          ordersList[index]
                                                                              .status
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                          ),
                isLoading && isListEmpty == ''
                    ? Center(
                        child: CircularProgressIndicator(
                        color: darkRedColor,
                        strokeWidth: 1,
                      ))
                    : (ordersList.isEmpty && isListEmpty == 'yes') ||
                            preparing == ''
                        ? RefreshIndicator(
                            onRefresh: () => getOrders(),
                            child: new ListView(
                              children: <Widget>[
                                Container(
                                    height: size.height * 0.5,
                                    width: size.width * 0.9,
                                    child: Center(
                                        child: new Text('No Orders Found'))),
                              ],
                            ))
                        : SizedBox(
                            // height: size.height*0.25,
                            child: RefreshIndicator(
                              onRefresh: () => getOrders(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: ordersList.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, index) {
                                  // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                                  //   totalAmount = totalAmount +
                                  // }

                                  return ordersList[index].status.toString() ==
                                          "Preparing your meal"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                        orderModel:
                                                            ordersList[index],
                                                      )),
                                            ).then((value) {
                                              setState(() {
                                                y = 0;
                                                isListEmpty = 'yes';
                                              });
                                              getOrders();
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Container(
                                                  width: size.width * 0.9,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              lightButtonGreyColor,
                                                          spreadRadius: 2,
                                                          blurRadius: 3)
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: size.height *
                                                              0.08,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                              'assets/images/order.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              height:
                                                                  size.height *
                                                                      0.08,
                                                              width:
                                                                  size.width *
                                                                      0.25,
                                                              // height: 80,
                                                              // width: 80,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.6,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
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
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Order Number: ${ordersList[index].orderNo.toString()}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Items : ${ordersList[index].ordersItems!.length}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString() +
                                                                          ' ' +
                                                                          DateFormat.jm()
                                                                              .format(DateTime.parse(ordersList[index].createdAt.toString()))
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF585858),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              color: Colors.blue),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          ordersList[index]
                                                                              .status
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                          ),
                isLoading && isListEmpty == ''
                    ? Center(
                        child: CircularProgressIndicator(
                        color: darkRedColor,
                        strokeWidth: 1,
                      ))
                    : (ordersList.isEmpty && isListEmpty == 'yes') ||
                            readyToCollect == ''
                        ? RefreshIndicator(
                            onRefresh: () => getOrders(),
                            child: new ListView(
                              children: <Widget>[
                                Container(
                                    height: size.height * 0.5,
                                    width: size.width * 0.9,
                                    child: Center(
                                        child: new Text('No Orders Found'))),
                              ],
                            ))
                        : SizedBox(
                            // height: size.height*0.25,
                            child: RefreshIndicator(
                              onRefresh: () => getOrders(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: ordersList.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, index) {
                                  // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                                  //   totalAmount = totalAmount +
                                  // }

                                  return ordersList[index].status.toString() ==
                                          "Ready for collection"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                        orderModel:
                                                            ordersList[index],
                                                      )),
                                            ).then((value) {
                                              setState(() {
                                                y = 0;
                                                isListEmpty = 'yes';
                                              });
                                              getOrders();
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Container(
                                                  width: size.width * 0.9,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              lightButtonGreyColor,
                                                          spreadRadius: 2,
                                                          blurRadius: 3)
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: size.height *
                                                              0.08,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                              'assets/images/order.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              height:
                                                                  size.height *
                                                                      0.08,
                                                              width:
                                                                  size.width *
                                                                      0.25,
                                                              // height: 80,
                                                              // width: 80,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.6,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
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
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Order Number: ${ordersList[index].orderNo.toString()}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Items : ${ordersList[index].ordersItems!.length}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString() +
                                                                          ' ' +
                                                                          DateFormat.jm()
                                                                              .format(DateTime.parse(ordersList[index].createdAt.toString()))
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF585858),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              color: Colors.blue),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          ordersList[index]
                                                                              .status
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                          ),
                isLoading && isListEmpty == ''
                    ? Center(
                        child: CircularProgressIndicator(
                        color: darkRedColor,
                        strokeWidth: 1,
                      ))
                    : (ordersList.isEmpty && isListEmpty == 'yes') ||
                            collect == ''
                        ? RefreshIndicator(
                            onRefresh: () => getOrders(),
                            child: new ListView(
                              children: <Widget>[
                                Container(
                                    height: size.height * 0.5,
                                    width: size.width * 0.9,
                                    child: Center(
                                        child: new Text('No Orders Found'))),
                              ],
                            ))
                        : SizedBox(
                            // height: size.height*0.25,
                            child: RefreshIndicator(
                              onRefresh: () => getOrders(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: ordersList.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, index) {
                                  // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                                  //   totalAmount = totalAmount +
                                  // }

                                  return ordersList[index].status.toString() ==
                                          "Collected"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                        orderModel:
                                                            ordersList[index],
                                                      )),
                                            ).then((value) {
                                              setState(() {
                                                y = 0;
                                                isListEmpty = 'yes';
                                              });
                                              getOrders();
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Container(
                                                  width: size.width * 0.9,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              lightButtonGreyColor,
                                                          spreadRadius: 2,
                                                          blurRadius: 3)
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: size.height *
                                                              0.08,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                              'assets/images/order.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              height:
                                                                  size.height *
                                                                      0.08,
                                                              width:
                                                                  size.width *
                                                                      0.25,
                                                              // height: 80,
                                                              // width: 80,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.6,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
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
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Order Number: ${ordersList[index].orderNo.toString()}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Items : ${ordersList[index].ordersItems!.length}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString() +
                                                                          ' ' +
                                                                          DateFormat.jm()
                                                                              .format(DateTime.parse(ordersList[index].createdAt.toString()))
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF585858),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              color: Colors.blue),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          ordersList[index]
                                                                              .status
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                          ),
                isLoading && isListEmpty == ''
                    ? Center(
                        child: CircularProgressIndicator(
                        color: darkRedColor,
                        strokeWidth: 1,
                      ))
                    : (ordersList.isEmpty && isListEmpty == 'yes') ||
                            delivered == ''
                        ? RefreshIndicator(
                            onRefresh: () => getOrders(),
                            child: new ListView(
                              children: <Widget>[
                                Container(
                                    height: size.height * 0.5,
                                    width: size.width * 0.9,
                                    child: Center(
                                        child: new Text('No Orders Found'))),
                              ],
                            ))
                        : SizedBox(
                            // height: size.height*0.25,
                            child: RefreshIndicator(
                              onRefresh: () => getOrders(),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: ordersList.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, index) {
                                  // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                                  //   totalAmount = totalAmount +
                                  // }

                                  return ordersList[index].status.toString() ==
                                          "Delivered"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                        orderModel:
                                                            ordersList[index],
                                                      )),
                                            ).then((value) {
                                              setState(() {
                                                isListEmpty = 'yes';
                                              });
                                              getOrders();
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Container(
                                                  width: size.width * 0.9,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color:
                                                              lightButtonGreyColor,
                                                          spreadRadius: 2,
                                                          blurRadius: 3)
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: size.height *
                                                              0.08,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Image.asset(
                                                              'assets/images/order.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              height:
                                                                  size.height *
                                                                      0.08,
                                                              width:
                                                                  size.width *
                                                                      0.25,
                                                              // height: 80,
                                                              // width: 80,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.6,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
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
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Order Number: ${ordersList[index].orderNo.toString()}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Items : ${ordersList[index].ordersItems!.length}',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString() +
                                                                          ' ' +
                                                                          DateFormat.jm()
                                                                              .format(DateTime.parse(ordersList[index].createdAt.toString()))
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF585858),
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),

                                                                    // Text('\$30.99',
                                                                    //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                              color: Colors.green),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          ordersList[index]
                                                                              .status
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit the App?'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },

                //return true when click on "Yes"
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    //if showDialouge had returned null, then return false
  }
}
