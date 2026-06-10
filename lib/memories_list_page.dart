import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lahzet_zikry/translations.dart';

// Import Clean Architecture layers
import 'domain/models/memory.dart';
import 'data/repositories/memory_repository_impl.dart';
import 'presentation/memories_list/memories_list_presenter.dart';

const Color spaceBlack = Color(0xFF0A0A0F);
const Color darkGray = Color(0xFF1A1A1F);
const Color lightGray = Color(0xFF4A4A4F);
const Color starWhite = Color(0xFFE8E8E8);
const Color textFieldGray = Color(0xFFE0E0E0);

class MemoriesListPage extends StatelessWidget {
  const MemoriesListPage({super.key});
  @override
  Widget build(BuildContext context) => const MemoriesListContent();
}

class MemoriesListContent extends StatefulWidget {
  final Function(Memory)? onMemorySelected;
  const MemoriesListContent({super.key, this.onMemorySelected});
  @override
  State<MemoriesListContent> createState() => _MemoriesListContentState();
}

class _MemoriesListContentState extends State<MemoriesListContent> implements MemoriesListContract {
  late MemoriesListPresenter _presenter;
  List<Memory> _memories = [];
  String _filterType = 'all';
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Dependency Injection (Manual for simplicity)
    _presenter = MemoriesListPresenter(MemoryRepositoryImpl(), this);
    _loadData();
  }

  void _loadData() {
    _presenter.loadMemories(
      filter: _filterType == 'all' ? 'All' : (_filterType == 'journal' ? 'My Journal' : 'Favorites'),
      searchQuery: searchController.text,
    );
  }

  @override
  void showMemories(List<Memory> memories) {
    if (mounted) setState(() => _memories = memories);
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: starWhite))
            : (_memories.isEmpty ? _buildEmptyState() : _buildMemoriesList()),
        ),
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
          onChanged: (_) => _loadData(),
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
      onTap: () {
        setState(() => _filterType = type);
        _loadData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? lightGray : spaceBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? starWhite.withOpacity(0.3) : lightGray.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? starWhite : starWhite.withOpacity(0.7))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories_outlined, size: 48, color: lightGray),
          const SizedBox(height: 16),
          Text(S.of(context, 'no_memories'), style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, color: starWhite.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildMemoriesList() {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: starWhite,
      backgroundColor: darkGray,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _memories.length,
        itemBuilder: (context, index) => _buildMemoryCard(_memories[index]),
      ),
    );
  }

  Widget _buildMemoryCard(Memory memory) {
    final hasMedia = memory.pages.any((p) => p.image != null || p.video != null);
    final preview = memory.pages.isNotEmpty ? memory.pages[0].text : '';
    
    return GestureDetector(
      onTap: () {
        if (widget.onMemorySelected != null) widget.onMemorySelected!(memory);
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => MemoryDetailPage(memory: memory, onUpdate: _loadData))).then((_) => _loadData());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: spaceBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              GestureDetector(
                onTap: () => _showDeleteDialog(memory),
                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.delete_outline, size: 16, color: Colors.red)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _presenter.toggleFavorite(memory),
                child: Icon(memory.isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: memory.isFavorite ? Colors.red : starWhite.withOpacity(0.5)),
              ),
              const SizedBox(width: 8),
              if (hasMedia) Icon(Icons.photo, size: 12, color: starWhite.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text('${memory.createdAt.day}/${memory.createdAt.month}/${memory.createdAt.year}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, color: starWhite.withOpacity(0.5))),
            ]),
            Flexible(child: Text(memory.title.isNotEmpty ? memory.title : S.of(context, 'untitled'), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.bold, color: memory.title.isNotEmpty ? starWhite : starWhite.withOpacity(0.5)))),
          ]),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(preview.length > 60 ? '${preview.substring(0, 60)}...' : preview, textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: starWhite.withOpacity(0.6))),
          ],
        ]),
      ),
    );
  }

  void _showDeleteDialog(Memory memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(S.of(context, 'confirm_delete'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 20)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context, 'cancel'), style: const TextStyle(color: lightGray))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400), child: Text(S.of(context, 'delete'), style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
      await MemoryRepositoryImpl().deleteMemory(memory.id);
      _loadData();
    }
  }
}

