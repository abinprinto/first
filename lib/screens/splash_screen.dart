import 'dart:async';
import 'package:first/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class CartifySplashScreen extends StatefulWidget {
  @override
  _CartifySplashScreenState createState() => _CartifySplashScreenState();
}

class _CartifySplashScreenState extends State<CartifySplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Page background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Enlarged App Icon
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 3),
              child: const Icon(
                Icons.shopping_cart,
                color:Color.fromARGB(228, 29, 62, 41),
                size: 100, // Increased size of the icon
              ),
            ),
            const SizedBox(height: 10),
            // App Name
            const Text(
              'Cartify',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(228, 29, 62, 41),
              ),
            ),
            const SizedBox(height: 30),

            const CircularProgressIndicator(
              color: Color.fromARGB(228, 29, 62, 41), // Match the theme
              strokeWidth: 3, // Adjust thickness
            ),
          ],
        ),
      ),
    );
  }
}
