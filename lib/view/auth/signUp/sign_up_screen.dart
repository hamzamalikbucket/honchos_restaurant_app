import 'dart:convert';
import 'dart:io' as f;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/get_cart_model.dart';
import 'package:honchos_restaurant_app/model/input_validator.dart';
import 'package:honchos_restaurant_app/model/session_model.dart';
import 'package:honchos_restaurant_app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:honchos_restaurant_app/view/auth/login/login_screen.dart';
import 'package:honchos_restaurant_app/view/enableLocation/enable_location_screen.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  final String phone;
  final String restaurantId;
  const SignUpScreen(
      {Key? key, required this.phone, required this.restaurantId})
      : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SessionModel? model;
  String userId = '';
  List<UserModel> model1 = [];
  PickedFile? _pickedFile;
  f.File? imageFile;
  bool isLoading = false;
  bool isLoadingImage = false;

  //final FirebaseAuth auth = FirebaseAuth.instance;
  String? profileImage = '',
      docId,
      userType,
      driverEmail = '',
      driverName = '',
      driverUid = '',
      image = '';
  RegExp regEx = new RegExp(r"(?=.*[a-z])(?=.*[A-Z])\w+");
  final InputValidator _inputValidator = InputValidator();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  //f.File? image;
  //f.File image = f.File('your initial file');

  void signUp() async {
    //print(_nameController.text);
    print(_emailAddressController.text);
    print(_phoneController.text);
    print(_passwordController.text);
    print('we are in signup');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'restaurant_session=$cookie'
    };
    // var request = http.Request('POST', Uri.parse('http://restaurant.wettlanoneinc.com/api/register?email=${_emailAddressController.text.toString()}&password=${_passwordController.text.toString()}&phone_no=${widget.phone.toString()}&name=${_nameController.text.toString()}'));
    //
    // request.headers.addAll(headers);
    //
    // http.StreamedResponse response = await request.send();
    // final responseData = await response.stream.bytesToString();
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${apiBaseUrl}register_restaurant'));
      request.fields.addAll({
        // 'name': _nameController.text.toString(),
        'email': _emailAddressController.text.toString(), //'fortest@gmail.com',
        // 'phone_no': widget.phone.toString(),
        'password': _passwordController.text.toString(),
        'restaurant_id': widget.restaurantId.toString()
      });

      request.files.add(await http.MultipartFile.fromPath(
          'image', _pickedFile!.path.toString()));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        print(data.toString());
        print('we are in signup 200');
        // pageModel = PageModel.fromJson(json.decode(responseData));
        FirebaseFirestore.instance.collection('Restaurant').doc().set({
          'email': _emailAddressController.text.trim(),
          'phone': widget.phone.toString(),
          // 'name':_nameController.text.trim(),
          'image': profileImage.toString(),
          'password': _passwordController.text.trim(),
        }).then((value) {
          prefs.setString('userPhone', widget.phone.toString());
          prefs.setString('userEmail', _emailAddressController.text.toString());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          var snackBar = SnackBar(
            content: Text(
              'Restaurant registered successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
        // print(await response.stream.bytesToString());
      } else if (response.statusCode == 302) {
        print(await response.stream.bytesToString());
        // print(data.toString());
        print('we are in signup 302');
        print(response.reasonPhrase.toString());
        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(
          content: Text(
            'The email has already been taken.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // print(data.toString());
        setState(() {
          isLoading = false;
        });
        print('we are in signup else');
        print(response.reasonPhrase.toString());
        print(response.reasonPhrase);
        print(response.statusCode);
        var snackBar = SnackBar(
          content: Text(
            response.reasonPhrase.toString(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(imageFile!.toString());
      print(e.toString());
      var snackBar = SnackBar(
        content: Text(
          'Server is not responding',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void signIn() async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'restaurant_session=$cookie'
    };

    var request = http.MultipartRequest(
        'POST', Uri.parse('${apiBaseUrl}login_restaurant'));

    request.fields.addAll({
      'email': _emailAddressController.text.trim().toString(),
      'password': _passwordController.text.trim().toString()
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final responseData = await response.stream.bytesToString();
    final data = json.decode(responseData);

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      var snackBar = SnackBar(
        content: Text(
          'Restaurant created successfully',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (response.statusCode == 302) {
      print('we are in 302 error');
      setState(() {
        isLoading = false;
      });
      var snackBar = SnackBar(
        content: Text(
          data['mesage'].toString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print(response.reasonPhrase);
      var snackBar = SnackBar(
        content: Text(
          await response.stream.bytesToString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        setState(() {
                          isLoadingImage = true;
                        });
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      setState(() {
                        isLoadingImage = true;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _pickedFile = (await ImagePicker.platform
        .pickImage(source: ImageSource.camera, imageQuality: 50))!;

    getUrl(_pickedFile!.path).then((value) {
      if (value != null) {
        setState(() {
          profileImage = value.toString();
          imageFile = f.File(_pickedFile!.path);
          prefs.setString('profileImage', profileImage.toString());
          isLoadingImage = false;
        });
      } else {
        setState(() {
          isLoadingImage = false;
        });
        print('sorry error');
      }
    });
  }

  _imgFromGallery() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _pickedFile = (await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, imageQuality: 50))!;
    getUrl(_pickedFile!.path).then((value) {
      if (value != null) {
        setState(() {
          profileImage = value.toString();
          imageFile = f.File(_pickedFile!.path);
          prefs.setString('profileImage', profileImage.toString());
          isLoadingImage = false;
        });
      } else {
        setState(() {
          isLoadingImage = false;
        });
        print('sorry error');
      }
    });
  }

  Future<String?> getUrl(String path) async {
    final file = f.File(path);
    TaskSnapshot snapshot = await FirebaseStorage.instance
        .ref()
        .child("image" + DateTime.now().toString())
        .putFile(file);
    if (snapshot.state == TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      profileImage = '';
      _phoneController.text = widget.phone.toString();
      isLoading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // isLoadingImage = false;
    print(widget.restaurantId);
    // print(widget.restaurantId);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      height: size.height * 0.35,
                      width: size.width,
                      child: Image.asset(
                        'assets/images/sign_up_bg.png',
                        fit: BoxFit.cover,
                        height: size.height * 0.35,
                        width: size.width,
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Container(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: size.height * 0.85,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30))),
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: size.height * 0.04,
                              ),

                              Center(
                                child: SizedBox(
                                  height: 80,
                                  width: 120,
                                  child: Image.asset(
                                    'assets/images/welcome_logo.png',
                                    fit: BoxFit.scaleDown,
                                    height: 80,
                                    width: 120,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: size.height * 0.02,
                              ),

                              // Center(
                              //     child: Text('Create Account', style: TextStyle(color: Color(0xFF585858), fontSize: 16,fontWeight: FontWeight.bold),)
                              // ),

                              isLoadingImage
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      color: darkRedColor,
                                      strokeWidth: 1,
                                    ))
                                  : Center(
                                      child: Stack(children: [
                                      ClipOval(
                                        child: profileImage == ''
                                            ? Image.network(
                                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                profileImage.toString(),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Positioned(
                                        left: size.width * 0.1,
                                        top: size.height * 0.05,
                                        child: InkWell(
                                          onTap: () => _showPicker(context),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                // color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
                                                // border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                                ),
                                            child: Container(
                                              // height: 30,
                                              // width: 30,
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                //border: Border.all(width: 2, color: Colors.white),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black26,
                                                      offset: Offset(0, 4),
                                                      blurRadius: 2.0)
                                                ],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Image.asset(
                                                    'assets/images/editProfile.png',
                                                    width: 15,
                                                    height: 15,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ])),

                              // SizedBox(
                              //   height: size.height*0.01,
                              // ),

                              SizedBox(
                                height: size.height * 0.04,
                              ),

                              // Container(
                              //   margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
                              //   child: TextFormField(
                              //     controller: _nameController,
                              //     keyboardType: TextInputType.name,
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       color: Colors.black,
                              //
                              //     ),
                              //     onChanged: (value) {
                              //       // setState(() {
                              //       //   userInput.text = value.toString();
                              //       // });
                              //     },
                              //     decoration: InputDecoration(
                              //       //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
                              //       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              //       focusColor: Colors.white,
                              //       //add prefix icon
                              //
                              //       // errorText: "Error",
                              //
                              //       border: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(10.0),
                              //       ),
                              //
                              //       focusedBorder: OutlineInputBorder(
                              //         borderSide:
                              //         BorderSide(color: darkGreyTextColor1, width: 1.0),
                              //         borderRadius: BorderRadius.circular(10.0),
                              //       ),
                              //       fillColor: Colors.grey,
                              //       hintText: "",
                              //
                              //       //make hint text
                              //       hintStyle: TextStyle(
                              //         color: Colors.grey,
                              //         fontSize: 16,
                              //         fontFamily: "verdana_regular",
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //
                              //       //create lable
                              //       labelText: 'Full Name',
                              //       //lable style
                              //       labelStyle: TextStyle(
                              //         color: darkRedColor,
                              //         fontSize: 16,
                              //         fontFamily: "verdana_regular",
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: size.height*0.02,
                              // ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 0),
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
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 15.0),
                                    focusColor: Colors.white,
                                    //add prefix icon

                                    // errorText: "Error",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: darkGreyTextColor1,
                                          width: 1.0),
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
                                height: size.height * 0.02,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 0),
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  enabled: false,
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

                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 15.0),
                                    focusColor: Colors.white,
                                    //add prefix icon

                                    // errorText: "Error",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: darkGreyTextColor1,
                                          width: 1.0),
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
                                    labelText: 'Phone Number',
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
                                height: size.height * 0.02,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, right: 16, top: 0),
                                child: TextFormField(
                                  autofocus: true,
                                  controller: _passwordController,
                                  keyboardType: TextInputType.text,
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
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 15.0),

                                    // errorText: "Error",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: darkGreyTextColor1,
                                          width: 1.0),
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
                                    labelText: 'Password',
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
                                height: size.height * 0.02,
                              ),

                              SizedBox(
                                height: size.height * 0.05,
                              ),

                              isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      color: darkRedColor,
                                      strokeWidth: 1,
                                    ))
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 4),
                                                blurRadius: 5.0)
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              minimumSize:
                                                  MaterialStateProperty.all(
                                                      Size(size.width, 50)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              // elevation: MaterialStateProperty.all(3),
                                              shadowColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                            ),
                                            onPressed: () {
                                              if (profileImage == '') {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Upload profile image',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              }

                                              // else if(_nameController.text.isEmpty) {
                                              //    var snackBar = SnackBar(content: Text('Enter name',style: TextStyle(color: Colors.white),),
                                              //      backgroundColor: Colors.red,);
                                              //    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              //  }
                                              //  else if(_inputValidator
                                              //      .validateName(_nameController.text) !=
                                              //      'success' &&
                                              //      _nameController.text.isNotEmpty) {
                                              //
                                              //    var snackBar = SnackBar(content: Text('Invalid Name',style: TextStyle(color: Colors.white),),
                                              //      backgroundColor: Colors.red,);
                                              //    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              //
                                              //  }
                                              else if (_emailAddressController
                                                  .text.isEmpty) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Enter email address',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else if (EmailValidator.validate(
                                                      _emailAddressController
                                                          .text) ==
                                                  false) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Wrong Email Address',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else if (_phoneController
                                                  .text.isEmpty) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Enter phone number',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else if (_passwordController
                                                  .text.isEmpty) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Enter password',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else if (_inputValidator
                                                          .validatePassword(
                                                              _passwordController
                                                                  .text) !=
                                                      'success' &&
                                                  _passwordController
                                                      .text.isNotEmpty) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Password must have 8 character with one lower case letter and one upper case and a special character.',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else if (_passwordController
                                                      .text.length <
                                                  7) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Password length must have at least 8 character.',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else if (RegExp(
                                                          r'[!@#\$%^&*()_+{}\[\]:;<>,.?~\\]')
                                                      .hasMatch(
                                                          _passwordController
                                                              .text) ==
                                                  false) {
                                                var snackBar = SnackBar(
                                                  content: Text(
                                                    'Password must have at least one special character.',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              } else {
                                                print(
                                                    ' all condition done success');

                                                setState(() {
                                                  isLoading = true;
                                                });

                                                signUp();
                                              }
                                            },
                                            child: Text('Sign Up',
                                                style: buttonStyle)),
                                      ),
                                    ),
                              SizedBox(
                                height: size.height * 0.05,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center(
                      //   child: SizedBox(
                      //     height: 120,
                      //     width: 120,
                      //     child: Image.asset('assets/images/logo_trans.png', fit: BoxFit.scaleDown,
                      //       height: 120,
                      //       width: 120,),
                      //   ),
                      // ),

                      // Container(
                      //   width: size.width,
                      //   height: size.height,
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //
                      //
                      //
                      //       Container(
                      //
                      //         decoration: BoxDecoration(
                      //           boxShadow: [
                      //             BoxShadow(
                      //                 color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                      //           ],
                      //           gradient: LinearGradient(
                      //             begin: Alignment.topLeft,
                      //             end: Alignment.bottomRight,
                      //             stops: [0.0, 1.0],
                      //             colors: [
                      //               lightRedColor,
                      //               darkRedColor,
                      //             ],
                      //           ),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         child: ElevatedButton(
                      //             style: ButtonStyle(
                      //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      //                 RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.circular(10.0),
                      //                 ),
                      //               ),
                      //               minimumSize: MaterialStateProperty.all(Size(size.width*0.8, 50)),
                      //               backgroundColor:
                      //               MaterialStateProperty.all(Colors.transparent),
                      //               // elevation: MaterialStateProperty.all(3),
                      //               shadowColor:
                      //               MaterialStateProperty.all(Colors.transparent),
                      //             ),
                      //
                      //             onPressed: (){}, child: Text('Login', style: buttonStyle)),
                      //       ),
                      //
                      //       SizedBox(
                      //         height: size.height*0.05,
                      //       ),
                      //
                      //       Center(
                      //         child: SizedBox(
                      //           height: 10,
                      //           width: 100,
                      //           child: Image.asset('assets/images/red_line.png', fit: BoxFit.scaleDown,
                      //             height: 10,
                      //             width: 100,),
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: size.height*0.025,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
