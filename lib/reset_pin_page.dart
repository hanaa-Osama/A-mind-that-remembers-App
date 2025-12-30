import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_page.dart';

class ResetPinPage extends StatefulWidget {
  const ResetPinPage({super.key});

  @override
  State<ResetPinPage> createState() => _ResetPinPageState();
}

class _ResetPinPageState extends State<ResetPinPage> {
  final TextEditingController pinController = TextEditingController();

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  Future<void> saveNewPin() async {
    String newPin = pinController.text.trim();

    if (newPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ يجب أن يكون الرمز 4 أرقام",
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userPin", newPin);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PinPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        backgroundColor: powderPink,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إعادة تعيين الرمز السري",
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              "أدخل الرمز السري الجديد:",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                color: purplePink,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 22,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: warmBeige,
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: roseGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: roseGold, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: saveNewPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: roseGold,
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "حفظ",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
