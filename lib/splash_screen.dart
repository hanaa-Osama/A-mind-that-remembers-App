import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color purplePink = Color(0xFFC48BCB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              powderPink,
              warmBeige,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            "لَحْظَةُ ذِكْرَى",
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: purplePink,
              letterSpacing: 1.1,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
