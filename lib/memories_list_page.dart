import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:lahzet_zikry/translations.dart';

const Color spaceBlack = Color(0xFF0A0A0F);
const Color darkGray = Color(0xFF1A1A1F);
const Color mediumGray = Color(0xFF2A2A2F);
const Color lightGray = Color(0xFF4A4A4F);
const Color starWhite = Color(0xFFE8E8E8);
const Color textFieldGray = Color(0xFFE0E0E0);

class MemoriesListPage extends StatelessWidget {
  const MemoriesListPage({super.key});
  @override
  Widget build(BuildContext context) => const MemoriesListContent();
}

class MemoriesListContent extends StatefulWidget {
  final Function(Map<String, dynamic>)? onMemorySelected;
  const MemoriesListContent({super.key, this.onMemorySelected});
  @override
  State<MemoriesListContent> createState() => _MemoriesListContentState();
}

class _MemoriesListContentState extends State<MemoriesListContent> {
  List<Map<String, dynamic>> memories = [];
  List<Map<String, dynamic>> filteredMemories = [];
  String _filterType = 'all';
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getString('memories');
      if (memoriesJson != null && memoriesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(memoriesJson);
        if (!mounted) return;
        setState(() {
          memories = decoded.cast<Map<String, dynamic>>();
          memories.sort((a, b) {
            final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
          _applyFilter();
        });
      }
    } catch (e) { debugPrint('Load error: $e'); }
  }

  void _applyFilter() {
    setState(() {
      List<Map<String, dynamic>> result = List.from(memories);
      switch (_filterType) {
        case 'journal': result = result.where((m) => m['isJournal'] == true).toList(); break;
        case 'favorite': result = result.where((m) => m['isFavorite'] == true).toList(); break;
      }
      final searchText = searchController.text.trim().toLowerCase();
      if (searchText.isNotEmpty) {
        result = result.where((m) {
          final title = (m['title'] ?? '').toString().toLowerCase();
          final pages = m['pages'] as List?;
          String allText = title;
          if (pages != null) { for (var page in pages) { allText += ' ${(page['text'] ?? '').toString().toLowerCase()}'; } }
          return allText.contains(searchText);
        }).toList();
      }
      filteredMemories = result;
    });
  }

