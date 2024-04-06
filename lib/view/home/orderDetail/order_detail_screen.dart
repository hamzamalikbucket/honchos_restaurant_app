import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/orderModel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as dp;
import 'package:geolocator/geolocator.dart';
import 'package:honchos_restaurant_app/model/order_model.dart';
import 'package:honchos_restaurant_app/model/session_model.dart';
import 'package:honchos_restaurant_app/view/chooseDriver/choose_driver_screen.dart';
import 'package:honchos_restaurant_app/view/home/home_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/restaurant_model.dart';


class OrderDetailScreen extends StatefulWidget {
  final RestaurantOrdersModel orderModel;
  const OrderDetailScreen({Key? key, required this.orderModel}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int total = 0;
  int subTotal = 0;
  int addOnsTotal = 0;
  List<RestaurantModel> restaurantList = [];
  String distance = '', address = '', restaurantID = '';
  double distanceInKm = 0.0;
  bool isLoading = false;


  totalAmount() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('userId') != null) {
      setState(() {
        restaurantID = prefs.getString('userId').toString();
      });
      print(restaurantID + ' userId');
    }


    for(int i=0; i<widget.orderModel.ordersItems!.length; i++) {



      if(widget.orderModel.ordersItems![i].addon!.isNotEmpty){
        for(int j=0; j<widget.orderModel.ordersItems![i].addon!.length; j++) {

          if(widget.orderModel.ordersItems![i].addon![j].addon != null) {
            setState(() {
              addOnsTotal = addOnsTotal + int.parse(widget.orderModel.ordersItems![i].addon![j].addon!.price.toString());
            });
          }
          else {
            break;
          }


        }

      }

      setState(() {
        subTotal = subTotal + (int.parse(widget.orderModel.ordersItems![i].payment.toString()) * int.parse(widget.orderModel.ordersItems![i].quantity.toString()));
      });

      if(widget.orderModel.ordersItems!.length-1 == i) {
        setState(() {
          total = subTotal + addOnsTotal;
        });
      }




    }

