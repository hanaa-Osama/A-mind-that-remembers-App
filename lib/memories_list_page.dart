import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_details_page.dart';

class MemoriesListPage extends StatefulWidget {
  const MemoriesListPage({super.key});

  @override
  State<MemoriesListPage> createState() => _MemoriesListPageState();
}

class _MemoriesListPageState extends State<MemoriesListPage> {
  List<Map<String, dynamic>> memories = [];

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  @override
  void initState() {
    super.initState();
    loadMemories();
  }

  Future<void> loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> raw = prefs.getStringList("memories") ?? [];

    memories = raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    memories = memories.reversed.toList();

    setState(() {});
  }

  Future<void> deleteMemory(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> raw = prefs.getStringList("memories") ?? [];

    raw.removeAt(raw.length - 1 - index);
    await prefs.setStringList("memories", raw);

    loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        title: const Text(
          "📜 سجل الذكريات",
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: powderPink,
        elevation: 0,
        centerTitle: true,
      ),
      body: memories.isEmpty
          ? const Center(
        child: Text(
          "لا توجد ذكريات محفوظة بعد",
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: memories.length,
        itemBuilder: (context, index) {
          final mem = memories[index];

          return Card(
            color: warmBeige,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: roseGold),
            ),
            child: ListTile(
              title: Text(
                mem["title"],
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                mem["date"],
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.grey,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.blue,
                ),
                onPressed: () => deleteMemory(index),
                tooltip: "حذف الذكرى",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemoryDetailsPage(data: mem),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
