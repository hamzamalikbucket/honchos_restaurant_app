import 'dart:convert';

import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/view/verifyPhone/verify_otp_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  String way = 'email',emailApi = "",tokenApi = "";

  bool isLoading = false;


  Future forgetPassword() async {

    // var headers = {
    //   'Content-Type': 'application/json',
    //   'Cookie': 'restaurant_session=$cookie'
    // };
    var request = http.Request('POST', Uri.parse('${apiBaseUrl}restaurant_forgot_password?email=${_controller.text.toString()}'));

    //request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = json.decode(responseData);
    if (response.statusCode == 200) {
      // pageModel = PageModel.fromJson(json.decode(responseData));



      // var request1 = http.Request('POST', Uri.parse('http://restaurant.wettlanoneinc.com/api/driver_get_otp_email'));
      //
      // http.StreamedResponse response2 = await request1.send();
      // final responseData2 = await response2.stream.bytesToString();
      //
      // if (response2.statusCode == 200) {
      //   final data1 = json.decode(responseData2);
      //   // pageModel = PageModel.fromJson(json.decode(responseData));
      //   setState(() {
      //     isLoading = false;
      //   });
      //   setState(() {
      //     emailApi = data1['email'].toString();
      //     tokenApi = data1['token'].toString();
      //   });
      //
      //   print( tokenApi +' token text\n' + emailApi + ' Email text\n') ;
      //
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyOtpPhoneScreen(email: _controller.text.toString(),token: '',)),
        );
      //
      // }
      // else if (response2.statusCode == 302) {
      //   final data1 = json.decode(responseData2);
      //   setState(() {
      //     isLoading = false;
      //   });
      //   var snackBar = SnackBar(content: Text(
      //     data1['mesage'].toString() == 'null' ? data1['message'].toString() : data1['mesage'].toString()
      //     ,style: TextStyle(color: Colors.white),),
      //     backgroundColor: Colors.red,
      //   );
      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // }
      // else {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   print(response2.reasonPhrase);
      //   var snackBar = SnackBar(content: Text(await response2.stream.bytesToString()
      //     ,style: TextStyle(color: Colors.white),),
      //     backgroundColor: Colors.red,
      //   );
      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // }


      setState(() {
        isLoading = false;
      });

      var snackBar = SnackBar(content: Text(data['message'].toString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => VerifyOtpPhoneScreen(email: _controller.text.toString(),token: tokenApi,)),
      // );



      // print(await response.stream.bytesToString());
    }
    else if (response.statusCode == 302) {
      setState(() {
        isLoading = false;
      });
      var snackBar = SnackBar(content: Text(
        data['mesage'].toString() == 'null' ? data['message'].toString() : data['mesage'].toString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else if (response.statusCode == 500) {
      setState(() {
        isLoading = false;
      });
      var snackBar = SnackBar(content: Text('Internal Server Error'
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else {
      print(response.reasonPhrase);
      var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }


  }

  void getToken() async {

    var request1 = http.Request('GET', Uri.parse('${apiBaseUrl}restaurant_get_otp_email'));

    http.StreamedResponse response2 = await request1.send();
    final responseData2 = await response2.stream.bytesToString();

    if (response2.statusCode == 200) {
      final data1 = json.decode(responseData2);
      // pageModel = PageModel.fromJson(json.decode(responseData));
      setState(() {
        isLoading = false;
      });
      setState(() {
        emailApi = data1['email'].toString();
        tokenApi = data1['token'].toString();
      });

      print( tokenApi +' token text\n' + emailApi + ' Email text\n') ;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyOtpPhoneScreen(email: _controller.text.toString(),token: tokenApi,)),
      );

    }
    else if (response2.statusCode == 302) {
      final data1 = json.decode(responseData2);
      setState(() {
        isLoading = false;
      });
      var snackBar = SnackBar(content: Text(
        data1['mesage'].toString() == 'null' ? data1['message'].toString() : data1['mesage'].toString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else {
      setState(() {
        isLoading = false;
      });
      print(response2.reasonPhrase);
      var snackBar = SnackBar(content: Text(await response2.stream.bytesToString()
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }





  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      way = 'email';
      isLoading = false;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
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
                child: Text('Forget Password', style: TextStyle(color: Color(0xFF585858), fontSize: 25,fontWeight: FontWeight.bold),)
            ),

            SizedBox(
              height: size.height*0.025,
            ),

            Container(
              width: size.width*0.8,
              child: Center(
                  child: Text('Provide your email address on which your account is registered.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkGreyTextColor, fontSize: 14,),)
              ),
            ),

            // SizedBox(
            //   height: size.height*0.025,
            // ),


            Center(
              child: SizedBox(
               // height: size.height*0.5,
                width: size.width*0.9,
                child: Image.asset('assets/images/forget_pass_image.png', fit: BoxFit.scaleDown,
                 // height: size.height*0.5,
                  width: size.width*0.9,
                  // height: 80,
                  // width: 80,
                ),
              ),
            ),

            SizedBox(
              height: size.height*0.03,
            ),

            Container(
              margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
              child: TextFormField(

                controller: _controller,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,

                ),
                onChanged: (value) {
                  // setState(() {
                  //   userInput.text = value.toString();
                  // });
                },
                keyboardType: way == 'email' ? TextInputType.emailAddress : TextInputType.number,

                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 18.0),
                  focusColor: Colors.white,
                  //add prefix icon

                  // errorText: "Error",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: darkGreyTextColor1, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: Colors.grey,
                  hintText: "",

                  //make hint text
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: "verdana_regular",
                    fontWeight: FontWeight.w400,
                  ),

                  //create lable
                  labelText:   way == 'phone' ? 'Phone Number' :'Email Address',
                  //lable style
                  labelStyle: TextStyle(
                    color: darkRedColor,
                    fontSize: 16,
                    fontFamily: "verdana_regular",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height*0.03,
            ),
            // GestureDetector(
            //   onTap: () {
            //     if(way == 'email') {
            //       // setState(() {
            //       //   way = 'phone';
            //       // });
            //     } else {
            //       setState(() {
            //         way = 'email';
            //       });
            //     }
            //   },
            //   child: Center(
            //       child: Text('Try another way', style: TextStyle(color: Color(0xFF585858), fontSize: 15,),)
            //   ),
            // ),
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

                    onPressed: () {

                      if(_controller.text.isEmpty) {
                        var snackBar = SnackBar(content: Text('Enter email address',style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      else if(EmailValidator.validate(_controller.text) == false) {
                        var snackBar = SnackBar(content: Text('Wrong Email Address'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,

                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          isLoading = true;
                        });

                        forgetPassword().then((value) {
                          //getToken();
                        });

                      }

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => VerifyOtpPhoneScreen()),
                     // );
                    }, child: Text('Forget Password', style: buttonStyle)),
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
