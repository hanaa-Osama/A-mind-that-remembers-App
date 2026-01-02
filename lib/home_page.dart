import 'package:flutter/material.dart';

import 'package:lahzet_zikry/fdfd_page.dart';
import 'package:lahzet_zikry/memory_page.dart';
import 'package:lahzet_zikry/self_session_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color roseGold = Color(0xFFB76E79);

  final List<Widget> pages = const [
    FadfadlyPage(),
    MemoryPage(),
    SelfSessionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: powderPink,
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: powderPink,
        elevation: 10,
        selectedItemColor: roseGold,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Tajawal',
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "كلام من القلب",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_added_outlined),
            activeIcon: Icon(Icons.bookmark),
            label: "ذكرى اليوم",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            activeIcon: Icon(Icons.self_improvement),
            label: "جلسة هادئة",
          ),
        ],
      ),
    );
  }
}
