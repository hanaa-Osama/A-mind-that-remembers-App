import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lib/widgets/delete_alert_dialog.dart';

class SelfSessionPage extends StatefulWidget {
  const SelfSessionPage({super.key});

  @override
  State<SelfSessionPage> createState() => _SelfSessionPageState();
}

class _SelfSessionPageState extends State<SelfSessionPage> {
  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  final Map<String, List<String>> sections = {
    "🌷 مشاعر اليوم": [
      "الشيء الذي منح شعورًا بالسعادة اليوم",
      "موقف تسبب في بعض التوتر",
      "لحظة شعر فيها القلب بالامتنان",
      "أمر استنزف الطاقة خلال اليوم",
      "لحظة منحت طاقة إيجابية",
    ],
    "🤝 العلاقات والناس": [
      "كلمة لطيفة أو مجاملة تم تلقيها اليوم",
      "ابتسامة أو تفاعل إنساني لافت",
      "موقف كان فيه الشخص مصدر سعادة لغيره",
      "شخص قدّم دعمًا أو مساندة اليوم",
      "شعور بالاشتياق لشخص ما",
    ],
    "📌 الإنجازات والتنظيم": [
      "إنجاز تحقق خلال اليوم",
      "مهمة أُنجزت بسهولة",
      "أمر تم تأجيله مع سبب ذلك",
      "شيء كان يمكن تغييره لو عاد اليوم",
      "معرفة أو درس جديد تم تعلمه",
    ],
    "🌿 الصحة والطاقة": [
      "مستوى الطاقة خلال اليوم",
      "شيء ساعد على الشعور بالراحة النفسية",
      "مكان أو لحظة منحت إحساسًا بالطمأنينة",
      "شكل من أشكال العناية بالنفس",
      "أمنية ليكون الغد أخف أو أهدأ",
    ],
    "✨ الامتنان والتأمل": [
      "أمر واحد يستحق الامتنان اليوم",
      "كلمة أو عبارة كان لها أثر",
      "لحظة ابتسامة عفوية",
      "ذكرى أو خاطر مرّ فجأة",
      "شيء بسيط صنع شعورًا جميلًا",
    ],
    "🧠 أفكار عميقة": [
      "ما يعكسه المزاج اليوم عن الداخل",
      "فكرة لم يتم مشاركتها مع أحد",
      "درس قدّمه هذا اليوم",
      "خاطرة بقيت حاضرة في القلب",
      "أمنية تم التفكير فيها اليوم",
    ],
  };

  final Map<String, TextEditingController> controllers = {};
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    for (var section in sections.entries) {
      for (var q in section.value) {
        controllers["${section.key}::$q"] = TextEditingController();
      }
    }
    _loadSessions();
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('self_sessions') ?? [];
    sessions = raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
    setState(() {});
  }

  Future<void> _saveSession() async {
    final answers = <String, String>{};
    controllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        answers[key] = controller.text.trim();
      }
    });

    if (answers.isEmpty) return;

    final now = DateTime.now();
    final session = {
      "id": now.millisecondsSinceEpoch,
      "createdAt": now.toIso8601String(),
      "answers": answers,
    };

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('self_sessions') ?? [];
    list.add(jsonEncode(session));
    await prefs.setStringList('self_sessions', list);

    controllers.forEach((_, c) => c.clear());
    await _loadSessions();
  }

  Future<void> _deleteSession(int id) async {
    final prefs = await SharedPreferences.getInstance();
    sessions.removeWhere((s) => s['id'] == id);
    await prefs.setStringList(
      'self_sessions',
      sessions.reversed.map((e) => jsonEncode(e)).toList(),
    );
  }

  void _openSessionDetails(Map<String, dynamic> session) {
    final answers = Map<String, String>.from(session['answers']);
    showDialog(
      context: context,
      builder: (_) {
        final date = DateFormat(
          'EEEE d MMMM yyyy – hh:mm a',
          'ar',
        ).format(DateTime.parse(session['createdAt']));
        return AlertDialog(
          backgroundColor: warmBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "🧘 تفاصيل الجلسة",
            textAlign: TextAlign.center,
            style: TextStyle(color: purplePink, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ...sections.entries.map((section) {
                  final items = section.value.where(
                    (q) => answers.containsKey("${section.key}::$q"),
                  );
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: roseGold),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          section.key,
                          style: const TextStyle(
                            color: purplePink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...items.map(
                          (q) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  q,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  answers["${section.key}::$q"]!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _deleteSession(session['id']);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text(
                "حذف الجلسة",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(title: const Text("🌿 جلسة مع نفسي")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...sections.entries.map(
              (section) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    section.key,
                    style: const TextStyle(
                      color: purplePink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...section.value.map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: controllers["${section.key}::$q"],
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(hintText: q),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _saveSession,
              child: const Text("💾 حفظ الجلسة"),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text("📚 سجل الجلسات"),
              onPressed: () {
                if (sessions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "لا توجد جلسات حتى الآن، ابدأ جلسة جديدة 🌱",
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                      backgroundColor: Colors.orangeAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: warmBeige,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) {
                      return StatefulBuilder(
                        builder: (context, modalSetState) {
                          return ListView.builder(
                            itemCount: sessions.length,
                            itemBuilder: (_, i) {
                              final s = sessions[i];
                              final date = DateFormat(
                                'd MMM yyyy – hh:mm a',
                                'ar',
                              ).format(DateTime.parse(s['createdAt']));
                              return Card(
                                child: ListTile(
                                  title: const Text("🧘 جلسة تأمل"),
                                  subtitle: Text(date),
                                  onTap: () => _openSessionDetails(s),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm =
                                          await DeleteConfirmDialog.show(
                                            context: context,
                                            title: 'حذف الجلسة',
                                            message:
                                                'هل أنت متأكد من حذف هذه الجلسة؟\nلا يمكن التراجع عن هذا الإجراء.',
                                            confirmText: 'حذف',
                                            cancelText: 'إلغاء',
                                          );

                                      if (confirm == true) {
                                        await _deleteSession(s['id']);
                                        modalSetState(() {});
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
