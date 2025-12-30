import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reset_pin_page.dart';

class VerifySecurityPage extends StatefulWidget {
  const VerifySecurityPage({super.key});

  @override
  State<VerifySecurityPage> createState() => _VerifySecurityPageState();
}

class _VerifySecurityPageState extends State<VerifySecurityPage> {
  List<String> savedQuestions = [];
  List<String> savedAnswers = [];
  List<TextEditingController> answersControllers = [];
  int? wrongAnswerIndex;

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  @override
  void initState() {
    super.initState();
    loadSecurityData();
  }

  Future<void> loadSecurityData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    savedQuestions = [
      prefs.getString("q0") ?? "",
      prefs.getString("q1") ?? "",
    ];

    savedAnswers = [
      prefs.getString("a0") ?? "",
      prefs.getString("a1") ?? "",
    ];

    answersControllers =
        List.generate(2, (index) => TextEditingController());

    setState(() {});
  }

  void verifyAnswers() {
    wrongAnswerIndex = null;

    for (int i = 0; i < 2; i++) {
      if (answersControllers[i].text.trim().isEmpty ||
          answersControllers[i].text.trim() != savedAnswers[i]) {
        wrongAnswerIndex = i;
        break;
      }
    }

    if (wrongAnswerIndex == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResetPinPage()),
      );
    } else {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ هناك إجابة غير صحيحة",
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
          "التحقق من الهوية",
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: savedQuestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "أجب عن أسئلة الأمان للمتابعة:",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  color: purplePink,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 25),
              for (int i = 0; i < 2; i++) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    savedQuestions[i],
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      color: wrongAnswerIndex == i
                          ? Colors.red
                          : Colors.grey[800],
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: answersControllers[i],
                  textDirection: TextDirection.rtl,
                  style:
                  const TextStyle(fontFamily: 'Tajawal'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: warmBeige,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: wrongAnswerIndex == i
                            ? Colors.red
                            : roseGold,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: wrongAnswerIndex == i
                            ? Colors.red
                            : roseGold,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: verifyAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: roseGold,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "تأكيد",
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
      ),
    );
  }
}
