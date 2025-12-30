import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  final List<String> selectedQuestions = const [
    "ما هو فريقك المفضل؟",
    "ما هو المكان الذي تشعر فيه بالراحة دائمًا؟",
  ];

  final List<TextEditingController> answerControllers =
  List.generate(2, (_) => TextEditingController());

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  Future<void> saveUser() async {
    final String name = nameController.text.trim();
    final String pin = pinController.text.trim();

    final bool validPin = RegExp(r'^\d{4}$').hasMatch(pin);

    if (name.isEmpty || !validPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❗ الرجاء إدخال الاسم و PIN مكوّن من 4 أرقام فقط",
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    for (int i = 0; i < 2; i++) {
      if (answerControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❗ يجب الإجابة على السؤال رقم ${i + 1}",
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("userName", name);
    await prefs.setString("userPin", pin);

    for (int i = 0; i < 2; i++) {
      await prefs.setString("q$i", selectedQuestions[i]);
      await prefs.setString("a$i", answerControllers[i].text.trim());
    }

    await prefs.remove("q2");
    await prefs.remove("a2");

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
          "تسجيل مستخدم جديد",
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _title("أدخل اسمك"),
            _field(nameController),
            const SizedBox(height: 25),
            _title("أدخل رمز PIN (٤ أرقام)"),
            TextField(
              controller: pinController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 20,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: _inputDecoration(counter: true).copyWith(
                hintText: "••••",
              ),
            ),
            const SizedBox(height: 25),
            _title("أسئلة الأمان:"),
            const SizedBox(height: 10),
            for (int i = 0; i < 2; i++) ...[
              Text(
                selectedQuestions[i],
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              _field(answerControllers[i]),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: saveUser,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: purplePink,
      ),
      textDirection: TextDirection.rtl,
    );
  }

  Widget _field(TextEditingController controller) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'Tajawal'),
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration({bool counter = false}) {
    return InputDecoration(
      counterText: counter ? "" : null,
      filled: true,
      fillColor: warmBeige,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: roseGold),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: roseGold, width: 2),
      ),
    );
  }
}