  Future<void> _deleteMemory(Map<String, dynamic> memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(S.of(context, 'confirm_delete'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 20)),
        content: Text(S.of(context, 'confirm_delete'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context, 'cancel'), style: const TextStyle(color: lightGray))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400), child: Text(S.of(context, 'delete'), style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
        try {
        final prefs = await SharedPreferences.getInstance();
        memories.removeWhere((m) => m['id'] == memory['id']);
        await prefs.setString('memories', jsonEncode(memories));
        _applyFilter();
        _snack(S.of(context, 'delete'));
      } catch (e) { _snack(S.of(context, 'error')); }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: darkGray, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(child: filteredMemories.isEmpty ? _buildEmptyState() : _buildMemoriesList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: spaceBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: lightGray.withOpacity(0.3)),
        ),
        child: TextField(
          controller: searchController,
          textAlign: TextAlign.center,
          onChanged: (_) => _applyFilter(),
          style: const TextStyle(fontFamily: 'Tajawal', color: starWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: S.of(context, 'search_hint'),
            hintStyle: const TextStyle(fontFamily: 'Tajawal', color: lightGray),
            prefixIcon: const Icon(Icons.search, color: lightGray, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(S.of(context, 'all'), 'all'),
            const SizedBox(width: 6),
            _buildFilterChip(S.of(context, 'my_journal'), 'journal'),
            const SizedBox(width: 6),
            _buildFilterChip(S.of(context, 'favorites'), 'favorite'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () { setState(() => _filterType = type); _applyFilter(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? lightGray : spaceBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? starWhite.withOpacity(0.3) : lightGray.withOpacity(0.3))),
        child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? starWhite : starWhite.withOpacity(0.7))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 48, color: lightGray),
          const SizedBox(height: 16),
          Text(S.of(context, 'no_memories'), style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, color: starWhite.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildMemoriesList() {
    return RefreshIndicator(
      onRefresh: _loadMemories,
      color: starWhite,
      backgroundColor: darkGray,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filteredMemories.length,
        itemBuilder: (context, index) => _buildMemoryCard(filteredMemories[index]),
      ),
    );
  }

  Widget _buildMemoryCard(Map<String, dynamic> memory) {
    final title = memory['title']?.toString() ?? '';
    final createdAt = DateTime.tryParse(memory['createdAt'] ?? '');
    final pages = memory['pages'] as List?;
    String preview = '';
    bool hasMedia = false;
    if (pages != null && pages.isNotEmpty) {
      preview = pages[0]['text']?.toString() ?? '';
      hasMedia = pages.any((p) => p['image'] != null || p['video'] != null);
    }
    
    return GestureDetector(
      onTap: () {
        if (widget.onMemorySelected != null) {
          widget.onMemorySelected!(memory);
        }
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => MemoryDetailPage(memory: memory, onUpdate: _loadMemories))).then((_) => _loadMemories());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: spaceBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              GestureDetector(onTap: () => _deleteMemory(memory), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.delete_outline, size: 16, color: Colors.red))),
              const SizedBox(width: 8),
              if (hasMedia) Icon(Icons.photo, size: 12, color: starWhite.withOpacity(0.5)),
              if (hasMedia) const SizedBox(width: 4),
              Text(createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year}' : '', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: starWhite.withOpacity(0.5))),
            ]),
            Flexible(child: Text(title.isNotEmpty ? title : S.of(context, 'untitled'), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: title.isNotEmpty ? starWhite : starWhite.withOpacity(0.5)))),
          ]),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(preview.length > 60 ? '${preview.substring(0, 60)}...' : preview, textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: starWhite.withOpacity(0.6))),
          ],
        ]),
      ),
    );
  }
}

class MemoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> memory;
  final VoidCallback? onUpdate;
  const MemoryDetailPage({super.key, required this.memory, this.onUpdate});
  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _starsController;
  final List<Map<String, dynamic>> _stars = [];
  final Random _random = Random();
  
  late TextEditingController _titleController;
  late TextEditingController _textController;
  bool _isEditing = false;
  late Map<String, dynamic> _currentMemory;

  @override
  void initState() {
    super.initState();
    _currentMemory = Map<String, dynamic>.from(widget.memory);
    _starsController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _generateStars();
    _initVideo();
    _titleController = TextEditingController(text: _currentMemory['title']?.toString() ?? '');
    final pages = _currentMemory['pages'] as List?;
    _textController = TextEditingController(text: pages?.isNotEmpty == true ? pages![0]['text']?.toString() ?? '' : '');
  }

  void _generateStars() {
    for (int i = 0; i < 80; i++) {
      _stars.add({'x': _random.nextDouble(), 'y': _random.nextDouble(), 'size': _random.nextDouble() * 2 + 0.5, 'opacity': _random.nextDouble() * 0.5 + 0.3, 'twinkleSpeed': _random.nextDouble() * 0.5 + 0.5});
    }
  }

  void _initVideo() {
    final pages = _currentMemory['pages'] as List?;
    if (pages != null && pages.isNotEmpty) {
      final videoPath = pages[0]['video']?.toString();
      if (videoPath != null && File(videoPath).existsSync()) {
        _videoController = VideoPlayerController.file(File(videoPath))..initialize().then((_) => setState(() {}));
      }
    }
  }

  @override
  void dispose() {
    _starsController.dispose();
    _videoController?.dispose();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memoriesJson = prefs.getString('memories');
      if (memoriesJson == null) return;
      
      List<dynamic> memories = jsonDecode(memoriesJson);
      final memoryIndex = memories.indexWhere((m) => m['id'].toString() == _currentMemory['id'].toString());
      
      if (memoryIndex != -1) {
        memories[memoryIndex]['title'] = _titleController.text.trim();
        final pages = memories[memoryIndex]['pages'] as List?;
        if (pages != null && pages.isNotEmpty) {
          pages[0]['text'] = _textController.text.trim();
        } else {
          memories[memoryIndex]['pages'] = [{'text': _textController.text.trim()}];
        }
        
        await prefs.setString('memories', jsonEncode(memories));
        
        setState(() {
          _currentMemory['title'] = _titleController.text.trim();
          if (_currentMemory['pages'] != null && (_currentMemory['pages'] as List).isNotEmpty) {
            (_currentMemory['pages'] as List)[0]['text'] = _textController.text.trim();
          }
          _isEditing = false;
        });
        
        widget.onUpdate?.call();
        _snack(S.of(context, 'changes_saved'));
      }
    } catch (e) {
      _snack(S.of(context, 'error'));
      debugPrint('Error: $e');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: darkGray, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    final title = _currentMemory['title']?.toString() ?? '';
    final createdAt = DateTime.tryParse(_currentMemory['createdAt'] ?? '');
    final pages = _currentMemory['pages'] as List?;
    String text = '';
    String? imagePath;
    String? videoPath;
    if (pages != null && pages.isNotEmpty) { 
      text = pages[0]['text']?.toString() ?? ''; 
      imagePath = pages[0]['image']?.toString(); 
      videoPath = pages[0]['video']?.toString(); 
    }

    return Scaffold(
      backgroundColor: spaceBlack,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [spaceBlack, darkGray, spaceBlack], stops: [0.0, 0.5, 1.0]))),
          AnimatedBuilder(animation: _starsController, builder: (context, child) => CustomPaint(painter: StarsPainter(stars: _stars, animationValue: _starsController.value), size: Size.infinite)),
          SafeArea(
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: darkGray, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_ios_new, color: starWhite, size: 18))),
                  Expanded(
                    child: _isEditing 
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: textFieldGray, borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: _titleController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.bold, color: spaceBlack),
                            decoration: InputDecoration(hintText: S.of(context, 'title_hint'), hintStyle: TextStyle(color: lightGray), border: InputBorder.none),
                          ),
                        )
                      : Text(title.isNotEmpty ? title : S.of(context, 'memory'), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.bold, color: starWhite)),
                  ),
                  _isEditing
                    ? GestureDetector(onTap: _saveChanges, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.8), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.check, color: starWhite, size: 18)))
                    : GestureDetector(onTap: () => setState(() => _isEditing = true), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: darkGray, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.edit, color: starWhite, size: 18))),
                ]),
              ),
              if (createdAt != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${createdAt.day}/${createdAt.month}/${createdAt.year}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: starWhite.withOpacity(0.5)))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    if (imagePath != null && File(imagePath).existsSync()) Container(margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath), fit: BoxFit.contain, errorBuilder: (ctx, e, s) => Container(height: 150, color: darkGray, child: Icon(Icons.broken_image, color: lightGray))))),
                    if (videoPath != null && _videoController != null && _videoController!.value.isInitialized) Container(margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: Stack(alignment: Alignment.center, children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))), GestureDetector(onTap: () => setState(() { if (_videoController!.value.isPlaying) _videoController!.pause(); else _videoController!.play(); }), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(40)), child: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: starWhite, size: 32)))])),
                    _isEditing 
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: textFieldGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.2))),
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            minLines: 5,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, color: spaceBlack, height: 1.7),
                            decoration: InputDecoration(hintText: S.of(context, 'write_hint'), hintStyle: TextStyle(color: lightGray), border: InputBorder.none),
                          ),
                        )
                      : (text.isNotEmpty ? Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: darkGray.withOpacity(0.7), borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.2))), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, color: starWhite, height: 1.7))) : const SizedBox.shrink()),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ]),
          ),
        ],
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
