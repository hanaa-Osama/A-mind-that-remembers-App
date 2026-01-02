import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lib/widgets/delete_alert_dialog.dart';

class FadfadlyPage extends StatefulWidget {
  const FadfadlyPage({super.key});

  @override
  State<FadfadlyPage> createState() => _FadfadlyPageState();
}

class _FadfadlyPageState extends State<FadfadlyPage> {
  String? selectedMood;
  String? selectedQuestion;

  final TextEditingController answerController = TextEditingController();
  final TextEditingController journalController = TextEditingController();

  bool showHistory = false;
  List<Map<String, dynamic>> savedEntries = [];

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  final Map<String, String> moodEmojis = {
    "سعيد": "😄",
    "عادي": "🙂",
    "حزين": "😢",
    "متوتر": "😰",
    "متحمّس": "🤩",
    "مرهق": "😫",
  };

  final Map<String, List<String>> moodQuestions = {
    "سعيد": [
      "ما أكثر شيء جعلك تبتسم اليوم؟",
      "ما لحظة صغيرة أسعدتك بدون توقع؟",
      "من الشخص الذي أشعرك بالراحة اليوم؟",
      "ما الخبر أو الرسالة التي فرحتك؟",
      "ما أجمل مجاملة سمعتها أو قلتها؟",
      "ما شيء فعلته وجعلك فخورًا بنفسك؟",
      "كيف تصف سعادتك الآن؟",
      "ما أكثر شيء ممتن له اليوم؟",
      "ما نشاط منحك طاقة إيجابية؟",
      "ما موقف بسيط جعلك تشعر بالرضا؟",
      "ما أكثر شيء استمتعت به اليوم؟",
      "ما قرار صغير أسعدك؟",
      "ما المكان الذي شعرت فيه بالراحة؟",
      "ما الموسيقى التي رفعت مزاجك؟",
      "ما الذي أضحكك من قلبك؟",
      "ما إنجازك اليوم حتى لو بسيط؟",
      "ما عادة جميلة تحب تكرارها؟",
      "ما لحظة شعرت فيها بالسلام؟",
      "ما أجمل شيء لاحظته اليوم؟",
      "كيف تحب أن تحتفل بسعادتك؟",
      "ما شيء جميل حدث ويستحق الشكر؟",
      "من تحب مشاركة فرحتك معه؟",
      "ما ذكرى جميلة حضرت في بالك؟",
      "ما الذي جعل يومك أخف؟",
      "ما خطوة قادمة تشعرك بالحماس؟",
      "ما موقف جعلك تشعر بالامتنان؟",
      "ما أفضل جزء في يومك؟",
      "ما شيء تحب أن يتكرر غدًا؟",
      "ما موقف شعرت فيه بالمحبة؟",
      "ما شيء تعلمته وكان مفرحًا؟",
      "ما لحظة شعرت فيها بالرضا؟",
      "ما تصرف لطيف قمت به؟",
      "ما هدية قدمتها لنفسك؟",
      "ما روتين بسيط أسعدك؟",
      "ما هدف تشعر أنك اقتربت منه؟",
      "ما صفة جميلة لاحظتها في نفسك؟",
      "ما موقف جعلك تثق بنفسك؟",
      "ما شعور إيجابي يرافقك الآن؟",
      "ما شيء جعلك تشعر بالطمأنينة؟",
      "ما مفاجأة لطيفة حدثت؟",
      "ما رسالة شكر تحب قولها لليوم؟",
      "ما تصرف لطيف تلقيته؟",
      "ما ذكرى تحب الاحتفاظ بها؟",
      "ما طاقة إيجابية تحب نشرها؟",
      "ما لحظة شعرت فيها بالسهولة؟",
      "ما شيء جميل رغم بساطته؟",
      "ما كلمة طيبة قلتها لنفسك؟",
      "ما شعور يجعلك مرتاحًا؟",
      "ما أمنية بسيطة تحققت؟",
    ],
    "عادي": [
      "كيف كان يومك بشكل عام؟",
      "ما أكثر شيء شغل تفكيرك؟",
      "ما نشاط قمت به بشكل روتيني؟",
      "ما شيء كان يمكن أن يكون أفضل؟",
      "ما لحظة شعرت فيها بالهدوء؟",
      "ما الذي استغرق أغلب وقتك؟",
      "ما عادة مارستها دون انتباه؟",
      "ما قرار بسيط اتخذته؟",
      "ما مهمة أنهيتها اليوم؟",
      "ما شيء كان عاديًا لكنه مهم؟",
      "ما أمر أجلته؟",
      "ما لحظة شعرت فيها بالتركيز؟",
      "ما لحظة شعرت فيها بالملل؟",
      "ما موقف جعلك تفكر؟",
      "ما تغيير بسيط حدث في روتينك؟",
      "ما شيء تحب تحسينه غدًا؟",
      "ما أمر يحتاج تنظيمًا؟",
      "ما شيء تحب التقليل منه؟",
      "ما شيء تحب زيادته؟",
      "ما الذي كان ينقص يومك؟",
      "ما درس بسيط تعلمته؟",
      "ما الذي كان أسهل مما توقعت؟",
      "ما الذي كان أصعب مما توقعت؟",
      "ما أمر لم يكن له تأثير؟",
      "ما شيء يستحق وقتك أكثر؟",
      "ما شيء استهلك وقتك بلا فائدة؟",
      "ما لحظة شعرت فيها بالرضا؟",
      "ما لحظة شعرت فيها بالعجلة؟",
      "ما شيء تحب فعله بطريقة أفضل؟",
      "ما قرار تحب مراجعته؟",
      "ما شيء استنزف طاقتك بهدوء؟",
      "ما حديث أثر في يومك؟",
      "ما خبر مر عليك؟",
      "ما نشاط أحببت فعله وحدك؟",
      "ما نشاط أحببت فعله مع غيرك؟",
      "ما أمر يحتاج أولوية؟",
      "ما لحظة شعرت فيها بالتوازن؟",
      "ما شيء كان مقبولًا دون تفاصيل؟",
      "ما أمر تحب فهمه عن نفسك؟",
      "ما سؤال دار في ذهنك؟",
      "ما لحظة جميلة مرت سريعًا؟",
      "ما شيء كنت تحتاجه؟",
      "ما عادة تحب البدء بها؟",
      "ما عادة تحب التوقف عنها؟",
      "ما أمر يحتاج حدودًا أوضح؟",
      "ما أمر يحتاج مساحة أكبر؟",
      "ما شيء كنت تتجنبه؟",
      "ما تصرف يجعلك أكثر راحة الآن؟",
      "ما شيء تحب وجوده في يومك؟",
      "ما شيء لا تحب تكراره؟",
    ],
    "حزين": [
      "ما الذي أثقل قلبك اليوم؟",
      "ما موقف جعلك تشعر بالحزن؟",
      "ما شيء افتقدته؟",
      "ما فكرة حزينة تكررت؟",
      "ما الذي تحب أن يفهمه الآخرون عن حزنك؟",
      "ما كلمة كنت تحتاج سماعها؟",
      "ما شيء تمنيت حدوثه ولم يحدث؟",
      "ما جزء من يومك كان صعبًا؟",
      "ما كلمة أثرت فيك سلبًا؟",
      "ما موقف أشعرك بالوحدة؟",
      "ما شيء كنت تحتاج فيه دعمًا؟",
      "ما أمر تلوم نفسك عليه؟",
      "ما شيء تحب أن تسامح نفسك عليه؟",
      "ما شعور تخشى الاعتراف به؟",
      "ما فضفضة تحتاج إخراجها؟",
      "ما ذكرى مؤلمة عادت إليك؟",
      "ما شيء قد يخفف حزنك؟",
      "من الشخص الذي يمكنك اللجوء إليه؟",
      "ما موقف جعلك تشعر بالانكسار؟",
      "ما شيء تحب إصلاحه؟",
      "ما موقف شعرت فيه بعدم الفهم؟",
      "ما إحساس بالرفض مررت به؟",
      "ما شيء تحب تعويضه؟",
      "ما الذي يحتاجه قلبك الآن؟",
      "ما الذي يساعدك وقت الحزن؟",
      "ما الذي يزيد حزنك؟",
      "ما حزن قديم عاد للظهور؟",
      "ما شيء تحب التحرر منه؟",
      "ما شيء تتمسك به رغم الحزن؟",
      "ما رسالة تحب قولها لنفسك؟",
      "ما أمر تحب تقبله؟",
      "ما شيء يحتاج شفاء؟",
      "ما شعور يحتاج احتواء؟",
      "ما خطوة صغيرة قد تهون عليك؟",
      "ما رسالة دعم تحب سماعها؟",
      "ما أمر تحب إنهاءه؟",
      "ما بداية جديدة تحتاجها؟",
      "ما موقف شعرت فيه بالظلم؟",
      "ما تغيير تحبه في ظروفك؟",
      "ما شعور بالعجز مررت به؟",
      "ما وعد تحب منحه لنفسك؟",
      "ما كلمة طيبة تستحق قولها لنفسك؟",
      "ما شيء تحب فعله لتشعر بالراحة؟",
      "ما عبء تحب تخفيفه؟",
      "ما أمر يمنحك الأمان؟",
      "من أقرب شخص للدعم؟",
      "ما خطوة بسيطة تخفف الألم؟",
      "ما إحساس يحتاج وقتًا؟",
      "ما شيء تحب مشاركته؟",
    ],
    "متوتر": [
      "ما أكثر شيء يسبب لك التوتر الآن؟",
      "ما فكرة تثير القلق داخلك؟",
      "ما أمر خارج عن سيطرتك؟",
      "ما شيء يمكنك التحكم فيه؟",
      "ما أول علامة تشعر بها عند التوتر؟",
      "ما أمر يحتاج تبسيطًا؟",
      "ما خطوة صغيرة قد تهدئك؟",
      "ما التزام يضغط عليك؟",
      "ما شخص أو موقف يربكك؟",
      "ما قرار متردد فيه؟",
      "ما أمر تؤجله ويسبب توترًا؟",
      "ما جزء من يومك كان مرهقًا؟",
      "ما مصدر التوتر الأساسي؟",
      "ما شعور تحب التعبير عنه؟",
      "ما أمر يحتاج حدودًا أوضح؟",
      "ما فكرة تطمئنك؟",
      "ما رسالة يحملها التوتر لك؟",
      "ما أولوية تحتاج وضوحًا؟",
      "ما شيء يحتاج تأجيلًا؟",
      "ما فكرة تسرع نبضك؟",
      "ما نقص زاد توترك؟",
      "ما مكان يزيد التوتر؟",
      "ما وقت يزيد فيه القلق؟",
      "ما جملة تكررها لنفسك؟",
      "ما أمر يجعلك تشعر بالضغط؟",
      "ما خطوة سهلة يمكنك البدء بها؟",
      "ما أمر يمكنك تقسيمه؟",
      "ما عبء يمكنك تركه؟",
      "من الشخص الذي يهدئك؟",
      "ما خوف من الحكم عليك؟",
      "ما خوف من الفشل؟",
      "ما أمر لو انتهى سترتاح؟",
      "ما شيء يحتاج تنظيمًا؟",
      "ما أمر يحتاج كلمة لا؟",
      "ما أمر يحتاج كلمة كفاية؟",
      "ما أمر يحتاج شجاعة؟",
      "ما الذي يزيد التوتر أكثر؟",
      "ما خطة بسيطة للتهدئة؟",
      "ما أشياء تمنحك هدوءًا؟",
      "ما موقف قديم يشبه الحالي؟",
      "ما أمر تحتاج الاطمئنان عليه؟",
      "ما تواصل ناقص؟",
      "ما فكرة تحتاج كتابة؟",
      "ما مهمة يمكن تفويضها؟",
      "ما أمر يحتاج مراجعة؟",
      "ما شيء يطمئنك سريعًا؟",
      "ما مهمة واحدة ستخفف الضغط؟",
      "ما أمر لا يستحق كل القلق؟",
      "ما شعور تحتاج تهدئته؟",
    ],
    "متحمّس": [
      "ما الذي يشعل حماسك الآن؟",
      "ما هدف قريب يشجعك؟",
      "ما خطوة تنتظرها بشغف؟",
      "ما سبب يجعلك تستمر؟",
      "ما نتيجة جميلة تتخيلها؟",
      "ما مهارة تحب تطويرها؟",
      "ما مشروع تفكر في بدايته؟",
      "ما تجربة جديدة متحمس لها؟",
      "ما فكرة أعطتك دفعة؟",
      "من تحب مشاركة حماسك معه؟",
      "ما أمر لو تحقق سيحدث فرقًا؟",
      "ما الذي يجعلك تؤمن بنفسك؟",
      "ما مكسب تتوقعه؟",
      "ما خطوة بسيطة يمكنك فعلها اليوم؟",
      "ما علامة التقدم بالنسبة لك؟",
      "ما شيء تحب إثباته لنفسك؟",
      "ما تحدٍ متحمس لتجاوزه؟",
      "ما جزء ممتع في الرحلة؟",
      "ما شيء يحتاج تحضيرًا؟",
      "ما توقعك للفترة القادمة؟",
      "ما شيء قد يضعف الحماس؟",
      "ما طقس يحافظ على حماسك؟",
      "ما مكافأة تحب تقديمها لنفسك؟",
      "ما التزام بسيط تحب البدء به؟",
      "ما عادة تدعم أهدافك؟",
      "ما أمر يحول الحماس لنتائج؟",
      "ما خطوة مؤجلة حان وقتها؟",
      "ما مورد تحتاجه؟",
      "ما شخص تحتاج التواصل معه؟",
      "ما وقت تحب استثماره؟",
      "ما شيء يعطيك دفعة معنوية؟",
      "ما احتمال جميل تتوقعه؟",
      "ما سببك الحقيقي؟",
      "ما ميزة لديك تساعدك؟",
      "ما شيء تحب تعلمه؟",
      "ما خطة بديلة تطمئنك؟",
      "ما مؤشر النجاح لديك؟",
      "ما أمر يحتاج صبرًا؟",
      "ما أمر يحتاج جرأة؟",
      "ما فعل يجعلك فخورًا؟",
      "ما أول شيء ستفعله عند النجاح؟",
      "ما طاقة تحب الحفاظ عليها؟",
      "ما عادة تحب الالتزام بها؟",
      "ما خطوة قد تغير المسار؟",
      "ما شيء يجعلك تشعر بالاستعداد؟",
      "ما شيء يجعلك تبدأ فورًا؟",
      "ما نتيجة تنتظرها بشغف؟",
      "ما نية تحب وضعها لليوم؟",
    ],
    "مرهق": [
      "ما أكثر شيء استنزف طاقتك اليوم؟",
      "هل الإرهاق ذهني أم جسدي؟",
      "ما موقف جعلك تشعر بالتعب؟",
      "ما أمر تحتاج إيقافه مؤقتًا؟",
      "ما شيء تحتاج راحة منه؟",
      "ما آخر مرة شعرت فيها بنوم مريح؟",
      "ما أمر لو تغير سيخفف الإرهاق؟",
      "ما عبء تحمله وحدك؟",
      "ما شيء يمكنك تقليله؟",
      "ما أمر يمكنك طلب مساعدة فيه؟",
      "ما الذي يرهقك أكثر؟",
      "ما شيء تحتاج الابتعاد عنه؟",
      "ما عناية بسيطة تحتاجها؟",
      "ما عادة تتعبك؟",
      "ما أمر يمكنك تخفيفه؟",
      "ما مهمة يمكن تأجيلها؟",
      "ما إنجاز بسيط سيمنحك خفة؟",
      "ما وقت يزداد فيه التعب؟",
      "ما مكان تشعر فيه بالإرهاق؟",
      "ما تقصير في العناية بنفسك؟",
      "ما شيء تحتاج إنهاءه؟",
      "ما أمر تحتاج تقبله؟",
      "ما شيء تحتاج استعادته؟",
      "ما ضغط يمكنك تخفيفه؟",
      "ما شيء يثقل عليك؟",
      "ما شيء يمنحك راحة؟",
      "من الشخص الذي يريحك؟",
      "ما آخر شيء فعلته لنفسك؟",
      "ما عادة تؤجلها حتى تتعب؟",
      "ما صوت داخلي يرهقك؟",
      "ما توقعات تضعها على نفسك؟",
      "ما شيء تحتاج الرحمة فيه؟",
      "ما شعور يرافق الإرهاق؟",
      "ما راحة سريعة تحتاجها؟",
      "ما أمر يمكنك تفويضه؟",
      "ما شيء تحتاج قول كفاية له؟",
      "ما راحة تختارها الآن؟",
      "ما أمر تحتاج التوقف عنه؟",
      "ما شيء تحتاج فعله بهدوء؟",
      "ما تصرف يخفف الضغط؟",
      "ما شيء يمنحك أمانًا؟",
      "ما شيء يمنحك هدوءًا؟",
      "ما شيء يمنحك دعمًا؟",
      "ما ما يحتاجه جسدك؟",
      "ما ما يحتاجه عقلك؟",
      "ما ما يحتاجه قلبك؟",
      "ما خطة بسيطة لبقية اليوم؟",
      "ما كلمة لطيفة تقولها لنفسك؟",
      "ما راحة تستحقها الآن؟",
    ],
  };

