import 'package:flutter/material.dart';
import 'package:lahzet_zikry/memory_page.dart';
import 'package:lahzet_zikry/memories_browser_page.dart';
import 'package:lahzet_zikry/memories_list_page.dart';
import 'package:lahzet_zikry/translations.dart';
import 'package:lahzet_zikry/language_provider.dart';
import 'package:provider/provider.dart';

const Color spaceBlack = Color(0xFF0A0A0F);
const Color darkGray = Color(0xFF1A1A1F);
const Color mediumGray = Color(0xFF2A2A2F);
const Color lightGray = Color(0xFF4A4A4F);
const Color starWhite = Color(0xFFE8E8E8);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Widget> pages = const [
    MemoriesBrowserPage(),
    MemoryPage(),
  ];

  void _openMemoriesDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: spaceBlack,
      body: pages[currentIndex],
      endDrawer: const MemoriesDrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: darkGray,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.auto_stories_outlined, Icons.auto_stories, S.of(context, 'my_journal')),
                _buildNavItem(1, Icons.photo_camera_outlined, Icons.photo_camera, S.of(context, 'studio')),
                _buildMenuButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? starWhite.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? starWhite : starWhite.withOpacity(0.5), size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontFamily: 'Tajawal', color: isSelected ? starWhite : starWhite.withOpacity(0.5), fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: _openMemoriesDrawer,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu, color: starWhite.withOpacity(0.5), size: 26),
            const SizedBox(height: 4),
            Text(S.of(context, 'menu'), style: TextStyle(fontFamily: 'Tajawal', color: starWhite.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class MemoriesDrawer extends StatefulWidget {
  const MemoriesDrawer({super.key});
  @override
  State<MemoriesDrawer> createState() => _MemoriesDrawerState();
}

class _MemoriesDrawerState extends State<MemoriesDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkGray,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lightGray.withOpacity(0.3)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: lightGray.withOpacity(0.3), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close, color: starWhite, size: 20)),
                  ),
                  Text(S.of(context, 'memories_list'), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.bold, color: starWhite)),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(child: MemoriesListContent(onMemorySelected: (memory) => Navigator.pop(context))),
          ],
        ),
      ),
    );
  }
}