    // for(int i=0; i<widget.orderModel.ordersItems!.length; i++) {
    //
    //   setState(() {
    //     total = total + (int.parse(widget.orderModel.ordersItems![i].payment.toString()) * int.parse(widget.orderModel.ordersItems![i].quantity.toString()));
    //   });
    //
    // }

  }





  updateStatus(String status) async {
    print('This is status $status');

    var headers = {

      'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${apiBaseUrl}restaurant/order_update_status/${widget.orderModel.id}'));
    request.fields.addAll({
      'status': status,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // setState(() {
      //   assigning = false;
      // });

      Fluttertoast.showToast(
          msg: "Status successfully updated to $status",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RestaurantHomeScreen()),
      ).then((value) {

        // var snackBar = SnackBar(content: Text('Status successfully changed to $status ',style: TextStyle(color: Colors.white),),
        //   backgroundColor: Colors.green,);
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);

      });



    }
    else {
      print(response.reasonPhrase);

      // setState(() {
      //   assigning = false;
      // });

      Fluttertoast.showToast(
          msg: "Something went wrong. Check your internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      // var snackBar = SnackBar(content: Text('Something went wrong. Check your internet',style: TextStyle(color: Colors.white),),
      //   backgroundColor: Colors.green,);
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }


  }







  @override
  void initState() {
    // TODO: implement initState
   // _getAddressFromLatLng();
    print(widget.orderModel.status.toString());
    setState(() {
      distance = '';
    });

    totalAmount();



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
        title: Text(
            'Order Detail',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:1)));
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

            Container(
              width: size.width*0.8,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height*0.01,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status ',
                          style: TextStyle(color: Colors.black,
                              fontSize: 14,fontWeight: FontWeight.w600),),


                        Container(
                          decoration: BoxDecoration(color:

                          widget.orderModel.status.toString() == 'Accepting order' || widget.orderModel.status.toString() == 'Pending' ? Colors.blue :
                          widget.orderModel.status.toString() == 'Ready for collection' ? Colors.teal :
                          widget.orderModel.status.toString() == 'Collected' ? Colors.deepOrangeAccent :
                          widget.orderModel.status.toString() == 'Delivered' ? Colors.green :
                          Colors.blue
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(

                              widget.orderModel.status.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 12,fontWeight: FontWeight.bold),),
                          ),
                        ),


                      ],),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(widget.orderModel.status.toString(),
                    //       style: TextStyle(color: Colors.blue,
                    //           fontSize: 14,fontWeight: FontWeight.bold),),
                    //
                    //   ],),

                    SizedBox(
                      height: size.height*0.01,
                    ),


                  ],
                ),
              ),
            ),
            widget.orderModel.deliveryType == null ? Container() :
            Padding(
              padding: const EdgeInsets.only(top: 8,),
              child: Container(
                width: size.width*0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: lightButtonGreyColor,
                        spreadRadius: 2,
                        blurRadius: 3
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [

                      Container(
                        width: size.width*0.8,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: size.height*0.01,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Delivery ',
                                    style: TextStyle(color: Colors.black,
                                        fontSize: 14,fontWeight: FontWeight.w600),),

                                  Container(
                                    decoration: BoxDecoration(
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.orderModel.deliveryType.toString(),
                                        style: TextStyle(color: Colors.blue,
                                            fontSize: 15,fontWeight: FontWeight.bold),),
                                    ),
                                  ),

                                ],),

                              SizedBox(
                                height: size.height*0.01,
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
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
                // );
              },
              child: Center(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.8,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Order Number : ${widget.orderModel.orderNo!.toString()}',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),
                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat.yMMMMd().format(DateTime.parse(widget.orderModel.createdAt.toString())).toString()
                                              + ' '  +DateFormat.jm().format(DateTime.parse(widget.orderModel.createdAt.toString())).toString()

                                          ,
                                          style: TextStyle(color: Color(0xFF585858),
                                              fontSize: 13,fontWeight: FontWeight.w500),),


                                        // Text('\$30.99',
                                        //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),

                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
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

                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.8,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Delivered To ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w600),),

                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                        //
                                        //     // height: 80,
                                        //     // width: 80,
                                        //   ),
                                        //),
                                      ],),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${widget.orderModel.user!.name.toString()}\n${widget.orderModel.user!.email.toString()}\n${widget.orderModel.user!.phoneNo.toString()} ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height*0.01,
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

                  widget.orderModel.address != null ?
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.8,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Delivery Address ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w600),),

                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                        //
                                        //     // height: 80,
                                        //     // width: 80,
                                        //   ),
                                        //),
                                      ],),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: size.width*0.7,
                                          child: Text(widget.orderModel.address.toString(),
                                            style: TextStyle(color: Colors.black,
                                                fontSize: 14,fontWeight: FontWeight.w500),),
                                        ),

                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
                                    ),


                                  ],
                                ),
                              ),
                            ),




                          ],
                        ),
                      ),
                    ),
                  ) : Container(),

                  widget.orderModel.ordersItems!.isEmpty  ? Container(
                    child: Text('No order item found',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),),
                  ) :
                  SizedBox(
                    // height: size.height*0.25,
                    width: size.width*0.9,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.orderModel.ordersItems!.length,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context,index
                          ) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            // width: size.width*0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: lightButtonGreyColor,
                                    spreadRadius: 2,
                                    blurRadius: 3
                                )
                              ],
                            ),
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8,),
                                child: Container(
                                  // width: size.width*0.9,
                                  // decoration: BoxDecoration(
                                  //   color: Colors.white,
                                  //   borderRadius: BorderRadius.circular(10),
                                  //   boxShadow: [
                                  //     BoxShadow(
                                  //         color: lightButtonGreyColor,
                                  //         spreadRadius: 2,
                                  //         blurRadius: 3
                                  //     )
                                  //   ],
                                  // ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Container(
                                          decoration: BoxDecoration(
                                            color: lightButtonGreyColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              height: size.height*0.07,
                                              width: size.width*0.2,
                                              fit: BoxFit.cover,
                                              imageUrl: imageConstUrlProduct+widget.orderModel.ordersItems![index].product!.image.toString(),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        ),

                                        Container(
                                          // height: size.height*0.07,
                                          width: size.width*0.65,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: size.width*0.5,
                                                      child: Text(widget.orderModel.ordersItems![index].product!.name.toString(),
                                                        style: TextStyle(color: Color(0xFF585858),
                                                            fontSize: 14,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                                    ),

                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Quantity : ' + widget.orderModel.ordersItems![index].quantity.toString(),
                                                      //quantity.toString(),
                                                      style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
                                                    // widget.order.ordersItems![index].product!.price.toString()
                                                    Text('R '+ '${
                                                        int.parse(widget.orderModel.ordersItems![index].product!.price.toString())*int.parse(widget.orderModel.ordersItems![index].quantity.toString())
                                                    }',
                                                      style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height*0.01,
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
                              SizedBox(
                                height: size.height*0.01,
                              ),
                              widget.orderModel.ordersItems![index].addon == null
                                  ||  widget.orderModel.ordersItems![index].addon.toString() == "[]"
                                 // ||  widget.orderModel.ordersItems![index].addon.toString() == "[Instance of 'AddonElement']"
                                  ? Container() :
                              Container(
                                width: size.width*0.9,
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(left: 8,),
                                child: Text('Addons',
                                  style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                              ),
                              SizedBox(height: 4,),

                              widget.orderModel.ordersItems![index].addon != null ?
                              Container(
                                width: size.width*0.9,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.orderModel.ordersItems![index].addon!.length,
                                  scrollDirection: Axis.vertical,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context,addIndex
                                      ) {

                                    return
                                      widget.orderModel.ordersItems![index].addon![addIndex].addon != null ?
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8,right: 20,bottom: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: size.width*0.6,
                                              child: Text(

                                                widget.orderModel.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '2' ?
                                                widget.orderModel.ordersItems![index].addon![addIndex].addon!.name.toString() + ' (Chips)' :
                                                widget.orderModel.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '4' ?
                                                widget.orderModel.ordersItems![index].addon![addIndex].addon!.name.toString() + ' (Flavour)' :
                                                widget.orderModel.ordersItems![index].addon![addIndex].addon!.name.toString()
                                                ,
                                                //quantity.toString(),
                                                style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                                            ),
                                            // widget.order.ordersItems![index].product!.price.toString()
                                            widget.orderModel.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '4' ||
                                                widget.orderModel.ordersItems![index].addon![addIndex].addon!.categoryId.toString() == '1'
                                                ? Container() :
                                            Text('R '+widget.orderModel.ordersItems![index].addon![addIndex].addon!.price.toString(),
                                              style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w500),),
                                          ],
                                        ),
                                      ) : Container();
                                  },
                                ),
                              ) : Container(),

                              SizedBox(
                                height: size.height*0.01,
                              ),
                              widget.orderModel.ordersItems![index].specialInstruction.toString() == ''
                                  || widget.orderModel.ordersItems![index].specialInstruction == null
                                  ? Container() :
                              Column(children: [
                                Container(
                                  width: size.width*0.95,
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 8,),
                                  child: Text('Special Instruction',
                                    style: TextStyle(color: darkRedColor, fontSize: 12,fontWeight: FontWeight.w600),),
                                ),
                                SizedBox(height: 4,),
                                Container(
                                  width: size.width*0.95,
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 8,),
                                  child: Text(widget.orderModel.ordersItems![index].specialInstruction.toString(),
                                    style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,maxLines: 4,),
                                ),
                                SizedBox(height: 8,),
                              ],),

                            ],),
                          ),
                        );
                      },

                    ),
                  ),
                  // widget.orderModel.ordersItems!.isEmpty  ? Container(
                  //   child: Text('No order item found',
                  //     style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w500),),
                  // ) :
                  // SizedBox(
                  //   // height: size.height*0.25,
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount: widget.orderModel.ordersItems!.length,
                  //     scrollDirection: Axis.vertical,
                  //     physics: NeverScrollableScrollPhysics(),
                  //     itemBuilder: (BuildContext context,index
                  //         ) {
                  //       return Column(children: [
                  //         Padding(
                  //           padding: const EdgeInsets.only(top: 16,),
                  //           child: Container(
                  //             width: size.width*0.9,
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(10),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                     color: lightButtonGreyColor,
                  //                     spreadRadius: 2,
                  //                     blurRadius: 3
                  //                 )
                  //               ],
                  //             ),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(0.0),
                  //               child: Row(
                  //                 children: [
                  //
                  //                   Container(
                  //                     decoration: BoxDecoration(
                  //                       color: lightButtonGreyColor,
                  //                       borderRadius: BorderRadius.circular(10),
                  //                     ),
                  //                     child: ClipRRect(
                  //                       borderRadius: BorderRadius.circular(10),
                  //                       child: CachedNetworkImage(
                  //                         height: size.height*0.07,
                  //                         width: size.width*0.2,
                  //                         fit: BoxFit.cover,
                  //                         imageUrl: imageConstUrlProduct+widget.orderModel.ordersItems![index].product!.image.toString(),
                  //                         errorWidget: (context, url, error) => Icon(Icons.error),
                  //                       ),
                  //                     ),
                  //                   ),
                  //
                  //                   Container(
                  //                     height: size.height*0.07,
                  //                     width: size.width*0.6,
                  //                     child: Padding(
                  //                       padding: const EdgeInsets.only(left: 8),
                  //                       child: Column(
                  //                         crossAxisAlignment: CrossAxisAlignment.start,
                  //                         children: [
                  //                           SizedBox(
                  //                             height: size.height*0.01,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(widget.orderModel.ordersItems![index].product!.name.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858),
                  //                                     fontSize: 14,fontWeight: FontWeight.w500),),
                  //
                  //                             ],
                  //                           ),
                  //                           SizedBox(
                  //                             height: size.height*0.01,
                  //                           ),
                  //                           Row(
                  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                             children: [
                  //                               Text(
                  //                                 'Quantity : ' + widget.orderModel.ordersItems![index].quantity.toString(),
                  //                                 //quantity.toString(),
                  //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
                  //                              // widget.order.ordersItems![index].product!.price.toString()
                  //                               Text('ZAR '+ '${
                  //                               int.parse(widget.orderModel.ordersItems![index].product!.price.toString())*int.parse(widget.orderModel.ordersItems![index].quantity.toString())
                  //                               }',
                  //                                 style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                  //                             ],
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //
                  //       ],);
                  //     },
                  //
                  //   ),
                  // ),


                  SizedBox(
                    height: size.height*0.01,
                  ),
                  subTotal == 0 ? Container() :
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,bottom: 8,top: 8),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.82,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Subtotal : ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 13,fontWeight: FontWeight.w500),),
                                        Text('R '+subTotal.toString(),
                                          style: TextStyle(color: Colors.red,
                                              fontSize: 12,fontWeight: FontWeight.w600),),
                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                        //
                                        //     // height: 80,
                                        //     // width: 80,
                                        //   ),
                                        //),
                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
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
                  SizedBox(
                    height: size.height*0.01,
                  ),
                  addOnsTotal == 0 ? Container() :
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,bottom: 8,top: 8),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.82,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),
                                    addOnsTotal.toString() == '0' ? Container() :
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Addons Total : ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 13,fontWeight: FontWeight.w500),),
                                        Text('R '+addOnsTotal.toString(),
                                          style: TextStyle(color: Colors.red,
                                              fontSize: 12,fontWeight: FontWeight.w600),),
                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                        //
                                        //     // height: 80,
                                        //     // width: 80,
                                        //   ),
                                        //),
                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
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
                  SizedBox(
                    height: size.height*0.01,
                  ),

                  widget.orderModel.deliveryFee == null ||   widget.orderModel.deliveryFee.toString() == '0'
                      || widget.orderModel.deliveryType.toString() == 'Self'
                      ? Container() :
                  Column(children: [
                    SizedBox(
                      height: size.height*0.01,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 0,),
                      child: Container(
                        width: size.width*0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: lightButtonGreyColor,
                                spreadRadius: 2,
                                blurRadius: 3
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [

                              Container(
                                width: size.width*0.82,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: size.height*0.01,
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Delivery Fee : ',
                                            style: TextStyle(color: Colors.black,
                                                fontSize: 14,fontWeight: FontWeight.w500),),
                                          Text('R '+widget.orderModel.deliveryFee.toString(),
                                            style: TextStyle(color: Colors.red,
                                                fontSize: 12,fontWeight: FontWeight.w600),),
                                          // SizedBox(
                                          //   height: 20,
                                          //   width: 20,
                                          //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                          //
                                          //     // height: 80,
                                          //     // width: 80,
                                          //   ),
                                          //),
                                        ],),

                                      SizedBox(
                                        height: size.height*0.01,
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
                  ],) ,

                  SizedBox(
                    height: size.height*0.01,
                  ),

                  widget.orderModel.deliveryFee == null ||   widget.orderModel.deliveryFee.toString() == '0'
                      || widget.orderModel.deliveryType.toString() == 'Self'
                      ?
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.82,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Order Total : ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),
                                        Text('R '+total.toString(),
                                          style: TextStyle(color: Colors.red,
                                              fontSize: 12,fontWeight: FontWeight.w600),),
                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                        //
                                        //     // height: 80,
                                        //     // width: 80,
                                        //   ),
                                        //),
                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                  ],
                                ),
                              ),
                            ),




                          ],
                        ),
                      ),
                    ),
                  ) :
                  Padding(
                    padding: const EdgeInsets.only(top: 8,),
                    child: Container(
                      width: size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: lightButtonGreyColor,
                              spreadRadius: 2,
                              blurRadius: 3
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [

                            Container(
                              width: size.width*0.82,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Order Total : ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),
                                        Text('R ${int.parse(total.toString()) + int.parse(widget.orderModel.deliveryFee.toString())}',
                                          style: TextStyle(color: Colors.red,
                                              fontSize: 12,fontWeight: FontWeight.w600),),
                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                        //
                                        //     // height: 80,
                                        //     // width: 80,
                                        //   ),
                                        //),
                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
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

                ],),
              ),
            ),



            SizedBox(
              height: size.height*0.05,
            ),
            isLoading ? Center(child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            )) :

            (widget.orderModel.status.toString() == 'Collected' || widget.orderModel.status.toString() == 'Delivered')  ? Container() :
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
                    onPressed: () {

                      if(widget.orderModel.deliveryType.toString() == 'Self') {

                        if(widget.orderModel.status.toString() == 'Accepting order') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Preparing your meal');
                        }

                        else if(widget.orderModel.status.toString() == 'Preparing your meal') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Ready for collection');
                        } else if(widget.orderModel.status.toString() == 'Ready for collection') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Collected');
                        }


                      }
                      else if(widget.orderModel.deliveryType.toString() == 'Driver') {

                        if(widget.orderModel.status.toString() == 'Accepting order') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Preparing your meal');
                        } else if(widget.orderModel.status.toString() == 'Preparing your meal') {

                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChooseDriverScreen(orderModel: widget.orderModel,resId: restaurantID,)));
                          // setState(() {
                          //   isLoading = true;
                          // });
                          // updateStatus('Ready for collection');
                        }



                      }
                      else {
                        var snackBar = SnackBar(content: Text('Its an old order with no delivery type'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.green,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }











                    }, child: Text(
                    widget.orderModel.status.toString() == 'Accepting order' ? 'Accept' :
                    widget.orderModel.status.toString() == 'Preparing your meal' && widget.orderModel.deliveryType.toString() == 'Self'  ? 'Ready' :
                    widget.orderModel.status.toString() == 'Ready for collection' && widget.orderModel.deliveryType.toString() == 'Self'  ? 'Collect' :
                    widget.orderModel.status.toString() == 'Preparing your meal' && widget.orderModel.deliveryType.toString() == 'Driver'  ? 'Assign Driver' :




                    'Submit'
                    , style: buttonStyle)),
              ),
            ),

            SizedBox(
              height: size.height*0.05,
            ),

        ],),
      ),

    );
  }
}
