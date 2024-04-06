import 'dart:convert';

import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/view/verificationComplete/verification_complete_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpPhoneScreen extends StatefulWidget {
  final String email;
  final String token;
  const VerifyOtpPhoneScreen({Key? key, required this.email,required this.token}) : super(key: key);

  @override
  _VerifyOtpPhoneScreenState createState() => _VerifyOtpPhoneScreenState();
}

class _VerifyOtpPhoneScreenState extends State<VerifyOtpPhoneScreen> {
 final TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  String currentText = "",emailApi = "",tokenApi = "";
  int code = 0;
  final formKey = GlobalKey<FormState>();


  bool isLoading = false;
  bool resend = false;



 void verifyCode() async {

   print(currentText.toString() + ' Current text') ;
   print(currentText.toString() + ' Current text\n' + widget.token.toString() +' token text\n' + emailApi + ' Email text\n') ;



   var headers = {

   'Cookie': 'restaurant_session=$cookie'
   };
   var request = http.MultipartRequest('POST', Uri.parse('${apiBaseUrl}restaurant_otp_verified'));
   request.fields.addAll({
     'otp': currentText
   });

   request.headers.addAll(headers);

   http.StreamedResponse response = await request.send();

   if (response.statusCode == 200) {
     print(response.reasonPhrase);
     setState(() {isLoading = false;});
     var snackBar = SnackBar(content: Text('OTP Verified'
       ,style: TextStyle(color: Colors.white),),
       backgroundColor: Colors.green,
     );
     ScaffoldMessenger.of(context).showSnackBar(snackBar);
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => VerificationCompleteScreen()),
     );
   }
   else if (response.statusCode == 302) {
     print(response.reasonPhrase);
     setState(() {
       isLoading = false;
     });
     var snackBar = SnackBar(content: Text('OTP not verified'
       ,style: TextStyle(color: Colors.white),),
       backgroundColor: Colors.red,
     );
     ScaffoldMessenger.of(context).showSnackBar(snackBar);
   }
   else {
     setState(() {
       isLoading = false;
     });
     print(response.reasonPhrase);
     var snackBar = SnackBar(content: Text('Something went wrong'
       ,style: TextStyle(color: Colors.white),),
       backgroundColor: Colors.red,
     );
     ScaffoldMessenger.of(context).showSnackBar(snackBar);
   }




   // var headers = {
   //   'Content-Type': 'application/json',
   //   'Cookie': 'restaurant_session=$cookie'
   // };
   // var request = http.MultipartRequest('POST', Uri.parse('http://restaurant.wettlanoneinc.com/api/driver_otp_verified'));
   // request.fields.addAll({
   //   'otp': currentText.toString(),
   // });
   // request.headers.addAll(headers);
   //
   // http.StreamedResponse response = await request.send();
   // // final responseData = await response.stream.bytesToString();
   // // // final data = json.decode(responseData);
   // if (response.statusCode == 200) {
   //   print(response.reasonPhrase);
   //   setState(() {isLoading = false;});
   //   var snackBar = SnackBar(content: Text('OTP Verified'
   //     ,style: TextStyle(color: Colors.white),),
   //     backgroundColor: Colors.green,
   //   );
   //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
   //   Navigator.push(
   //     context,
   //     MaterialPageRoute(builder: (context) => VerificationCompleteScreen()),
   //   );
   // }
   // else if (response.statusCode == 302) {
   //   print(response.reasonPhrase);
   //   setState(() {
   //     isLoading = false;
   //   });
   //   var snackBar = SnackBar(content: Text('OTP not verified'
   //     ,style: TextStyle(color: Colors.white),),
   //     backgroundColor: Colors.red,
   //   );
   //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
   // }
   // else {
   //   print(response.reasonPhrase);
   //   var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
   //     ,style: TextStyle(color: Colors.white),),
   //     backgroundColor: Colors.red,
   //   );
   //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
   // }

 }




 // void resendCode() async {
 //   var headers = {
 //     'Content-Type': 'application/json',
 //     'Cookie': 'restaurant_session=$cookie'
 //   };
 //   var request = http.Request('POST', Uri.parse('http://restaurant.wettlanoneinc.com/api/forgot_password?email=${widget.email.toString()}'));
 //
 //   request.headers.addAll(headers);
 //
 //   http.StreamedResponse response = await request.send();
 //   final responseData = await response.stream.bytesToString();
 //   final data = json.decode(responseData);
 //   if (response.statusCode == 200) {
 //     // pageModel = PageModel.fromJson(json.decode(responseData));
 //
 //     setState(() {
 //       resend  = false;
 //     });
 //
 //     var snackBar = SnackBar(content: Text(data['message'].toString()
 //       ,style: TextStyle(color: Colors.white),),
 //       backgroundColor: Colors.green,
 //     );
 //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
 //
 //
 //     // print(await response.stream.bytesToString());
 //   }
 //   else if (response.statusCode == 302) {
 //     setState(() {
 //       resend  = false;
 //     });
 //     var snackBar = SnackBar(content: Text(
 //       data['mesage'].toString() == 'null' ? data['message'].toString() : data['mesage'].toString()
 //       ,style: TextStyle(color: Colors.white),),
 //       backgroundColor: Colors.red,
 //     );
 //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
 //   }
 //   else {
 //     print(response.reasonPhrase);
 //     var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
 //       ,style: TextStyle(color: Colors.white),),
 //       backgroundColor: Colors.red,
 //     );
 //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
 //   }
 //
 // }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoading = false;
      resend  = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // bool isLoading = false;
    // setState(() {
    //   isLoading = false;
    //   resend  = false;
    // });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height*0.12,
            ),

            Center(
                child: Text('Verify OTP', style: TextStyle(color: Color(0xFF585858), fontSize: 25,fontWeight: FontWeight.bold),)
            ),

            SizedBox(
              height: size.height*0.025,
            ),

            Container(
              width: size.width*0.8,
              child: Center(
                  child: Text('Enter the 4 digit code received on your entered email ${widget.email.toString()}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkGreyTextColor, fontSize: 14,),)
              ),
            ),

            SizedBox(
              height: size.height*0.025,
            ),


            Center(
              child: SizedBox(
                // height: size.height*0.5,
                width: size.width*0.8,
                child: Image.asset('assets/images/otp_screen.png', fit: BoxFit.scaleDown,
                  // height: size.height*0.5,
                  width: size.width*0.8,
                  // height: 80,
                  // width: 80,
                ),
              ),
            ),

            SizedBox(
              height: size.height*0.03,
            ),



            Form(
              key: formKey,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 30),
                  child: PinCodeTextField(
                    backgroundColor: Colors.white,
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 4,
                    obscureText: true,
                    obscuringCharacter: '*',
                    // obscuringWidget: const FlutterLogo(
                    //   size: 24,
                    // ),
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 3) {
                        return "I'm from validator";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(

                      selectedColor: Colors.black,

                      activeColor: Colors.white,
                      selectedFillColor: Colors.white,
                      shape: PinCodeFieldShape.box,
                      inactiveFillColor: Colors.white,
                      inactiveColor: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                      borderWidth: 1,
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                  //  errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (value) {
                      debugPrint("Completed");
                      setState(() {
                        currentText = value;
                      });
                    },
                    // onTap: () {
                    //   print("Pressed");
                    // },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  )),
            ),





            SizedBox(
              height: size.height*0.03,
            ),

            resend ? Center(child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            )) :
            Column(children: [

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
                  setState(() {
                    resend = true;
                  });

                  //resendCode();
                },
                child: Center(
                    child: Text('Resent Code', style: TextStyle(color: Color(0xFF585858), fontSize: 15,),)
                ),
              ),
              SizedBox(
                height: size.height*0.05,
              ),

              isLoading ? Center(child: CircularProgressIndicator(
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

                      onPressed: (){

                        if(textEditingController.text.isEmpty) {
                          var snackBar = SnackBar(content: Text('Enter Code'
                            ,style: TextStyle(color: Colors.white),),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          verifyCode();
                        }


                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => VerificationCompleteScreen()),
                        // );
                      }, child: Text('Verify', style: buttonStyle)),
                ),
              ),
              SizedBox(
                height: size.height*0.05,
              ),

            ],),





          ],
        ),
      ),
    );
  }
}
