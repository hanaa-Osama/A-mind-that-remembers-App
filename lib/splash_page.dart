import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_page.dart';
import 'register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _checkUser);
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPin = prefs.getString('userPin');

    if (!mounted) return;

    if (savedPin == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinPage()),
      );
    }
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.book_rounded,
                  size: 60,
                  color: roseGold,
                ),
              ),
              SizedBox(height: 28),
              Text(
                "لَحْظَةُ ذِكْرَى",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: purplePink,
                  letterSpacing: 1.2,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 12),
              Text(
                "✨ دَفْتَرُكَ اليَوْمِي… لَحَظَات لا تُنْسَى ✨",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
