// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
//
// class UpdateProfileScreen extends StatefulWidget {
//   const UpdateProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
// }
//
// class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
//   final TextEditingController _emailAddressController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   String name = '', image = '';
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     getData();
//     setState(() {
//       image = '';
//       // _nameController.text =  'Miekie Jones';
//       // _emailAddressController.text =  'miekiejones24@gmail.com';
//       // _addressController.text =  '123 Street Hilton streets, USA';
//     });
//     super.initState();
//   }
//   getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // setState(() {
//     //   name =  prefs.getString('userName')!;
//     // });
//     //
//
//     if(prefs.getString('userName') != null) {
//       setState(() {
//         name =  prefs.getString('userName')!;
//         _nameController.text =  prefs.getString('userName')!;
//       });
//     }
//     if(prefs.getString('profileImage') != null) {
//       setState(() {
//         profileImage =  prefs.getString('profileImage')!;
//         image =  prefs.getString('profileImage')!;
//       });
//     }
//     if(prefs.getString('userAddress') != null) {
//       setState(() {
//         _addressController.text =  prefs.getString('userAddress')!;
//         //name =  prefs.getString('userName')!;
//       });
//     }
//     if(prefs.getString('userEmail') != null) {
//       setState(() {
//         _emailAddressController.text =  prefs.getString('userEmail')!;
//         //name =  prefs.getString('userName')!;
//       });
//     }
//
//
//   }
//
//   PickedFile? _pickedFile;
//   File? imageFile;
//   bool isLoading = false;
//   bool isLoadingImage = false;
//
//   //final FirebaseAuth auth = FirebaseAuth.instance;
//   String? profileImage = '', docId, userType, driverEmail = '', driverName = '', driverUid = '';
//
//   void _showPicker(context) {
//     showModalBottomSheet(
//         backgroundColor: Colors.white,
//         context: context,
//         builder: (BuildContext bc) {
//           return SafeArea(
//             child: Container(
//               child: new Wrap(
//                 children: <Widget>[
//                   new ListTile(
//                       leading: new Icon(Icons.photo_library),
//                       title: new Text('Photo Library'),
//                       onTap: () {
//
//                         _imgFromGallery();
//                         setState(() {
//                           isLoadingImage = true;
//                         });
//                         Navigator.of(context).pop();
//                       }),
//                   new ListTile(
//                     leading: new Icon(Icons.photo_camera),
//                     title: new Text('Camera'),
//                     onTap: () {
//                       _imgFromCamera();
//                       setState(() {
//                         isLoadingImage = true;
//                       });
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   _imgFromCamera() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     _pickedFile = (await ImagePicker.platform
//         .pickImage(source: ImageSource.camera, imageQuality: 50))!;
//
//     getUrl(_pickedFile!.path).then((value) {
//       if (value != null) {
//         setState(() {
//           profileImage = value.toString();
//           prefs.setString('profileImage', profileImage.toString());
//           isLoadingImage = false;
//         });
//
//       } else {
//         setState(() {
//           isLoadingImage = false;
//         });
//         print('sorry error');
//       }
//     });
//
//     setState(() {
//       imageFile = File(_pickedFile!.path);
//       image = 'done';
//      // isLoadingImage = false;
//       print('List Printed');
//
//     });
//   }
//
//   _imgFromGallery() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//
//     _pickedFile = (await ImagePicker.platform
//         .pickImage(source: ImageSource.gallery, imageQuality: 50))!;
//     getUrl(_pickedFile!.path).then((value) {
//       if (value != null) {
//         setState(() {
//           profileImage = value.toString();
//           prefs.setString('profileImage', profileImage.toString());
//           isLoadingImage = false;
//         });
//
//       } else {
//         setState(() {
//           isLoadingImage = false;
//         });
//         print('sorry error');
//       }
//     });
//     setState(() {
//       imageFile = File(_pickedFile!.path);
//     //  isLoadingImage = false;
//       image = 'done';
//       print('List Printed');
//
//     });
//   }
//
//   Future<String?> getUrl(String path) async {
//     final file = File(path);
//     TaskSnapshot snapshot = await FirebaseStorage.instance
//         .ref()
//         .child("image" + DateTime.now().toString())
//         .putFile(file);
//     if (snapshot.state == TaskState.success) {
//       return await snapshot.ref.getDownloadURL();
//     }
//
//   }
//
//   // updateProfile() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //
//   //   var headers = {
//   //     'Cookie': 'restaurant_session=$cookie'
//   //   };
//   //   var request = http.MultipartRequest('POST', Uri.parse('https://restaurant.wettlanoneinc.com/api/edit_user'));
//   //   request.fields.addAll({
//   //     'name': '${_nameController.text.toString()}'
//   //   });
//   //   request.files.add(await http.MultipartFile.fromPath('image', _pickedFile!.path.toString()));
//   //   request.headers.addAll(headers);
//   //
//   //   http.StreamedResponse response = await request.send();
//   //
//   //   if (response.statusCode == 200) {
//   //     FirebaseFirestore.instance.collection('userImage').doc(prefs.getString('userId')).set({
//   //       'userId':prefs.getString('userId'),
//   //       'image':profileImage.toString(),
//   //     });
//   //     print('this is 200');
//   //     print(await response.stream.bytesToString());
//   //     setState(() {
//   //       name = _nameController.text.toString();
//   //       isLoading = false;
//   //     });
//   //
//   //     var snackBar = SnackBar(content: Text('User Updated successfully'
//   //       ,style: TextStyle(color: Colors.white),),
//   //       backgroundColor: Colors.green,
//   //     );
//   //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   //     Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => DashBoardScreen(index:2)));
//   //   }
//   //   else {
//   //     FirebaseFirestore.instance.collection('userImage').doc(prefs.getString('userId')).set({
//   //       'userId':prefs.getString('userId'),
//   //       'image':profileImage.toString(),
//   //     });
//   //     print('this is else');
//   //     print(response.reasonPhrase);
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //     final responseData = await response.stream.bytesToString();
//   //     final data = json.decode(responseData);
//   //
//   //     if(data['message'] == "Please login first")  {
//   //       var snackBar = SnackBar(content: Text('${response.statusCode} Please login first'
//   //         ,style: TextStyle(color: Colors.white),),
//   //         backgroundColor: Colors.green,
//   //       );
//   //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   //     }
//   //   }
//   //   // var headers = {
//   //   //   'Cookie': 'restaurant_session=$Cookie'
//   //   // };
//   //   // var request = http.Request('POST', Uri.parse('https://restaurant.wettlanoneinc.com/api/edit_user?name=${_nameController.text.toString()}&image=https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png'));
//   //   //
//   //   // request.headers.addAll(headers);
//   //   //
//   //   // http.StreamedResponse response = await request.send();
//   //   //
//   //   // if (response.statusCode == 200) {
//   //   //   print('this is 200');
//   //   //   print(await response.stream.bytesToString());
//   //   //   setState(() {
//   //   //     name = _nameController.text.toString();
//   //   //     isLoading = false;
//   //   //   });
//   //   //
//   //   //   var snackBar = SnackBar(content: Text('Successfully updated'
//   //   //     ,style: TextStyle(color: Colors.white),),
//   //   //     backgroundColor: Colors.green,
//   //   //   );
//   //   //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   //   // }
//   //   // else {
//   //   //   print('this is else');
//   //   //   print(response.reasonPhrase);
//   //   //   setState(() {
//   //   //     isLoading = false;
//   //   //   });
//   //   //   final responseData = await response.stream.bytesToString();
//   //   //   final data = json.decode(responseData);
//   //   //
//   //   //   if(data['message'] == "Please login first")  {
//   //   //     var snackBar = SnackBar(content: Text('${response.statusCode} Please login first'
//   //   //       ,style: TextStyle(color: Colors.white),),
//   //   //       backgroundColor: Colors.green,
//   //   //     );
//   //   //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   //   //     // Navigator.push(
//   //   //     //   context,
//   //   //     //   MaterialPageRoute(builder: (context) => LoginScreen()),
//   //   //     // );
//   //   //   }
//   //   //
//   //   // //  print(await response.stream.bytesToString());
//   //   //
//   //   //
//   //   // }
//   // }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         title: Text(
//           'Edit Profile',
//           style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
//         ),
//         leading: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//               // Scaffold.of(context).openDrawer();
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(13.0),
//               child: Image.asset(
//                 'assets/images/arrow_back.png',
//                 height: 20,
//                 width: 20,
//                 fit: BoxFit.scaleDown,
//               ),
//             )),
//       ),
//       body: SingleChildScrollView(
//         child: Column(children: [
//
//           isLoadingImage ? Center(child: CircularProgressIndicator(
//             color: darkRedColor,
//             strokeWidth: 1,
//           )) :
//           Center(
//               child: Stack(children: [
//                 ClipOval( child:
//
//                 profileImage == '' ?
//
//                 Image.network(
//                   'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
//                       width: 120,
//                       height: 120,
//                       fit: BoxFit.cover,
//                     )
//                   : Image.network(profileImage.toString(),
//                   width: 120,
//                   height: 120,
//                   fit: BoxFit.cover,
//                 )
//                   ,
//
//                 ),
//                 Positioned(
//                   left: size.width * 0.2,
//                   top: size.height * 0.1,
//                   child: InkWell(
//                     onTap: () =>    _showPicker(context),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         // color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
//                         // border: Border.all(width: 1, color: Theme.of(context).primaryColor),
//                       ),
//                       child: Container(
//                         // height: 30,
//                         // width: 30,
//                         margin: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           //border: Border.all(width: 2, color: Colors.white),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Colors.black26, offset: Offset(0, 4), blurRadius: 2.0)
//                           ],
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(5.0),
//                             child: Image.asset(
//                               'assets/images/editProfile.png',
//                               width: 15,
//                               height: 15,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ])),
//
//           SizedBox(
//             height: size.height*0.01,
//           ),
//
//           Container(
//               width: size.width,
//               child: Center(
//                 child: Text('$name',
//                   style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
//                 ),
//               )),
//
//
//           SizedBox(
//             height: size.height*0.02,
//           ),
//
//           Container(
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(topRight: Radius.circular(30),
//                     topLeft: Radius.circular(30)
//                 )
//             ),
//             child: Column(
//               children: [
//
//                 SizedBox(
//                   height: size.height*0.03,
//                 ),
//
//
//
//
//                 Container(
//                   margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
//                   child: TextFormField(
//                     controller: _nameController,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black,
//
//                     ),
//                     onChanged: (value) {
//                       // setState(() {
//                       //   userInput.text = value.toString();
//                       // });
//                     },
//                     decoration: InputDecoration(
//                       //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
//                       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                       focusColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide:
//                         BorderSide(color: darkGreyTextColor1, width: 1.0),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       fillColor: Colors.grey,
//                       hintText: "",
//
//                       //make hint text
//                       hintStyle: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 16,
//                         fontFamily: "verdana_regular",
//                         fontWeight: FontWeight.w400,
//                       ),
//                       //create lable
//                       labelText: 'Full Name',
//                       //lable style
//                       labelStyle: TextStyle(
//                         color: darkRedColor,
//                         fontSize: 16,
//                         fontFamily: "verdana_regular",
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: size.height*0.02,
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
//                   child: TextFormField(
//                     controller: _emailAddressController,
//                     enabled: false,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black,
//
//                     ),
//                     onChanged: (value) {
//                       // setState(() {
//                       //   userInput.text = value.toString();
//                       // });
//                     },
//                     decoration: InputDecoration(
//                       //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
//                       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                       focusColor: Colors.white,
//                       //add prefix icon
//
//                       // errorText: "Error",
//
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//
//                       focusedBorder: OutlineInputBorder(
//                         borderSide:
//                         BorderSide(color: darkGreyTextColor1, width: 1.0),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       fillColor: Colors.grey,
//                       hintText: "",
//
//                       //make hint text
//                       hintStyle: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 16,
//                         fontFamily: "verdana_regular",
//                         fontWeight: FontWeight.w400,
//                       ),
//
//                       //create lable
//                       labelText: 'Email Address',
//                       //lable style
//                       labelStyle: TextStyle(
//                         color: darkRedColor,
//                         fontSize: 16,
//                         fontFamily: "verdana_regular",
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(
//                   height: size.height*0.02,
//                 ),
//
//                 Container(
//                   margin: EdgeInsets.only(left: 16,right: 16,bottom: 0),
//                   child: TextFormField(
//                     controller: _addressController,
//                     enabled: false,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black,
//
//                     ),
//                     onChanged: (value) {
//                       // setState(() {
//                       //   userInput.text = value.toString();
//                       // });
//                     },
//                     decoration: InputDecoration(
//                       //contentPadding: EdgeInsets.only(top: 15,bottom: 15),
//                       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                       focusColor: Colors.white,
//                       //add prefix icon
//
//                       // errorText: "Error",
//
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//
//                       focusedBorder: OutlineInputBorder(
//                         borderSide:
//                         BorderSide(color: darkGreyTextColor1, width: 1.0),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       fillColor: Colors.grey,
//                       hintText: "",
//
//                       //make hint text
//                       hintStyle: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 16,
//                         fontFamily: "verdana_regular",
//                         fontWeight: FontWeight.w400,
//                       ),
//
//                       //create lable
//                       labelText: 'Address',
//                       //lable style
//                       labelStyle: TextStyle(
//                         color: darkRedColor,
//                         fontSize: 16,
//                         fontFamily: "verdana_regular",
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(
//                   height: size.height*0.05,
//                 ),
//                 isLoading ? Center(child: CircularProgressIndicator(
//                   color: darkRedColor,
//                   strokeWidth: 1,
//                 )) :
//                 Padding(
//                   padding: const EdgeInsets.only(left: 16,right: 16),
//                   child: Container(
//
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
//                       ],
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         stops: [0.0, 1.0],
//                         colors: [
//                           darkRedColor,
//                           lightRedColor,
//
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: ElevatedButton(
//                         style: ButtonStyle(
//                           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           minimumSize: MaterialStateProperty.all(Size(size.width, 50)),
//                           backgroundColor:
//                           MaterialStateProperty.all(Colors.transparent),
//                           // elevation: MaterialStateProperty.all(3),
//                           shadowColor:
//                           MaterialStateProperty.all(Colors.transparent),
//                         ),
//
//                         onPressed: () {
//
//                           if(_nameController.text.isEmpty) {
//
//                             var snackBar = SnackBar(content: Text('Name is required'
//                               ,style: TextStyle(color: Colors.white),),
//                               backgroundColor: Colors.red,
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//
//                           }
//                           else if (image == '') {
//
//                             var snackBar = SnackBar(content: Text('Image is required'
//                               ,style: TextStyle(color: Colors.white),),
//                               backgroundColor: Colors.red,
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//
//                           } else {
//                             updateProfile();
//                           }
//
//                         }, child: Text('Update', style: buttonStyle)),
//                   ),
//                 ),
//                 SizedBox(
//                   height: size.height*0.1,
//                 ),
//               ],
//             ),
//
//           ),
//
//
//         ],),
//       ),
//     );
//   }
// }
