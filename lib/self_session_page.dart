import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'lib/widgets/delete_alert_dialog.dart';
import 'translations.dart';
import 'language_provider.dart';


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

  Map<String, List<String>> getSections(BuildContext context) {
    return {
      S.of(context, 'section_feelings'): [
        S.of(context, 'q1_1'),
        S.of(context, 'q1_2'),
        S.of(context, 'q1_3'),
        S.of(context, 'q1_4'),
        S.of(context, 'q1_5'),
      ],
      S.of(context, 'section_relationships'): [
        S.of(context, 'q2_1'),
        S.of(context, 'q2_2'),
        S.of(context, 'q2_3'),
        S.of(context, 'q2_4'),
        S.of(context, 'q2_5'),
      ],
      S.of(context, 'section_achievements'): [
        S.of(context, 'q3_1'),
        S.of(context, 'q3_2'),
        S.of(context, 'q3_3'),
        S.of(context, 'q3_4'),
        S.of(context, 'q3_5'),
      ],
      S.of(context, 'section_health'): [
        S.of(context, 'q4_1'),
        S.of(context, 'q4_2'),
        S.of(context, 'q4_3'),
        S.of(context, 'q4_4'),
        S.of(context, 'q4_5'),
      ],
      S.of(context, 'section_gratitude'): [
        S.of(context, 'q5_1'),
        S.of(context, 'q5_2'),
        S.of(context, 'q5_3'),
        S.of(context, 'q5_4'),
        S.of(context, 'q5_5'),
      ],
      S.of(context, 'section_thoughts'): [
        S.of(context, 'q6_1'),
        S.of(context, 'q6_2'),
        S.of(context, 'q6_3'),
        S.of(context, 'q6_4'),
        S.of(context, 'q6_5'),
      ],
    };
  }

  final Map<String, TextEditingController> controllers = {};
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _initializeControllers(BuildContext context) {
    final sections = getSections(context);
    for (var section in sections.entries) {
      for (var q in section.value) {
        String key = "${section.key}::$q";
        if (!controllers.containsKey(key)) {
          controllers[key] = TextEditingController();
        }
      }
    }
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
    if (mounted) setState(() {});
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

  void _openSessionDetails(Map<String, dynamic> session, Map<String, List<String>> sections) {
    final answers = Map<String, String>.from(session['answers']);
    showDialog(
      context: context,
      builder: (_) {
        final date = DateFormat(
          'EEEE d MMMM yyyy – hh:mm a',
          Localizations.localeOf(context).languageCode,
        ).format(DateTime.parse(session['createdAt']));
        return AlertDialog(
          backgroundColor: warmBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            S.of(context, 'session_details'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: purplePink, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _deleteSession(session['id']);
                setState(() {});
                Navigator.pop(context);
              },
              child: Text(
                S.of(context, 'delete_session'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context, 'close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeControllers(context);
    final sections = getSections(context);

    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        title: Text(S.of(context, 'self_session_title')),
        backgroundColor: powderPink,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...sections.entries.map(
              (section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        decoration: InputDecoration(
                          hintText: q,
                          filled: true,
                          fillColor: warmBeige,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: roseGold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _saveSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: roseGold,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                S.of(context, 'save_session'),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(S.of(context, 'session_history')),
              style: OutlinedButton.styleFrom(
                foregroundColor: purplePink,
                side: const BorderSide(color: purplePink),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (sessions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        S.of(context, 'no_sessions_yet'),
                        style: const TextStyle(fontFamily: 'Tajawal'),
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
                            padding: const EdgeInsets.all(16),
                            itemCount: sessions.length,
                            itemBuilder: (_, i) {
                              final s = sessions[i];
                              final date = DateFormat(
                                'd MMM yyyy – hh:mm a',
                                Localizations.localeOf(context).languageCode,
                              ).format(DateTime.parse(s['createdAt']));
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  title: Text(S.of(context, 'meditation_session')),
                                  subtitle: Text(date),
                                  onTap: () => _openSessionDetails(s, sections),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm =
                                          await DeleteConfirmDialog.show(
                                            context: context,
                                            title: S.of(context, 'delete_session'),
                                            message: S.of(context, 'confirm_delete_session'),
                                            confirmText: S.of(context, 'delete'),
                                            cancelText: S.of(context, 'cancel'),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
