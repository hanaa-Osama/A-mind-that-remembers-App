import 'package:lahzet_zikry/translations.dart';
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

  List<String> getSelectedQuestions(BuildContext context) => [
    S.of(context, 'question_team'),
    S.of(context, 'question_place'),
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
        SnackBar(
          content: Text(
            S.of(context, 'name_pin_required'),
            style: const TextStyle(fontFamily: 'Tajawal'),
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
              "${S.of(context, 'answer_question_prefix')}${i + 1}",
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

    final questions = getSelectedQuestions(context);
    for (int i = 0; i < 2; i++) {
      await prefs.setString("q$i", questions[i]);
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
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        backgroundColor: powderPink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context, 'register_new_user'),
          style: const TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _title(S.of(context, 'enter_name'), isRtl),
            _field(nameController, isRtl),
            const SizedBox(height: 25),
            _title(S.of(context, 'enter_pin_4_digits'), isRtl),
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
            _title(S.of(context, 'security_questions_title'), isRtl),
            const SizedBox(height: 10),
            for (int i = 0; i < 2; i++) ...[
              Text(
                getSelectedQuestions(context)[i],
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 8),
              _field(answerControllers[i], isRtl),
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
                child: Text(
                  S.of(context, 'save'),
                  style: const TextStyle(
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

  Widget _title(String text, bool isRtl) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: purplePink,
      ),
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  Widget _field(TextEditingController controller, bool isRtl) {
    return TextField(
      controller: controller,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
