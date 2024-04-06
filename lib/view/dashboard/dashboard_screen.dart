import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:honchos_restaurant_app/view/home/home_screen.dart';
import 'package:honchos_restaurant_app/view/profile/profile_screen.dart';
import 'package:honchos_restaurant_app/view/profile/update_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoardScreen extends StatefulWidget {
  final int index;
  const DashBoardScreen({Key? key, required this.index}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = [
    RestaurantHomeScreen(),

    ProfileScreen(), //  More(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    //  cartController.getBanners();
    if(widget.index == 0) {
      setState(() {
        _selectedIndex = 0;
        _pages[0] = RestaurantHomeScreen();
      });
    }
    // else if(widget.index == 1) {
    //
    //   setState(() {
    //     _selectedIndex = 1;
    //     _pages[1] = SearchScreen();
    //   });
    // }

    else if(widget.index == 1) {

      setState(() {
        _selectedIndex = 1;
        _pages[1] = ProfileScreen();
      });
    }
    else if(widget.index == 5) {

      // setState(() {
      //   _selectedIndex = 2;
      //   _pages[2] = CheckOutScreen();
      // });
    }
    else if(widget.index == 6) {

      setState(() {
        // _selectedIndex = 2;
        // _pages[2] = UpdateProfileScreen();
      });
    }


    super.initState();


  }



  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return WillPopScope(
      onWillPop:  showExitPopup,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _pages.elementAt(_selectedIndex),
        bottomNavigationBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: BottomAppBar(

            color: Colors.white,
            child: Container(
              // height: 55,
              //  color: Colors.white,
              child: SizedBox(
                // height: 70,
                child: CupertinoTabBar(
                  inactiveColor: darkRedColor,
                  activeColor: Colors.black,
                  currentIndex: _selectedIndex,
                  backgroundColor: Colors.white,
                  border: Border.all(color: Colors.white),
                  // iconSize: 40,
                  onTap: _onItemTapped,
                  items: [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 0,top: 4),
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 0;
                                _pages[0] = RestaurantHomeScreen();
                              });
                            },
                            child:
                            _selectedIndex == 0 ?  Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/selectedHome.png',
                                  width: 25,height: 25,fit: BoxFit.scaleDown,
                                  color: darkRedColor,
                                  //  color: _selectedIndex == 0 ? darkRedColor : darkGreyTextColor1 ,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                      color: darkRedColor,
                                    ),
                                    width: 25,
                                    height: 3,

                                  ),
                                ),
                              ],
                            ):
                            Image.asset('assets/images/home.png', width: 25,height: 25,fit: BoxFit.scaleDown,
                              color: _selectedIndex == 0 ? darkRedColor : darkGreyTextColor1 ,
                            )
                        ),
                      ),
                      // label: '',
                    ),

                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 0,top: 4),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                              _pages[1] = ProfileScreen();
                            });
                          },
                          child:
                          _selectedIndex == 1 ?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/selectedUser.png', width: 25,height: 25,fit: BoxFit.scaleDown,
                                color: darkRedColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                    color: darkRedColor,
                                  ),
                                  width: 25,
                                  height: 3,

                                ),
                              ),
                            ],
                          )
                              :
                          Image.asset('assets/images/user.png', width: 25,height: 25,fit: BoxFit.scaleDown,
                            color: _selectedIndex == 1 ? darkRedColor : darkGreyTextColor1  ,
                          ),
                        ),
                      ),
                      // label: '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<bool> showExitPopup() async {

    if(_selectedIndex == 0) {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit the App?'),
          actions:[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },



              //return true when click on "Yes"
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              child:Text('Yes'),
            ),

          ],
        ),
      )??false;
    } else {
      setState(() {
        _selectedIndex = 0;
      });
      return false;

    }

    //if showDialouge had returned null, then return false
  }

}
