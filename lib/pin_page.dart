import 'package:lahzet_zikry/translations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'verify_security.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final TextEditingController pinController = TextEditingController();
  String? savedPin;

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  @override
  void initState() {
    super.initState();
    loadSavedPin();
  }

  Future<void> loadSavedPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPin = prefs.getString("userPin");
    });
  }

  void checkPin() {
    String enteredPin = pinController.text.trim();

    if (enteredPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context, 'pin_4_digits'),
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
      );
      return;
    }

    if (enteredPin == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context, 'incorrect_pin'),
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        title: Text(
          S.of(context, 'login'),
          style: const TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: powderPink,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context, 'enter_pin'),
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: purplePink,
              ),
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 22,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: warmBeige,
                counterText: "",
                hintText: "••••",
                hintStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.grey,
                ),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: checkPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: roseGold,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  S.of(context, 'confirm'),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerifySecurityPage(),
                  ),
                );
              },
              child: Text(
                S.of(context, 'forgot_pin'),
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  color: roseGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
