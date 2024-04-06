import 'dart:async';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/get_cart_model.dart';
import 'package:honchos_restaurant_app/view/auth/login/login_screen.dart';
import 'package:honchos_restaurant_app/view/auth/phone_login/phone_login_screen.dart';
import 'package:honchos_restaurant_app/view/auth/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:mec/constants.dart';



class SplashScreen extends StatefulWidget {
  //final Color backgroundColor = Colors.white;
  //final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  const SplashScreen({Key? key, }) : super(key: key);


  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 1; // delay for 5 seconds
  //final cartController = Get.put(AddToCartController());
  @override
  void initState() {
    super.initState();
    // setState(() {
    //   cartController.getProducts();
    // });
    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SignInScreen() // WelcomeScreen()
   ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
     // backgroundColor: primaryColor,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: new BoxDecoration(

          gradient: LinearGradient(begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
            0.1,
            0.9
          ], colors: [
            lightRedColor,
            darkRedColor
          ],
          ),
        ),
        child: Image.asset('assets/images/logo_splash.png', fit: BoxFit.scaleDown,),
      ),
    );
  }
}
