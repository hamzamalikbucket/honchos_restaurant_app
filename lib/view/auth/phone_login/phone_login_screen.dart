import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/view/auth/login/login_screen.dart';
import 'package:honchos_restaurant_app/view/auth/signUp/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honchos_restaurant_app/view/chooseRestaurant/choose_restaurant_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen();

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _countryDialCode, smsCode;
  bool _obscureText = false, isLoadingDialog = false, isVerify = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _categories = [];
  String isCategoryExists = '';
  String password = '';
  final TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _countryDialCode = '+27';
      isCategoryExists = 'no';
      isLoadingDialog = false;
      isVerify = false;
    });
    getCookie();
    // _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
    //     : CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).dialCode;
    // _phoneController.text =  Get.find<AuthController>().getUserNumber() ?? '';
    // _passwordController.text = Get.find<AuthController>().getUserPassword() ?? '';
  }

  getCookie() async {
    var headers = {'Cookie': 'restaurant_session=$cookie'};
    var request = http.Request('GET', Uri.parse('${apiBaseUrl}get_cookie'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
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
                      'assets/images/sign_in_bg.png',
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
                      height: size.height * 0.7,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              topLeft: Radius.circular(30))),
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.05,
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
                            height: size.height * 0.05,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    lightButtonGreyColor, //Theme.of(context).cardColor,
                                //boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                              ),
                              child: Column(children: [
                                Row(children: [
                                  CountryCodePicker(
                                    onChanged: (code) {
                                      setState(() {
                                        _countryDialCode = code.toString();
                                      });
                                      print(code.toString() +
                                          ' This is the code');
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    // initialSelection: 'SA',
                                    favorite: const ['+27'],
                                    initialSelection: '+27',
                                    countryFilter: ['SS', '+27', '+92'],
                                    //countryFilter: const ['IT', 'FR'],
                                    // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                                    flagDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: lightButtonGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                        // maxLines: widget.maxLines,
                                        controller: _phoneController,
                                        focusNode: _phoneFocus,
                                        // textAlign: widget.textAlign,
                                        // style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                                        textInputAction: TextInputAction.done,

                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        cursorColor:
                                            Theme.of(context).primaryColor,
                                        //textCapitalization: widget.capitalization,
                                        //enabled: widget.isEnabled,
                                        autofocus: false,
                                        obscureText: false,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[0-9]'))
                                        ],
                                        // : widget.isAmount ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : widget.isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))] : null,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  style: BorderStyle.none,
                                                  width: 0),
                                            ),
                                            isDense: true,
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            hintText:
                                                '12345678901', //'password'.tr,
                                            fillColor:
                                                lightButtonGreyColor, //Theme.of(context).cardColor,
                                            // hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                                            filled: true,
                                            // prefixText: '+1 | ',
                                            prefixStyle: TextStyle(
                                                color: darkGreyTextColor)
                                            // prefixIcon: widget.prefixIcon != null ? Padding(
                                            //   padding: EdgeInsets.symmetric(horizontal: widget.prefixSize),
                                            //   child: Image.asset(widget.prefixIcon, height: 20, width: 20),
                                            // ) : null,
                                            // suffixIcon: IconButton(
                                            //   icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).hintColor.withOpacity(0.3)),
                                            //   onPressed: () {
                                            //     setState(() {
                                            //       _obscureText = !_obscureText;
                                            //     });
                                            //   },
                                            // ),
                                            ),
                                        // onSubmitted: (text) => (GetPlatform.isWeb && authController.acceptTerms)
                                        //     ? _login(authController, _countryDialCode) : null,
                                        // onChanged: widget.onChanged,
                                      ),
                                    ),
                                    // CustomTextField(
                                    //   hintText: 'phone'.tr,
                                    //   controller: _phoneController,
                                    //   focusNode: _phoneFocus,
                                    //   nextFocus: _passwordFocus,
                                    //   inputType: TextInputType.phone,
                                    //   divider: false,
                                    // )
                                  ),
                                ]),
                              ]),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          isLoadingDialog
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
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
                                        onPressed: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(builder: (context) => EnableLocationScreen()));

                                          if (_phoneController.text.isEmpty) {
                                            var snackBar = SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  'Phone number is required',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          } else {
                                            if (_phoneController.text.length <
                                                7) {
                                              var snackBar = SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    'Wrong phone number',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            } else {
                                              setState(() {
                                                isLoadingDialog = true;
                                              });

                                              print(_countryDialCode! +
                                                  _phoneController.text
                                                      .trim()
                                                      .toString() +
                                                  ' Phone number');
                                              prefs.setString(
                                                  'userPhone',
                                                  _countryDialCode! +
                                                      _phoneController.text
                                                          .trim());

                                              FirebaseFirestore.instance
                                                  .collection('Restaurant')
                                                  .where('phone',
                                                      isEqualTo:
                                                          _countryDialCode! +
                                                              _phoneController
                                                                  .text
                                                                  .toString())
                                                  .get()
                                                  .then((value) {
                                                if (value.docs.isNotEmpty) {
                                                  setState(() {
                                                    isLoadingDialog = false;
                                                    isCategoryExists = 'yes';
                                                  });
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginScreen()));
                                                } else {
                                                  registerUser(
                                                      '${_countryDialCode! + _phoneController.text.trim()}',
                                                      context);
                                                }
                                              });

                                              // final snapshot = await FirebaseFirestore.instance.collection('Restaurant').get();
                                              // snapshot.docs.forEach((element) {
                                              //   print('user data');
                                              //   if(element['phone'] == _countryDialCode!+_phoneController.text.toString().trim()) {
                                              //     print('user age in if of current user ');
                                              //     //   print(element['age']);
                                              //     setState(() {
                                              //       isCategoryExists = 'yes';
                                              //     });
                                              //
                                              //   }
                                              // });
                                              //
                                              // print(_countryDialCode.toString()+' Dial Code');
                                              // print(_countryDialCode!+_phoneController.text.trim().toString() + ' Phone number');
                                              //
                                              //
                                              // if(isCategoryExists == 'yes') {
                                              //   print(_countryDialCode!+_phoneController.text.trim().toString() + ' Phone number');
                                              //   prefs.setString('userPhone', _countryDialCode!+_phoneController.text.trim());
                                              //
                                              //   setState(() {
                                              //     isLoadingDialog = false;
                                              //     isCategoryExists = 'yes';
                                              //   });
                                              //   Navigator.push(context, MaterialPageRoute(
                                              //       builder: (context) => LoginScreen()
                                              //   ));
                                              // } else {
                                              //   registerUser('${_countryDialCode!+_phoneController.text.trim()}',context);
                                              // }
                                            }

                                            // var snackBar = SnackBar(content: Text('Hello World'));
                                            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }
                                        },
                                        child:
                                            Text('Next', style: buttonStyle)),
                                  ),
                                ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future registerUser(String mobile, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final size = MediaQuery.of(context).size;
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: Duration(seconds: 60),
      verificationFailed: (authException) {
        print('WE are here in code sent verificationFailed');

        setState(() {
          isLoadingDialog = false;
        });
        showDialog(
            context: context,
            useSafeArea: false,
            barrierDismissible: true,
            builder: (context) => WillPopScope(
                  onWillPop: () async => true,
                  child: StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      insetPadding: EdgeInsets.all(0),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            Container(
                              width: size.width * 0.8,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.arrow_back,
                                        size: 20,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.035,
                            ),
                            Center(
                                child: Text(
                              'Verify Phone Number',
                              style: TextStyle(
                                  color: Color(0xFF585858),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            )),
                            SizedBox(
                              height: size.height * 0.025,
                            ),
                            Container(
                              width: size.width * 0.8,
                              child: Center(
                                  child: Text(
                                'Unable to verify. Try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              )),
                            ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all(
                                          Size(size.width, 50)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      // elevation: MaterialStateProperty.all(3),
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.transparent),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      //  await PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode!);
                                    },
                                    child: Text('Cancel', style: buttonStyle)),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ));
        // var snackBar = SnackBar(
        //     backgroundColor: Colors.red,
        //     content: Text('Wrong code',style: TextStyle(color: Colors.white),));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // print(authException.message);
      },
      codeSent: (String? verificationId, int? code) {
        //show dialog to take input from the user
        setState(() {
          isLoadingDialog = false;
        });
        print('WE are here in code sent $code this is your code');
        showDialog(
            context: context,
            useSafeArea: false,
            barrierDismissible: false,
            builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                      insetPadding: EdgeInsets.all(0),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.03,
                            ),

                            Container(
                              width: size.width * 0.8,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.arrow_back,
                                        size: 20,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                            ),

                            SizedBox(
                              height: size.height * 0.035,
                            ),

                            Center(
                                child: Text(
                              'Verify Phone Number',
                              style: TextStyle(
                                  color: Color(0xFF585858),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            )),

                            SizedBox(
                              height: size.height * 0.025,
                            ),

                            Container(
                              width: size.width * 0.8,
                              child: Center(
                                  child: Text(
                                'Enter the 4 digit code received on your entered phone number.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: darkGreyTextColor,
                                  fontSize: 14,
                                ),
                              )),
                            ),

                            SizedBox(
                              height: size.height * 0.025,
                            ),

                            Center(
                              child: SizedBox(
                                // height: size.height*0.5,
                                width: size.width * 0.8,
                                child: Image.asset(
                                  'assets/images/otp_screen.png',
                                  fit: BoxFit.scaleDown,
                                  // height: size.height*0.5,
                                  width: size.width * 0.8,
                                  // height: 80,
                                  // width: 80,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: size.height * 0.03,
                            ),

                            Form(
                              key: formKey,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 0),
                                  child: PinCodeTextField(
                                    autoDisposeControllers: false,
                                    backgroundColor: Colors.white,
                                    appContext: context,
                                    pastedTextStyle: TextStyle(
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    length: 6,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    // obscuringWidget: const FlutterLogo(
                                    //   size: 24,
                                    // ),
                                    blinkWhenObscuring: true,
                                    animationType: AnimationType.fade,
                                    validator: (v) {
                                      if (v!.length < 3) {
                                        return "";
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
                                      borderWidth: 0.5,
                                      fieldHeight: 40,
                                      fieldWidth: 35,
                                      activeFillColor: Colors.white,
                                    ),
                                    cursorColor: Colors.black,
                                    animationDuration:
                                        const Duration(milliseconds: 300),
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
                                    onCompleted: (v) {
                                      debugPrint("Completed");
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
                              height: size.height * 0.03,
                            ),

                            // GestureDetector(
                            //   onTap: () {
                            //     // if(way == 'email') {
                            //     //   setState(() {
                            //     //     way = 'phone';
                            //     //   });
                            //     // } else {
                            //     //   setState(() {
                            //     //     way = 'email';
                            //     //   });
                            //     // }
                            //   },
                            //   child: Center(
                            //       child: Text('Resent Code', style: TextStyle(color: Color(0xFF585858), fontSize: 15,),)
                            //   ),
                            // ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                            isVerify
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
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
                                          onPressed: () async {
                                            if (textEditingController
                                                .text.isEmpty) {
                                              showDialog(
                                                  context: context,
                                                  useSafeArea: false,
                                                  barrierDismissible: true,
                                                  builder:
                                                      (context) => WillPopScope(
                                                            onWillPop:
                                                                () async =>
                                                                    true,
                                                            child: StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return AlertDialog(
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height: size.height *
                                                                            0.07,
                                                                      ),
                                                                      Center(
                                                                          child:
                                                                              Text(
                                                                        'Verify Phone Number',
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF585858),
                                                                            fontSize:
                                                                                25,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )),
                                                                      SizedBox(
                                                                        height: size.height *
                                                                            0.025,
                                                                      ),
                                                                      Container(
                                                                        width: size.width *
                                                                            0.8,
                                                                        child: Center(
                                                                            child: Text(
                                                                          'Please enter code received on your given ${_countryDialCode.toString() + _phoneController.text.toString()} phone number.',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        )),
                                                                      ),
                                                                      SizedBox(
                                                                        height: size.height *
                                                                            0.05,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                16,
                                                                            right:
                                                                                16),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            boxShadow: [
                                                                              BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                                                            ],
                                                                            gradient:
                                                                                LinearGradient(
                                                                              begin: Alignment.topLeft,
                                                                              end: Alignment.bottomRight,
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
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
                                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                                  RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                  ),
                                                                                ),
                                                                                minimumSize: MaterialStateProperty.all(Size(size.width, 50)),
                                                                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                                // elevation: MaterialStateProperty.all(3),
                                                                                shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                              ),
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                                //  await PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode!);
                                                                              },
                                                                              child: Text('Cancel', style: buttonStyle)),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: size.height *
                                                                            0.05,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                          ));
                                            } else {
                                              setState(() {
                                                isVerify = true;
                                              });
                                              FirebaseAuth auth =
                                                  FirebaseAuth.instance;

                                              smsCode = textEditingController
                                                  .text
                                                  .trim();

                                              try {
                                                auth
                                                    .signInWithCredential(
                                                        await PhoneAuthProvider
                                                            .credential(
                                                                verificationId:
                                                                    verificationId!,
                                                                smsCode:
                                                                    smsCode!))
                                                    .then((UserCredential
                                                        result) {
                                                  setState(() {
                                                    isVerify = false;
                                                  });

                                                  if (result.user != null) {
                                                    prefs.setString(
                                                        'userPhone',
                                                        _countryDialCode! +
                                                            _phoneController
                                                                .text
                                                                .trim());
                                                    if (isCategoryExists ==
                                                        'yes') {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LoginScreen()));
                                                    } else {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ChosseRestaurantScreen(
                                                                    phone: _countryDialCode! +
                                                                        _phoneController
                                                                            .text
                                                                            .trim(),
                                                                  )));
                                                    }
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        useSafeArea: false,
                                                        barrierDismissible:
                                                            true,
                                                        builder:
                                                            (context) =>
                                                                WillPopScope(
                                                                  onWillPop:
                                                                      () async =>
                                                                          true,
                                                                  child: StatefulBuilder(
                                                                      builder:
                                                                          (context,
                                                                              setState) {
                                                                    return AlertDialog(
                                                                      insetPadding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      content:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            SizedBox(
                                                                              height: size.height * 0.07,
                                                                            ),
                                                                            Center(
                                                                                child: Text(
                                                                              'Verify Phone Number',
                                                                              style: TextStyle(color: Color(0xFF585858), fontSize: 25, fontWeight: FontWeight.bold),
                                                                            )),
                                                                            SizedBox(
                                                                              height: size.height * 0.025,
                                                                            ),
                                                                            Container(
                                                                              width: size.width * 0.8,
                                                                              child: Center(
                                                                                  child: Text(
                                                                                'Wrong code',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.red,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              )),
                                                                            ),
                                                                            SizedBox(
                                                                              height: size.height * 0.05,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 16, right: 16),
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  boxShadow: [
                                                                                    BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                                                                  ],
                                                                                  gradient: LinearGradient(
                                                                                    begin: Alignment.topLeft,
                                                                                    end: Alignment.bottomRight,
                                                                                    stops: [
                                                                                      0.0,
                                                                                      1.0
                                                                                    ],
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
                                                                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                                      // elevation: MaterialStateProperty.all(3),
                                                                                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                                    ),
                                                                                    onPressed: () async {
                                                                                      Navigator.pop(context);
                                                                                      //  await PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode!);
                                                                                    },
                                                                                    child: Text('Cancel', style: buttonStyle)),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: size.height * 0.05,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                                ));

                                                    // var snackBar = SnackBar(
                                                    //     backgroundColor: Colors.red,
                                                    //     content: Text('Wrong code try again',style: TextStyle(color: Colors.white),));
                                                    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  }
                                                }).catchError((e) {
                                                  print(e);
                                                  setState(() {
                                                    isVerify = false;
                                                  });
                                                  showDialog(
                                                      context: context,
                                                      useSafeArea: false,
                                                      barrierDismissible: true,
                                                      builder:
                                                          (context) =>
                                                              WillPopScope(
                                                                onWillPop:
                                                                    () async =>
                                                                        true,
                                                                child: StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                  return AlertDialog(
                                                                    insetPadding:
                                                                        EdgeInsets
                                                                            .all(0),
                                                                    content:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                size.height * 0.07,
                                                                          ),
                                                                          Center(
                                                                              child: Text(
                                                                            'Verify Phone Number',
                                                                            style: TextStyle(
                                                                                color: Color(0xFF585858),
                                                                                fontSize: 25,
                                                                                fontWeight: FontWeight.bold),
                                                                          )),
                                                                          SizedBox(
                                                                            height:
                                                                                size.height * 0.025,
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                size.width * 0.8,
                                                                            child: Center(
                                                                                child: Text(
                                                                              'Wrong code',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontSize: 14,
                                                                              ),
                                                                            )),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                size.height * 0.05,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 16, right: 16),
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(
                                                                                boxShadow: [
                                                                                  BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                                                                ],
                                                                                gradient: LinearGradient(
                                                                                  begin: Alignment.topLeft,
                                                                                  end: Alignment.bottomRight,
                                                                                  stops: [
                                                                                    0.0,
                                                                                    1.0
                                                                                  ],
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
                                                                                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                                    // elevation: MaterialStateProperty.all(3),
                                                                                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                                  ),
                                                                                  onPressed: () async {
                                                                                    Navigator.pop(context);
                                                                                    //  await PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode!);
                                                                                  },
                                                                                  child: Text('Cancel', style: buttonStyle)),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                size.height * 0.05,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                              ));
                                                  // var snackBar = SnackBar(
                                                  //     backgroundColor: Colors.red,
                                                  //     content: Text('Wrong code',style: TextStyle(color: Colors.white),));
                                                  // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                });
                                              } catch (e) {
                                                setState(() {
                                                  isVerify = false;
                                                });

                                                showDialog(
                                                    context: context,
                                                    useSafeArea: false,
                                                    barrierDismissible: true,
                                                    builder:
                                                        (context) =>
                                                            WillPopScope(
                                                              onWillPop:
                                                                  () async =>
                                                                      true,
                                                              child: StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                return AlertDialog(
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              size.height * 0.07,
                                                                        ),
                                                                        Center(
                                                                            child:
                                                                                Text(
                                                                          'Verify Phone Number',
                                                                          style: TextStyle(
                                                                              color: Color(0xFF585858),
                                                                              fontSize: 25,
                                                                              fontWeight: FontWeight.bold),
                                                                        )),
                                                                        SizedBox(
                                                                          height:
                                                                              size.height * 0.025,
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              size.width * 0.8,
                                                                          child: Center(
                                                                              child: Text(
                                                                            'Wrong code',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: 14,
                                                                            ),
                                                                          )),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              size.height * 0.05,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 16,
                                                                              right: 16),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              boxShadow: [
                                                                                BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                                                                              ],
                                                                              gradient: LinearGradient(
                                                                                begin: Alignment.topLeft,
                                                                                end: Alignment.bottomRight,
                                                                                stops: [
                                                                                  0.0,
                                                                                  1.0
                                                                                ],
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
                                                                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                                                  // elevation: MaterialStateProperty.all(3),
                                                                                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                                                                                ),
                                                                                onPressed: () async {
                                                                                  Navigator.pop(context);
                                                                                  //  await PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode!);
                                                                                },
                                                                                child: Text('Cancel', style: buttonStyle)),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              size.height * 0.05,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                            ));

                                                // var snackBar = SnackBar(
                                                //     backgroundColor: Colors.red,
                                                //     content: Text('Wrong code',style: TextStyle(color: Colors.white),));
                                                // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              }
                                            }

                                            //  await PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: smsCode!);
                                          },
                                          child: Text('Verify',
                                              style: buttonStyle)),
                                    ),
                                  ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          isLoadingDialog = false;
        });
        verificationId = verificationId;
        print(verificationId);
        print('WE are here in code sent codeAutoRetrievalTimeout');
        print("Timout");
      },
      verificationCompleted: (AuthCredential authCredential) {
        print('WE are here in code sent verificationCompleted');

        _auth
            .signInWithCredential(authCredential)
            .then((UserCredential result) {
          if (isCategoryExists == 'yes') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChosseRestaurantScreen(
                          phone:
                              _countryDialCode! + _phoneController.text.trim(),
                        )));
          }
        }).catchError((e) {
          print(e);
        });
      },
    );
  }

