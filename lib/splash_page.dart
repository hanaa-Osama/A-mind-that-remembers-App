import 'package:lahzet_zikry/translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lahzet_zikry/language_provider.dart';
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
  bool _isAuthenticated = false;

  // New calm color palette
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color softWhiteGray = Color(0xFFE8E8E8);
  static const Color mediumGray = Color(0xFF9E9E9E);

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
    }
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
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: darkBackground,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: softWhiteGray,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    return Scaffold(body: splashView());
  }

  Widget splashView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icons/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Image.asset(
                  'assets/icons/logo.png',
                  width: 120,
                  height: 120,
                ),

                const SizedBox(height: 32),

                // App Name
                Text(
                  S.of(context, 'my_memories'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: softWhiteGray,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  S.of(context, 'memories_subtitle'),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    color: softWhiteGray.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Single button at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: softWhiteGray,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: softWhiteGray.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        S.of(context, 'start_journey'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
            // زر تغيير اللغة
            Positioned(
              top: 10,
              left: 16,
              child: GestureDetector(
                onTap: () => _showLanguageMenu(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                  ),
                  child: const Icon(Icons.language, color: softWhiteGray, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final provider = Provider.of<LanguageProvider>(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              _buildLanguageOption(context, 'ar', S.of(context, 'arabic'), provider),
              _buildLanguageOption(context, 'en', S.of(context, 'english'), provider),
              _buildLanguageOption(context, 'tr', S.of(context, 'turkish'), provider),
              _buildLanguageOption(context, 'system', S.of(context, 'system_language'), provider),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String label, LanguageProvider provider) {
    bool isSelected = (code == 'system' && provider.locale == null) ||
        (provider.locale?.languageCode == code);
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : softWhiteGray.withOpacity(0.6),
          fontFamily: 'Tajawal',
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      onTap: () {
        provider.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}
