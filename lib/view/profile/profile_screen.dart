import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honchos_restaurant_app/constants.dart';

import 'package:flutter/material.dart';
import 'package:honchos_restaurant_app/model/user_model.dart';
import 'package:honchos_restaurant_app/view/splash/splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String token = '',
      name = '',
      profileImage = '',
      userId = '',
      address = '';

  List<UserModel> model = [];

  @override
  void initState() {
    // TODO: implement initState
  //  getUser();
   // getUserData();
    super.initState();
  }


  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('userId') != null ) {
      setState(() {
        userId = prefs.getString('userId')!;
      });
      print('userId is here $userId');
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
        model = List<UserModel>.from(json.decode(responseData).map((x) => UserModel.fromJson(x)));
      });
      if(model.isNotEmpty) {
        prefs.setString('status', model[0].status.toString());
        prefs.setString('userName', model[0].name.toString());
        prefs.setString('userId', model[0].id.toString());
        //print('Session Token ${model!.session!.token.toString()}');
        getUserData();
      }
      // if(prefs.getString('userName') != null) {
      //   setState(() {
      //     name =  prefs.getString('userName')!;
      //   });
      // }
    }
    else {
      print(response.reasonPhrase);
    }

  }


  getUserData() async {
    print('we are in get user data');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('token') != null) {
      setState(() {
        token =  prefs.getString('token')!;
      });
    }
    if(prefs.getString('profileImage') != null) {
      setState(() {
        profileImage =  prefs.getString('profileImage')!;
      });
      print(profileImage.toString() + ' Profile image');
    }else {

      if(prefs.getString('userId') != null) {
        FirebaseFirestore.instance.collection('userImage').doc(prefs.getString('userId')).get().then((value) {
          setState(() {
            profileImage = value['image'];
          });

        });
      }



    }
    if(prefs.getString('userName') != null) {
      setState(() {
        name =  prefs.getString('userName')!;
      });
    }
    if(prefs.getString('userAddress') != null) {
      setState(() {
        address =  prefs.getString('userAddress')!;
        //name =  prefs.getString('userName')!;
      });
    }

  }


  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: size.height*0.38,
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(50), bottomLeft: Radius.circular(50)),
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
              child: Column(children: [
                Padding(
                  padding:  EdgeInsets.only(top: size.height*0.03),
                  child: Container(
                    height: size.height*0.08,
                    width: size.width,
                    child: Stack(
                      alignment: Alignment.centerRight,

                      children: [
                        Container(
                            width: size.width,
                            height: size.height*0.08,
                            child: Center(
                              child: Text('Profile',
                                style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                              ),
                            )),
                        // Container(
                        //   width: size.width,
                        //   height: size.height*0.08,
                        //   child:   Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //
                        //     children: [
                        //       Stack(
                        //         alignment: Alignment.topRight,
                        //         children: [
                        //         Padding(
                        //           padding: const EdgeInsets.only(right: 10),
                        //           child: Container(
                        //             width: 30,
                        //             height: 30,
                        //             // width: size.width*0.5,
                        //             decoration: BoxDecoration(
                        //                 shape: BoxShape.circle,
                        //                 color: Colors.white
                        //             ),
                        //             child: Center(
                        //                 child: Icon(Icons.favorite,size: 20,color: Colors.red,)
                        //             ),
                        //           ),
                        //         ),
                        //         Positioned(
                        //           right: size.width*0.01,
                        //           child: Container(
                        //             width: 14,
                        //             height: 14,
                        //             // width: size.width*0.5,
                        //             decoration: BoxDecoration(
                        //                 shape: BoxShape.circle,
                        //                 color: Colors.black
                        //             ),
                        //             child: Center(
                        //               child: Text('10',
                        //                 style: TextStyle(color: Colors.white, fontSize: 8,fontWeight: FontWeight.w500),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ],)
                        //
                        //
                        //
                        //     ],),
                        //
                        // ),
                      ],),

                  ),
                ),

                SizedBox(
                  height: size.height*0.01,
                ),

                Container(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        profileImage == '' ?
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2,color: Colors.white)
                          ),
                          child: CircleAvatar(
                            backgroundColor: lightButtonGreyColor,
                            radius: 50,
                            backgroundImage: NetworkImage( 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png'),
                          ),
                        ) :
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 2,color: Colors.white)
                          ),
                          child: CircleAvatar(
                            backgroundColor: lightButtonGreyColor,
                            radius: 50,
                            backgroundImage: NetworkImage(profileImage.toString()),
                          ),
                        ),
                      ],
                    )),

                SizedBox(
                  height: size.height*0.01,
                ),

                Container(
                    width: size.width,
                    child: Center(
                      child: Text(name.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                      ),
                    )),


                SizedBox(
                  height: size.height*0.02,
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/locationIcon.png', fit: BoxFit.scaleDown,
                        height: 15,
                        color: Colors.white,
                        width: 15,
                      ),

                      Container(
                        width: size.width*0.8,
                        child: Text(address.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 10,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                      ),


                    ],),
                ),
                SizedBox(
                  height: size.height*0.02,
                ),



              ],)
            ),


            SizedBox(
              height: size.height*0.02,
            ),
            Padding(
              padding:  EdgeInsets.only(left: size.width*0.25,right: size.width*0.25,),
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
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => MyOrdersScreen()));
                      //
                    }, child: Text('My Orders', style: buttonStyle)),
              ),
            ),
            // SizedBox(
            //   height: size.height*0.02,
            // ),


            SizedBox(
              height: size.height*0.02,
            ),

            ListTile(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => DashBoardScreen(index: 6))).then((value) {
                  //   getUser();
                  // });
                },
                leading:      Image.asset('assets/images/editProfile.png', width: 20,height: 20,fit: BoxFit.scaleDown,
                ),
                title: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w500),
                ),
                trailing:Icon(Icons.arrow_forward_ios_outlined, size: 15,color: Colors.black)

            ),

            ListTile(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => SaveCardDetailsScreen()));
                },
              leading:  Image.asset('assets/images/payment_icon.png', width: 20,height: 20,fit: BoxFit.scaleDown,
              ),
              title: Text(
                'Payment Methods',
                style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w500),
              ),
              trailing:Icon(Icons.arrow_forward_ios_outlined, size: 15,color: Colors.black)

            ),

            ListTile(
                onTap: () {

                },
                leading:    Image.asset('assets/images/share_app.png', width: 18,height: 18,fit: BoxFit.scaleDown,
                ),
                title: Text(
                  'Share App',
                  style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w500),
                ),
                trailing:Icon(Icons.arrow_forward_ios_outlined, size: 15,color: Colors.black)

            ),

            ListTile(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
                },
                leading: Image.asset('assets/images/privacyPolicy.png', width: 18,height: 18,fit: BoxFit.scaleDown,
                ),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w500),
                ),
                trailing:Icon(Icons.arrow_forward_ios_outlined, size: 15,color: Colors.black)

            ),


            SizedBox(
              height: size.height*0.05,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                GestureDetector(
                  onTap: () async {

                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    if(prefs.getString('userPhone') != null && prefs.getString('userEmail') != null) {

                      prefs.remove('userPhone');
                       prefs.remove('userEmail');

                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SplashScreen()));

                    }


                  },
                  child: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.black, fontSize: 17,fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),


          ],
        ),
      ),

    );
  }
}
