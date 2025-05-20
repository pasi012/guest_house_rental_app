import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:guest_house_rental_app/screens/home_page.dart';
import 'authentication/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  void _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      _checkUserLoginStatus();
    }
  }

  void _checkUserLoginStatus() async {
    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Check if a user is already signed in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // No user is signed in, navigate to the login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Internet Connection Lost"),
          content: const Text("Please connect to the internet."),
          actions: <Widget>[
            TextButton(
              child: const Text("Retry"),
              onPressed: () {
                Navigator.of(context).pop();
                _checkInternetConnection();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo here
            Image.asset(
              'assets/logo.png', // Ensure you have this image in your assets folder
              height: 100.0,
              width: 100.0,
              fit: BoxFit.fill,// Adjust the size as needed
            ),
            const SizedBox(height: 20.0),
            // Add the app name here
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Room Rent System',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Show a loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}