  String pickQuestion(String mood) {
    final list = List<String>.from(moodQuestions[mood]!);
    list.shuffle(Random());
    return list.first;
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('entries') ?? [];
    savedEntries = raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
    setState(() {});
  }

  Future<void> saveEntry() async {
    if (selectedMood == null ||
        selectedQuestion == null ||
        answerController.text.trim().isEmpty ||
        journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("من فضلك أكمل جميع الحقول")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE d MMMM yyyy – hh:mm a', 'ar').format(now);

    final entry = {
      'date': dateStr,
      'mood': selectedMood,
      'emoji': moodEmojis[selectedMood]!,
      'question': selectedQuestion!,
      'answer': answerController.text.trim(),
      'journal': journalController.text.trim(),
    };

    final current = prefs.getStringList('entries') ?? [];
    current.add(jsonEncode(entry));
    await prefs.setStringList('entries', current);

    answerController.clear();
    journalController.clear();

    setState(() {
      selectedMood = null;
      selectedQuestion = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("تم حفظ تدوينك بنجاح ❤️")));
  }

  Future<void> deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => savedEntries.removeAt(index));
    await prefs.setStringList(
      'entries',
      savedEntries.reversed.map((e) => jsonEncode(e)).toList(),
    );
  }

  void showEntryDetails(Map<String, dynamic> e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: warmBeige,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("${e['emoji']} ${e['mood']}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📅 ${e['date']}"),
              const SizedBox(height: 14),
              Text(
                "❓ ${e['question']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("✍️ إجابتك:\n${e['answer']}"),
              const SizedBox(height: 10),
              Text("📓 التدوين الشخصي:\n${e['journal']}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: powderPink,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("🗣️ فضفضلي"),
          centerTitle: true,
          backgroundColor: powderPink,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: roseGold),
                onPressed: () async {
                  if (!showHistory) await loadHistory();
                  setState(() => showHistory = !showHistory);
                },
                child: Text(showHistory ? "إخفاء السجل" : "📁 سجل التدوينات"),
              ),
              const SizedBox(height: 20),
              if (!showHistory) ...[
                const Text(
                  "كيف تشعر اليوم؟",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: purplePink,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: moodEmojis.keys.map((mood) {
                    final selected = selectedMood == mood;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = mood;
                          selectedQuestion = pickQuestion(mood);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? roseGold : warmBeige,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: roseGold, width: 2),
                        ),
                        child: Text(
                          "${moodEmojis[mood]}  $mood",
                          style: TextStyle(
                            fontSize: 18,
                            color: selected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (selectedQuestion != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: warmBeige,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: roseGold, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          selectedQuestion!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: answerController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "إجابتك على السؤال",
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: journalController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "مساحة هدوء",
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: roseGold,
                          ),
                          onPressed: saveEntry,
                          child: const Text("حفظ"),
                        ),
                      ],
                    ),
                  ),
              ],
              if (showHistory) ...[
                if (savedEntries.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: warmBeige.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.brown.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.history_rounded,
                            size: 42,
                            color: Colors.brown,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "لا توجد عناصر محفوظة بعد",
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: savedEntries.length,
                    itemBuilder: (context, index) {
                      final e = savedEntries[index];
                      return Card(
                        color: warmBeige,
                        child: ListTile(
                          onTap: () => showEntryDetails(e),
                          title: Text("${e['emoji']} ${e['mood']}"),
                          subtitle: Text(e['date']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await DeleteConfirmDialog.show(
                                context: context,
                                title: 'هل أنت متأكد من الحذف؟',
                                message: 'سيتم حذف هذا العنصر نهائيًا',
                              );

                              if (confirm == true) {
                                deleteEntry(index);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
          content: const Text(
            'هل أنت متأكد من الحذف؟',
            textAlign: TextAlign.right,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
