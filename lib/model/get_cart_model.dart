// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:honchos_restaurant_app/constants.dart';
// import 'package:honchos_restaurant_app/model/bannerModel.dart';
// import 'package:honchos_restaurant_app/model/cartModel.dart';
// import 'package:honchos_restaurant_app/model/restaurant_category_product_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AddToCartController extends GetxController {
//   List<CartModel> productsList = [];
//   List<BannerModel> bannerList = [];
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<CategoriesProductsModel> serachProductsList = [];
//   var cartItems = 0.obs;
//   var cartTotal = 0.obs;
//   int cartItemsTotal = 0;
//
//   // void addProduct(Products product) {
//   //   productsList.add(product);
//   //   update();
//   // }
//
//   void clearCart() {
//     cartItems.value = 0;
//     cartTotal.value = 0;
//     update();
//   }
//
//   void fetchCartItems() async {
//     int total = 0 ;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//
//     try {
//
//       var headers = {
//         // 'Content-Type': 'application/json',
//         'Cookie': 'restaurant_session=$cookie',
//         'Content-type': 'application/json',
//         'Accept': 'application/json'
//       };
//
//       var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/cart'));
//
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         print('get Cart');
//         productsList = List<CartModel>.from(json.decode(responseData).map((x) => CartModel.fromJson(x)));
//         print(productsList.length.toString() +' cart List Length');
//         cartItems.value = productsList.length;
//         print( cartItems.value.toString() +' cart 2 List Length');
//         //  cartItemsTotal = productsList.length;
//         if(prefs.getString('userId') != null) {
//
//           for(int i=0;i<productsList.length;i++) {
//             if(productsList[i].userId.toString() == prefs.getString('userId') && productsList[i].status == 'Active') {
//               total = total + ((int.parse(productsList[i].product!.price.toString())) * (int.parse(productsList[i].quantity.toString())));
//               // ((int.parse(productsList[i].product!.price.toString())) * (int.parse(productsList[i].quantity.toString())))
//               print(total.toString() + ' This is $i');
//               if(i==productsList.length-1) {
//                 print(total.toString() + ' This is $i and final');
//                 cartTotal.value = total;
//                 prefs.setString('cartTotal', total.toString());
//                 update();
//               }
//               update();
//               // cartItemsTotal = total + ((int.parse(productsList[i].product!.price.toString())) * (int.parse(productsList[i].quantity.toString())));
//               // cartTotal.value = cartItemsTotal;
//
//             }
//           }
//         } else {
//           print( 'User id is null');
//         }
//         update();
//
//       }
//       else if (response.statusCode == 302) {
//
//       }
//       else {
//
//       }
//       update();
//
//     } catch(e) {
//
//       print( 'response after Hello getProducts' + e.toString());
//
//       if(e.toString() == 'Bad state: Response has no Location header for redirect') {
//        print('Bad state: Response has no Location header for redirect');
//
//       } else if (e.toString() == 'Connection timed out') {
//        print('timed out');
//       }
//
//     }
//
//
//
//
//   }
//
//
//   void getBanners() async {
//     print('we are in banners');
//     try {
//
//       var headers = {
//         'Cookie': 'restaurant_session=$cookie'
//       };
//       var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/banners'));
//
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//
//
//         bannerList = List<BannerModel>.from(json.decode(responseData).map((x) => BannerModel.fromJson(x)));
//
//
//         //print(await response.stream.bytesToString());
//       }
//       else if (response.statusCode == 302) {
//         print('we are in empty response.statusCode == 302');
//
//       }
//       else {
//         print('we are in empty else');
//
//         print(response.reasonPhrase.toString() + ' Hello error');
//
//       }
//
//
//   } catch(e) {
//   print( 'response after Hello getProducts' + e.toString());
//
//
//   }
//
//
//
//
//
//   }
//
//
//   void getProducts() async {
//     // setState(() {
//     //   y=1;
//     //   isLoading = true;
//     //   categoriesProductsList.clear();
//     // });
//     print( ' Hello getProducts');
//
//     try{
//       var headers = {
//         'Content-Type': 'application/json',
//         'Cookie': 'restaurant_session=$cookie'
//       };
//
//       var request = http.Request('GET', Uri.parse('https://restaurant.wettlanoneinc.com/api/products'));
//
//       request.headers.addAll(headers);
//       print( 'response before Hello getProducts');
//       http.StreamedResponse response = await request.send();
//       print( 'response after Hello getProducts');
//       //print(response.statusCode.toString() + ' This is status code');
//       // final data = json.decode(responseData);
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//
//           serachProductsList = List<CategoriesProductsModel>.from(json.decode(responseData).map((x) => CategoriesProductsModel.fromJson(x)));
//
//       }
//       else if (response.statusCode == 302) {
//         print('we are in empty response.statusCode == 302');
//
//       }
//       else {
//         print('we are in empty else');
//
//         print(response.reasonPhrase.toString() + ' Hello error');
//
//       }
//     } catch(e) {
//       print( 'response after Hello getProducts' + e.toString());
//
//
//     }
//
//
//     // if(categoriesProductsList.isEmpty && restaurantCategoriesList.isEmpty && isLoading == true && isLoadingC ==true) {
//     //   SharedPreferences preferences = await SharedPreferences.getInstance();
//     //   await preferences.clear().then((value){
//     //     Navigator.push(
//     //       context,
//     //       MaterialPageRoute(builder: (context) => LoginScreen()),
//     //     );
//     //   });
//     // }
//
//   }
//
// // del(int index) {
// //   productsList.removeAt(index);
// //   update();
// // }
// }