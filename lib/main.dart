import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/view/chooseRestaurant/choose_restaurant_screen.dart';
import 'package:honchos_restaurant_app/view/dashboard/dashboard_screen.dart';
import 'package:honchos_restaurant_app/view/enableLocation/enable_location_screen.dart';
import 'package:honchos_restaurant_app/view/home/home_screen.dart';
import 'package:honchos_restaurant_app/view/payment/payfast_screen.dart';
import 'package:honchos_restaurant_app/view/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(apiKey: 'AIzaSyBoLcq9ljSXzLeXmO1AQPEdSriWFkvhpVQ',
          appId: '1:1011606518727:android:764f48b74e30448af937e2',
          messagingSenderId: '1011606518727',
          projectId: 'food-order-flutter-868a3')
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  String? phone, email, uid, userType;
  @override
  void initState() {
    // TODO: implement initState
    // getData();
    setState(() {
      phone = '';
      email = '';
    });
    getUserData();
    // initPlatformState();

    super.initState();
  }
  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();



    if( prefs.getString('userEmail') != null) {

      setState(() {
        phone = prefs.getString('userPhone');
        email = prefs.getString('userEmail');
      });

    }

    print("MAin user data");
    print(phone);
    print(email);


  }

  Future _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: darkRedColor,
      ),
      home:email != '' ? RestaurantHomeScreen() :
      SplashScreen(),
    );
  }
}