class MemoryDetailPage extends StatefulWidget {
  final Memory memory;
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
  late Memory _currentMemory;

  @override
  void initState() {
    super.initState();
    _currentMemory = widget.memory;
    _starsController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _generateStars();
    _initVideo();
    _titleController = TextEditingController(text: _currentMemory.title);
    _textController = TextEditingController(text: _currentMemory.pages.isNotEmpty ? _currentMemory.pages[0].text : '');
  }

  void _generateStars() {
    for (int i = 0; i < 80; i++) {
      _stars.add({'x': _random.nextDouble(), 'y': _random.nextDouble(), 'size': _random.nextDouble() * 2 + 0.5, 'opacity': _random.nextDouble() * 0.5 + 0.3, 'twinkleSpeed': _random.nextDouble() * 0.5 + 0.5});
    }
  }

  void _initVideo() {
    if (_currentMemory.pages.isNotEmpty && _currentMemory.pages[0].video != null) {
      final videoPath = _currentMemory.pages[0].video!;
      if (File(videoPath).existsSync()) {
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
    final updated = Memory(
      id: _currentMemory.id,
      title: _titleController.text.trim(),
      createdAt: _currentMemory.createdAt,
      isJournal: _currentMemory.isJournal,
      isFavorite: _currentMemory.isFavorite,
      pages: [
        MemoryPageData(
          text: _textController.text.trim(),
          image: _currentMemory.pages.isNotEmpty ? _currentMemory.pages[0].image : null,
          video: _currentMemory.pages.isNotEmpty ? _currentMemory.pages[0].video : null,
        )
      ],
    );
    
    await MemoryRepositoryImpl().updateMemory(updated);
    setState(() {
      _currentMemory = updated;
      _isEditing = false;
    });
    widget.onUpdate?.call();
  }

  @override
  Widget build(BuildContext context) {
    String? imagePath = _currentMemory.pages.isNotEmpty ? _currentMemory.pages[0].image : null;
    String? videoPath = _currentMemory.pages.isNotEmpty ? _currentMemory.pages[0].video : null;

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
                            decoration: InputDecoration(hintText: S.of(context, 'title_hint'), border: InputBorder.none),
                          ),
                        )
                      : Text(_currentMemory.title.isNotEmpty ? _currentMemory.title : S.of(context, 'memory'), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.bold, color: starWhite)),
                  ),
                  _isEditing
                    ? GestureDetector(onTap: _saveChanges, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.8), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.check, color: starWhite, size: 18)))
                    : GestureDetector(onTap: () => setState(() => _isEditing = true), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: darkGray, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.edit, color: starWhite, size: 18))),
                ]),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${_currentMemory.createdAt.day}/${_currentMemory.createdAt.month}/${_currentMemory.createdAt.year}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: starWhite.withOpacity(0.5)))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    if (imagePath != null && File(imagePath).existsSync()) Container(margin: const EdgeInsets.only(bottom: 16), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath)))),
                    if (videoPath != null && _videoController != null && _videoController!.value.isInitialized) Container(margin: const EdgeInsets.only(bottom: 16), child: Stack(alignment: Alignment.center, children: [AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)), GestureDetector(onTap: () => setState(() { _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play(); }), child: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: starWhite, size: 48))])),
                    _isEditing 
                      ? TextField(controller: _textController, maxLines: null, style: const TextStyle(color: starWhite), decoration: InputDecoration(filled: true, fillColor: darkGray.withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))
                      : Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: darkGray.withOpacity(0.7), borderRadius: BorderRadius.circular(12)), child: Text(_currentMemory.pages.isNotEmpty ? _currentMemory.pages[0].text : '', textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 15, height: 1.7))),
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
      final paint = Paint()..color = starWhite.withOpacity(opacity.clamp(0.1, 1.0));
      canvas.drawCircle(Offset(star['x'] * size.width, star['y'] * size.height), star['size'] as double, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
