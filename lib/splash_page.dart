import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'lib/services/local_auth_service.dart';

import 'pin_page.dart';
import 'register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final LocalAuthService _authService = LocalAuthService();
  bool _isAuthenticated = false; // Control UI rendering
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateOnStart();
    });
  }

  Future<void> _authenticateOnStart() async {
    final bool hasBiometric = await _authService.isBiometricAvailable();

    if (hasBiometric) {
      final bool isAuthenticated = await _authService.authenticate();

      if (isAuthenticated) {
        setState(() => _isAuthenticated = true);
        return;
      }
      // ❗ biometric failed → fallback to PIN
    }

    // 👇  PIN flow if user cancel biometric
    // await _checkUser();
  }

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

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

  // Future<void> _navigateSignedUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? savedPin = prefs.getString('userPin');
  //
  //   if (!mounted) return;
  //
  //   if (savedPin == null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const RegisterPage()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const HomePage()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Scaffold(body: splashView());
  }

  Widget splashView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [powderPink, warmBeige],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: Icon(Icons.book_rounded, size: 60, color: roseGold),
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
            SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB76E79), // roseGold
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'المتابعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
