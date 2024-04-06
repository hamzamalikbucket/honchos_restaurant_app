import 'dart:convert';

import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/input_validator.dart';
import 'package:honchos_restaurant_app/view/auth/login/login_screen.dart';
import 'package:honchos_restaurant_app/view/auth/phone_login/phone_login_screen.dart';
import 'package:honchos_restaurant_app/view/enableLocation/enable_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerificationCompleteScreen extends StatefulWidget {
  const VerificationCompleteScreen({Key? key}) : super(key: key);

  @override
  _VerificationCompleteScreenState createState() => _VerificationCompleteScreenState();
}

class _VerificationCompleteScreenState extends State<VerificationCompleteScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final InputValidator _inputValidator = InputValidator();
  bool isLoading = false;


  void resetPassword() async {



    var headers = {
    'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${apiBaseUrl}restaurant_change_password'));
    request.fields.addAll({
      'password': _passwordController.text.toString(),
      'confirm_password': _confirmPassController.text.toString()
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = json.decode(responseData);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });

      var snackBar = SnackBar(content: Text('Password updated successfully'
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
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
    else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase.toString() + ' Hello error');
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
    //
    // var request = http.Request('POST', Uri.parse('https://restaurant.wettlanoneinc.com/api/driver_change_password?password=${_passwordController.text.toString()}&confirm_password=${_confirmPassController.text.toString()}'));
    //
    //  request.headers.addAll(headers);
    //
    // http.StreamedResponse response = await request.send();
    // final responseData = await response.stream.bytesToString();
    // final data = json.decode(responseData);
    // if (response.statusCode == 200) {
    //   // pageModel = PageModel.fromJson(json.decode(responseData));
    //
    //   setState(() {
    //     isLoading = false;
    //   });
    //
    //   var snackBar = SnackBar(content: Text('Password updated successfully'
    //     ,style: TextStyle(color: Colors.white),),
    //     backgroundColor: Colors.green,
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => LoginScreen()),
    //   );
    //
    //
    //   // print(await response.stream.bytesToString());
    // }
    // else if (response.statusCode == 302) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   var snackBar = SnackBar(content: Text(
    //     data['mesage'].toString() == 'null' ? data['message'].toString() : data['mesage'].toString()
    //     ,style: TextStyle(color: Colors.white),),
    //     backgroundColor: Colors.red,
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // }
    // else {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   print(response.reasonPhrase.toString() + ' Hello error');
    //   // var snackBar = SnackBar(content: Text(await response.stream.bytesToString()
    //   //   ,style: TextStyle(color: Colors.white),),
    //   //   backgroundColor: Colors.red,
    //   // );
    //   // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // }

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // setState(() {
    //   isLoading = false;
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
                child: Text('Verification Complete', style: TextStyle(color: Color(0xFF585858), fontSize: 25,fontWeight: FontWeight.bold),)
            ),

            SizedBox(
              height: size.height*0.025,
            ),

            Container(
              width: size.width*0.8,
              child: Center(
                  child: Text('Choose New Password',
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
                child: Image.asset('assets/images/verification_complete_image.png', fit: BoxFit.scaleDown,
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

            Container(
              margin: EdgeInsets.only(left: 16,right: 16,top: 0),
              child: TextFormField(
                autofocus: true,
                controller: _passwordController,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,

                ),
                onChanged: (value) {
                  // setState(() {
                  //   userInput.text = value.toString();
                  // });
                },
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                  focusColor: Colors.white,
                  //add prefix icon
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),

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
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),

                  //create lable
                  labelText: 'Password',
                  //lable style
                  labelStyle: TextStyle(
                    color: darkRedColor,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height*0.02,
            ),

            Container(
              margin: EdgeInsets.only(left: 16,right: 16,top: 0),
              child: TextFormField(
                autofocus: true,
                controller: _confirmPassController,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,

                ),
                onChanged: (value) {
                  // setState(() {
                  //   userInput.text = value.toString();
                  // });
                },
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                  focusColor: Colors.white,
                  //add prefix icon
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),

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
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),

                  //create lable
                  labelText: 'Confirm Password',
                  //lable style
                  labelStyle: TextStyle(
                    color: darkRedColor,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            SizedBox(
              height: size.height*0.03,
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

                    onPressed: () {

                      if(_passwordController.text.isEmpty) {
                        var snackBar = SnackBar(content: Text('Enter password',style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      else if(_inputValidator
                          .validatePassword(_passwordController.text) !=
                          'success' &&
                          _passwordController.text.isNotEmpty) {
                        var snackBar = SnackBar(content: Text('Password must have 8 character with one lower case letter and one upper case.'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                      else if (_passwordController.text.length < 7) {

                        var snackBar = SnackBar(content: Text('Password length must have at least 8 character.'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,

                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      }

                      else if(_confirmPassController.text.isEmpty){
                        var snackBar = SnackBar(content: Text('Enter confirm password',style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                      else if(_confirmPassController.text.toString() != _passwordController.text.toString()){
                        var snackBar = SnackBar(content: Text('Sorry password and confirm password must be same',style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.red,);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        setState(() {
                          isLoading = true;
                        });
                        resetPassword();
                      }

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => EnableLocationScreen()
                      //   ));

                    }, child: Text('Confirm', style: buttonStyle)),
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
