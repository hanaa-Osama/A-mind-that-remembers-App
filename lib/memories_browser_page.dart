import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lahzet_zikry/translations.dart';
import 'data/repositories/memory_repository_impl.dart';
import 'presentation/memories_browser/memories_browser_presenter.dart';

const Color spaceBlack = Color(0xFF0A0A0F);
const Color darkGray = Color(0xFF1A1A1F);
const Color mediumGray = Color(0xFF2A2A2F);
const Color lightGray = Color(0xFF4A4A4F);
const Color starWhite = Color(0xFFE8E8E8);
const Color textFieldGray = Color(0xFFE0E0E0);

class MemoriesBrowserPage extends StatefulWidget {
  const MemoriesBrowserPage({super.key});
  @override
  State<MemoriesBrowserPage> createState() => _MemoriesBrowserPageState();
}

class _MemoriesBrowserPageState extends State<MemoriesBrowserPage> with TickerProviderStateMixin implements MemoriesBrowserView {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late MemoriesBrowserPresenter _presenter;
  
  late AnimationController _starsController;
  late AnimationController _shootingStarController;
  
  final List<Map<String, dynamic>> _stars = [];
  final List<Map<String, dynamic>> _shootingStars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _presenter = MemoriesBrowserPresenter(MemoryRepositoryImpl(), this);
    _initAnimations();
    _generateStars();
    _generateShootingStars();
  }

  void _initAnimations() {
    _starsController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _shootingStarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  void _generateStars() {
    for (int i = 0; i < 150; i++) {
      _stars.add({'x': _random.nextDouble(), 'y': _random.nextDouble(), 'size': _random.nextDouble() * 2.5 + 0.5, 'opacity': _random.nextDouble() * 0.5 + 0.3, 'twinkleSpeed': _random.nextDouble() * 0.5 + 0.5});
    }
  }

  void _generateShootingStars() {
    for (int i = 0; i < 3; i++) {
      _shootingStars.add({'startX': _random.nextDouble(), 'startY': _random.nextDouble() * 0.5, 'length': _random.nextDouble() * 0.15 + 0.1, 'delay': _random.nextDouble(), 'speed': _random.nextDouble() * 0.5 + 0.5});
    }
  }

  @override
  void dispose() {
    _starsController.dispose();
    _shootingStarController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // MVP View Implementation
  @override
  void showMessage(String message) => _snack(S.of(context, message));

  @override
  void onSaveSuccess() {
    _snack(S.of(context, 'save_success'));
    setState(() => _textController.clear());
  }

  Future<void> _saveMemory() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      showMessage('write_something');
      return;
    }
    final title = await _showSaveTitleDialog();
    if (title != null) {
      await _presenter.saveMemory(text, title);
    }
  }

  Future<String?> _showSaveTitleDialog() async {
    final titleController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: darkGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(S.of(context, 'save_memory'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context, 'add_title_prompt'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: textFieldGray, borderRadius: BorderRadius.circular(12)),
                child: TextField(controller: titleController, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 16), decoration: InputDecoration(hintText: S.of(context, 'title_hint'), hintStyle: TextStyle(color: lightGray), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: Text(S.of(context, 'cancel'), style: const TextStyle(color: Colors.red, fontSize: 16))),
            TextButton(onPressed: () => Navigator.pop(ctx, ''), child: Text(S.of(context, 'no_title'), style: const TextStyle(color: starWhite, fontSize: 16))),
            ElevatedButton(onPressed: () { final title = titleController.text.trim(); Navigator.pop(ctx, title.isEmpty ? '' : title); }, style: ElevatedButton.styleFrom(backgroundColor: starWhite, foregroundColor: spaceBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(S.of(context, 'save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: darkGray, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: spaceBlack,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [spaceBlack, darkGray, mediumGray, spaceBlack], stops: [0.0, 0.3, 0.7, 1.0]))),
            AnimatedBuilder(animation: _starsController, builder: (context, child) => CustomPaint(painter: StarsPainter(stars: _stars, animationValue: _starsController.value), size: Size.infinite)),
            AnimatedBuilder(animation: _shootingStarController, builder: (context, child) => CustomPaint(painter: ShootingStarsPainter(shootingStars: _shootingStars, animationValue: _shootingStarController.value), size: Size.infinite)),
            SafeArea(child: Column(children: [_buildHeader(), Expanded(child: _buildWritingArea())])),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 44),
          Text(S.of(context, 'memories_space'), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 26, fontWeight: FontWeight.bold, color: starWhite, letterSpacing: 2)),
          GestureDetector(onTap: _saveMemory, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: darkGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray, width: 0.5)), child: const Icon(Icons.add, color: starWhite, size: 24))),
        ],
      ),
    );
  }

  Widget _buildWritingArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(color: darkGray.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: lightGray.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          maxLines: null,
          expands: true,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.8, fontFamily: 'Tajawal'),
          decoration: InputDecoration(hintText: S.of(context, 'write_hint'), hintStyle: TextStyle(color: lightGray, fontFamily: 'Tajawal'), border: InputBorder.none, contentPadding: const EdgeInsets.all(20), filled: true, fillColor: textFieldGray),
        ),
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  final List<Map<String, dynamic>> stars;
  final double animationValue;
  StarsPainter({required this.stars, required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final opacity = (star['opacity'] as double) * (0.5 + 0.5 * sin(animationValue * 2 * pi * (star['twinkleSpeed'] as double)));
      final paint = Paint()..color = starWhite.withOpacity(opacity.clamp(0.1, 1.0))..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(star['x'] * size.width, star['y'] * size.height), star['size'] as double, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShootingStarsPainter extends CustomPainter {
  final List<Map<String, dynamic>> shootingStars;
  final double animationValue;
  ShootingStarsPainter({required this.shootingStars, required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in shootingStars) {
      final delay = star['delay'] as double;
      final speed = star['speed'] as double;
      double progress = ((animationValue * speed) + delay) % 1.0;
      if (progress > 0.7) continue;
      final normalizedProgress = progress / 0.7;
      final startX = (star['startX'] as double) * size.width;
      final startY = (star['startY'] as double) * size.height;
      final length = (star['length'] as double) * size.width;
      final currentX = startX + normalizedProgress * length * 1.5;
      final currentY = startY + normalizedProgress * length;
      final opacity = (1.0 - normalizedProgress) * 0.8;
      final gradient = LinearGradient(colors: [starWhite.withOpacity(opacity), starWhite.withOpacity(0)]);
      final paint = Paint()..shader = gradient.createShader(Rect.fromPoints(Offset(currentX, currentY), Offset(currentX - length * 0.5, currentY - length * 0.3)))..strokeWidth = 2..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(currentX, currentY), Offset(currentX - length * 0.5, currentY - length * 0.3), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
