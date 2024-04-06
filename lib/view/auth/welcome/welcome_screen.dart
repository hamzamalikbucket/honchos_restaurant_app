import 'package:honchos_restaurant_app/constants.dart';

import 'package:flutter/material.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: new BoxDecoration(
          color: Colors.white,
          // gradient: LinearGradient(begin: Alignment.topRight,
          //   end: Alignment.bottomLeft,
          //   stops: [
          //     0.1,
          //     0.9
          //   ], colors: [
          //     lightRedColor,
          //     darkRedColor
          //   ],
          // ),
        ),
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                height: 120,
                width: 180,
                child: Image.asset('assets/images/logo_trans.png', fit: BoxFit.scaleDown,
                  height: 120,
                  width: 180,),
              ),
            ),

            Container(
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Container(

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
                          minimumSize: MaterialStateProperty.all(Size(size.width*0.8, 50)),
                          backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                          // elevation: MaterialStateProperty.all(3),
                          shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                        ),

                        onPressed: (){
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => LoginScreen()),
                          // );
                        }, child: Text('Login', style: buttonStyle)),
                  ),

                  SizedBox(
                    height: size.height*0.025,
                  ),

                  Container(

                    decoration: BoxDecoration(
                      // boxShadow: [
                      //   BoxShadow(
                      //       color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                      // ],
                      border: Border.all(color: Colors.black,width: 0.5),
                      color: Colors.white,
                      // color: Colors.deepPurple.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all(Size(size.width*0.8, 50)),
                          backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                          // elevation: MaterialStateProperty.all(3),
                          shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                        ),

                        onPressed: (){
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => SignUpScreen()),
                          // );

                        }, child: Text('Sign up', style: buttonStyle.copyWith(color: Colors.black))),
                  ),

                  SizedBox(
                    height: size.height*0.08,
                  ),


                  SizedBox(
                    height: size.height*0.025,
                  ),
                ],
              ),
            ),

          ],),


      ),
    );
  }
}
