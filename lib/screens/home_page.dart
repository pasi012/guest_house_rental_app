import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guest_house_rental_app/authentication/report_login_screen.dart';
import 'package:guest_house_rental_app/screens/charges_and_expenses_screen.dart';
import 'package:guest_house_rental_app/screens/guest_register_screen.dart';
import 'room_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const GuestRegisterScreen(),
    const ReportLoginScreen(),
    const ChargesAndExpensesScreen(),
    //const RoomStatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    ScreenUtil.init(context);

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration, size: 24.sp,),
            label: 'Guest Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.event_note_outlined,
              size: 24.sp, // Responsive icon size
            ),
            label: 'Daily Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_link,
              size: 24.sp, // Responsive icon size
            ),
            label: 'Charges',
          ),
        ],
        selectedLabelStyle: TextStyle(fontSize: 14.sp), // Responsive font size
        unselectedLabelStyle: TextStyle(fontSize: 12.sp), // Responsive font size
      ),
    );
  }
}