// AIzaSyCQ2UhiAGUD_nqAQmOI4at__8EtBBHdy6E
  // void _login(AuthController authController, String countryDialCode) async {
  //   String _phone = _phoneController.text.trim();
  //   String _password = _passwordController.text.trim();
  //   String _numberWithCountryCode = countryDialCode+_phone;
  //   bool _isValid = GetPlatform.isWeb ? true : false;
  //   if(!GetPlatform.isWeb) {
  //     try {
  //       PhoneNumber phoneNumber = await PhoneNumberUtil().parse(_numberWithCountryCode);
  //       _numberWithCountryCode = '+' + phoneNumber.countryCode + phoneNumber.nationalNumber;
  //       _isValid = true;
  //     } catch (e) {}
  //   }
  //   if (_phone.isEmpty) {
  //     showCustomSnackBar('enter_phone_number'.tr);
  //   }else if (!_isValid) {
  //     showCustomSnackBar('invalid_phone_number'.tr);
  //   }else if (_password.isEmpty) {
  //     showCustomSnackBar('enter_password'.tr);
  //   }else if (_password.length < 6) {
  //     showCustomSnackBar('password_should_be'.tr);
  //   }else {
  //     authController.login(_numberWithCountryCode, _password).then((status) async {
  //       if (status.isSuccess) {
  //         if (authController.isActiveRememberMe) {
  //           authController.saveUserNumberAndPassword(_phone, _password, countryDialCode);
  //         } else {
  //           authController.clearUserNumberAndPassword();
  //         }
  //         String _token = status.message.substring(1, status.message.length);
  //         if(Get.find<SplashController>().configModel.customerVerification && int.parse(status.message[0]) == 0) {
  //           List<int> _encoded = utf8.encode(_password);
  //           String _data = base64Encode(_encoded);
  //           Get.toNamed(RouteHelper.getVerificationRoute(_numberWithCountryCode, _token, RouteHelper.signUp, _data));
  //         }else {
  //           Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
  //         }
  //       }else {
  //         showCustomSnackBar(status.message);
  //       }
  //     });
  //   }
  // }
}
