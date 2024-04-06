import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/get_cart_model.dart';
import 'package:honchos_restaurant_app/model/session_model.dart';
import 'package:honchos_restaurant_app/model/user_model.dart';
import 'package:honchos_restaurant_app/view/dashboard/dashboard_screen.dart';
import 'package:honchos_restaurant_app/view/enableLocation/enable_location_screen.dart';
import 'package:honchos_restaurant_app/view/forgetPassword/forget_password_screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:honchos_restaurant_app/view/home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({Key? key,}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SessionModel? model;
  //final cartController = Get.put(AddToCartController());
  String userId = '',userName = '',userEmail = '';
  bool isLoading = false;
  List<UserModel> model1 = [];



  void signIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {

      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'restaurant_session=$cookie'
      };
      // login_restaurant
      var request = http.MultipartRequest('POST', Uri.parse('${apiBaseUrl}login_restaurant'));
      request.fields.addAll({
        'email':_emailAddressController.text.trim().toString(),
        'password': _passwordController.text.toString()
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 200) {
        getSessionToken();
        // print(await response.stream.bytesToString() + ' 1 Login successfully');
        // getSessionToken();
        prefs.setString('userEmail', _emailAddressController.text.toString());


        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(content: Text('Login successfully'
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => RestaurantHomeScreen()
        ));


        // print(await response.stream.bytesToString());
      }
      else if (response.statusCode == 302) {
        print('Please Wait for admin approval');
        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(content: Text(
          //'we are here'
          data['message'].toString()
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        print(response.reasonPhrase);
        var snackBar = SnackBar(content: Text(
            'we are here 1'
         // await response.stream.bytesToString()
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }


    } catch(e) {
      setState(() {
        isLoading = false;
      });
      print( 'response after Hello getProducts' + e.toString());

      if(e.toString() == 'Bad state: Response has no Location header for redirect') {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var snackBar = SnackBar(content: Text('Session expires login to continue'
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        await preferences.remove('userEmail').then((value){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else if (e.toString() == 'Connection timed out') {
        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(content: Text('Network connection problem. Try again.'
          ,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      }

    }




  }


  void getSessionToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {
      'Cookie': 'restaurant_session=$cookie'
    };
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
       getUser();

       //cartController.fetchCartItems();
    }
    else if (response.statusCode == 302) {
      print(response.reasonPhrase);
    }
    else {
      print(response.reasonPhrase);

    }
  }


  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('userId') != null ) {
      setState(() {
        userId = prefs.getString('userId')!;
      });
    }

    var headers = {
      'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}users/$userId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      setState(() {
        model1 = List<UserModel>.from(json.decode(responseData).map((x) => UserModel.fromJson(x)));
      });
      if(model1.isNotEmpty) {
        prefs.setString('status', model1[0].status.toString());
        prefs.setString('userName', model1[0].name.toString());
        prefs.setString('userId', model1[0].id.toString());
        //print('Session Token ${model!.session!.token.toString()}');
        //getUserData();
      }

    }
    else {
      print(response.reasonPhrase);
    }

  }

  getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    FirebaseFirestore.instance.collection('Restaurant').where('phone', isEqualTo:prefs.getString('userPhone')).get().then((value) {
      setState(() {
        // userName = value.docs[0]['name'].toString();
        userEmail = value.docs[0]['email'].toString();
      });
    });

  }



  @override
  void initState() {
    // TODO: implement initState
    getUserName();
    setState(() {
    //  _phoneController.text = widget.phone.toString();
      isLoading = false;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
     backgroundColor: Colors.white,
      //resizeToAvoidBottomInset: false,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: new BoxDecoration(
          color: Colors.white,

        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
          Column(
            children: [
              Center(
                child: SizedBox(
                  height: size.height*0.35,
                  width: size.width,
                  child: Image.asset('assets/images/sign_in_bg.png', fit: BoxFit.cover,
                    height: size.height*0.35,
                    width: size.width,
                  ),
                ),
              ),

            ],),

          SingleChildScrollView(
            child: Container(
              height: size.height,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [


                  Container(height: size.height*0.7,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(30),
                            topLeft: Radius.circular(30)
                        )
                    ),
                    child: Column(
                      children: [

                        SizedBox(
                          height: size.height*0.05,
                        ),

                        Center(
                          child: SizedBox(
                            height: 80,
                            width: 120,
                            child: Image.asset('assets/images/welcome_logo.png', fit: BoxFit.scaleDown,
                              height: 80,
                              width: 120,),
                          ),
                        ),

                        SizedBox(
                          height: size.height*0.03,
                        ),

                        Center(
                          child: Text('Welcome back $userName!', style: TextStyle(color: Color(0xFF585858), fontSize: 16,fontWeight: FontWeight.bold),)
                        ),

                        SizedBox(
                          height: size.height*0.05,
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                          child: TextFormField(
                            controller: _emailAddressController,
                            keyboardType: TextInputType.emailAddress,
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
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
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
                              labelText: 'Email Address',
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
                          height: size.height*0.02,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16,right: 16,top: 0),
                          child: TextFormField(
                            autofocus: true,
                            controller: _passwordController,
                            obscureText: true,
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
                                fontWeight: FontWeight.w400,
                              ),

                              //create lable
                              labelText: 'Password',
                              //lable style
                              labelStyle: TextStyle(
                                color: darkRedColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height*0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16,right: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                              Text('Forget Password?', style: TextStyle(color: Color(0xFF585858), fontSize: 13,fontWeight: FontWeight.w500),),
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

                                  if(_emailAddressController.text.isEmpty) {
                                    var snackBar = SnackBar(content: Text('Enter email address',style: TextStyle(color: Colors.white),),
                                      backgroundColor: Colors.red,);
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                  else if(EmailValidator.validate(_emailAddressController.text) == false) {
                                    var snackBar = SnackBar(content: Text('Wrong Email Address'
                                      ,style: TextStyle(color: Colors.white),),
                                      backgroundColor: Colors.red,

                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                  else if(_passwordController.text.isEmpty) {
                                    var snackBar = SnackBar(content: Text('Enter password',style: TextStyle(color: Colors.white),),
                                      backgroundColor: Colors.red,);
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                  else if(userEmail != _emailAddressController.text) {
                                    var snackBar = SnackBar(content: Text('Sorry, this email is not registered with this number'
                                      ,style: TextStyle(color: Colors.white),),
                                      backgroundColor: Colors.red,

                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }

                                  else {

                                    setState(() {
                                      isLoading = true;
                                    });

                                    signIn();
                                  }



                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(builder: (context) => EnableLocationScreen()));

                                }, child: Text('Login', style: buttonStyle)),
                          ),
                        ),

                        SizedBox(
                          height: size.height*0.05,
                        ),




                      ],
                    ),

                    ),


                ],),
            ),
          ),


        ],),




      ),
    );
  }
}
