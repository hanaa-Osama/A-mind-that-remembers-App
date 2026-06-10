import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:lahzet_zikry/translations.dart';
import 'domain/models/media_item.dart';
import 'domain/models/memory.dart';
import 'domain/repositories/memory_repository.dart';
import 'data/repositories/memory_repository_impl.dart';
import 'presentation/memory_studio/memory_studio_presenter.dart';

const Color spaceBlack = Color(0xFF0A0A0F);
const Color darkGray = Color(0xFF1A1A1F);
const Color mediumGray = Color(0xFF2A2A2F);
const Color lightGray = Color(0xFF4A4A4F);
const Color starWhite = Color(0xFFE8E8E8);

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> with TickerProviderStateMixin implements MemoryStudioView {
  late MemoryStudioPresenter _presenter;
  List<MediaItem> _mediaItems = [];
  bool _showGrid = true;
  bool _isLoading = false;
  
  late AnimationController _starsController;
  late AnimationController _shootingStarController;
  
  final List<Map<String, dynamic>> _stars = [];
  final List<Map<String, dynamic>> _shootingStars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _presenter = MemoryStudioPresenter(MemoryRepositoryImpl(), this);
    _initAnimations();
    _generateStars();
    _generateShootingStars();
    _presenter.loadAllMedia();
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
    super.dispose();
  }

  // MVP View Implementation
  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void displayMedia(List<MediaItem> media) => setState(() => _mediaItems = media);

  @override
  void displayMemories(List<Memory> memories) {
    // This will be used in the add to memory dialog
  }

  @override
  void showMessage(String message) => _snack(message);

  @override
  void onMediaAdded() => _snack(S.of(context, 'save_success'));

  Future<void> _addNewMedia() async {
    final result = await showModalBottomSheet<MediaType>(
      context: context,
      backgroundColor: darkGray,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(S.of(context, 'add_new_media'), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.bold, color: starWhite)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(Icons.image, S.of(context, 'image'), () => Navigator.pop(ctx, MediaType.image)),
                _buildMediaOption(Icons.videocam, S.of(context, 'video'), () => Navigator.pop(ctx, MediaType.video)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    if (result != null) await _presenter.pickAndSaveMedia(result);
  }

  Widget _buildMediaOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(color: spaceBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.3))),
        child: Column(children: [Icon(icon, color: starWhite, size: 32), const SizedBox(height: 8), Text(label, style: const TextStyle(fontFamily: 'Tajawal', color: starWhite, fontSize: 14))]),
      ),
    );
  }

  void _openMediaViewer(MediaItem media) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => MediaViewerPage(
      media: media, 
      presenter: _presenter,
    )));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), backgroundColor: darkGray, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spaceBlack,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [spaceBlack, darkGray, mediumGray, spaceBlack], stops: [0.0, 0.3, 0.7, 1.0]))),
          AnimatedBuilder(animation: _starsController, builder: (context, child) => CustomPaint(painter: StarsPainter(_stars, _starsController.value), size: Size.infinite)),
          AnimatedBuilder(animation: _shootingStarController, builder: (context, child) => CustomPaint(painter: ShootingStarsPainter(_shootingStars, _shootingStarController.value), size: Size.infinite)),
          SafeArea(child: Column(children: [_buildHeader(), _buildViewToggle(), Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator(color: starWhite)) : (_mediaItems.isEmpty ? _buildEmptyState() : (_showGrid ? _buildMediaGrid() : _buildMediaList())))])),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addNewMedia, backgroundColor: starWhite, child: const Icon(Icons.add, color: spaceBlack, size: 28)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 22), 
          Text(S.of(context, 'studio'), style: const TextStyle(color: starWhite, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          GestureDetector(onTap: () => _presenter.loadAllMedia(), child: Icon(Icons.refresh, color: starWhite.withOpacity(0.7), size: 22)),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showGrid = true),
            child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _showGrid ? lightGray : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.grid_view, color: _showGrid ? starWhite : lightGray, size: 22)),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _showGrid = false),
            child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: !_showGrid ? lightGray : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.view_agenda, color: !_showGrid ? starWhite : lightGray, size: 22)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(shape: BoxShape.circle, color: lightGray.withOpacity(0.2)), child: Icon(Icons.photo_library_outlined, size: 60, color: starWhite.withOpacity(0.4))),
          const SizedBox(height: 20),
          Text(S.of(context, 'no_media'), style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, color: starWhite.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text(S.of(context, 'press_to_add'), style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: starWhite.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return RefreshIndicator(
      onRefresh: () => _presenter.loadAllMedia(),
      color: starWhite,
      backgroundColor: darkGray,
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemCount: _mediaItems.length,
        itemBuilder: (ctx, index) => _buildGridItem(_mediaItems[index]),
      ),
    );
  }

  Widget _buildGridItem(MediaItem media) {
    final isVideo = media.type == MediaType.video;
    return GestureDetector(
      onTap: () => _openMediaViewer(media),
      child: Stack(
        fit: StackFit.expand,
        children: [
          isVideo ? Container(color: darkGray, child: const Center(child: Icon(Icons.videocam, color: lightGray, size: 32))) : Image.file(File(media.path), fit: BoxFit.cover, errorBuilder: (ctx, e, s) => Container(color: darkGray, child: const Icon(Icons.broken_image, color: lightGray))),
          if (isVideo) Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 16))),
        ],
      ),
    );
  }

  Widget _buildMediaList() {
    return RefreshIndicator(
      onRefresh: () => _presenter.loadAllMedia(),
      color: starWhite,
      backgroundColor: darkGray,
      child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _mediaItems.length, itemBuilder: (ctx, index) => _buildListItem(_mediaItems[index])),
    );
  }

  Widget _buildListItem(MediaItem media) {
    final isVideo = media.type == MediaType.video;
    final title = media.memoryTitle ?? '';
    final createdAt = media.createdAt;
    
    return GestureDetector(
      onTap: () => _openMediaViewer(media),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: darkGray.withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: isVideo ? Container(height: 200, color: darkGray, child: const Center(child: Icon(Icons.videocam, color: lightGray, size: 48))) : Image.file(File(media.path), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, e, s) => Container(height: 200, color: darkGray, child: const Icon(Icons.broken_image, color: lightGray)))),
                if (isVideo) Positioned.fill(child: Center(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 32)))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${createdAt.day}/${createdAt.month}/${createdAt.year}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: starWhite.withOpacity(0.5))),
                if (title.isNotEmpty) Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: starWhite)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaViewerPage extends StatefulWidget {
  final MediaItem media;
  final MemoryStudioPresenter presenter;
  const MediaViewerPage({super.key, required this.media, required this.presenter});
  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> implements MemoryStudioView {
  VideoPlayerController? _videoController;
  List<Memory> _memories = [];

  @override
  void initState() {
    super.initState();
    if (widget.media.type == MediaType.video) {
      _videoController = VideoPlayerController.file(File(widget.media.path))..initialize().then((_) => setState(() {}));
    }
    widget.presenter.loadMemories();
  }

  // MVP View Implementation for Viewer
  @override void showLoading() {}
  @override void hideLoading() {}
  @override void displayMedia(List<MediaItem> media) {}
  @override void displayMemories(List<Memory> memories) => setState(() => _memories = memories);
  @override void showMessage(String message) => _snack(message);
  @override void onMediaAdded() {}

  Future<void> _addToMemory() async {
    if (_memories.isEmpty) {
      _snack(S.of(context, 'no_memories_available'));
      return;
    }

    final selectedMemory = await showModalBottomSheet<Memory>(
      context: context,
      backgroundColor: darkGray,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(S.of(context, 'select_memory'), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.bold, color: starWhite)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _memories.length,
                itemBuilder: (ctx, index) {
                  final memory = _memories[index];
                  final title = memory.title;
                  final createdAt = memory.createdAt;
                  final dateStr = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
                  
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx, memory),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: spaceBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGray.withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateStr, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: starWhite.withOpacity(0.5))),
                          Expanded(child: Text(title.isNotEmpty ? title : S.of(context, 'no_title'), textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: starWhite))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedMemory != null) {
      await widget.presenter.addMediaToMemory(widget.media, selectedMemory.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal')), backgroundColor: darkGray, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(S.of(context, 'delete'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 20)),
        content: Text(S.of(context, 'confirm_delete_file'), textAlign: TextAlign.center, style: const TextStyle(color: starWhite, fontSize: 16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context, 'cancel'), style: const TextStyle(color: lightGray))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(S.of(context, 'delete'), style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.presenter.deleteMedia(widget.media);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.media.type == MediaType.video;
    final title = widget.media.memoryTitle ?? '';
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: starWhite), onPressed: () => Navigator.pop(context)),
        title: Text(title.isNotEmpty ? title : (isVideo ? S.of(context, 'video') : S.of(context, 'image')), style: const TextStyle(fontFamily: 'Tajawal', color: starWhite)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add_photo_alternate_outlined, color: starWhite), onPressed: _addToMemory),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _confirmDelete),
        ],
      ),
      body: Center(
        child: isVideo
          ? (_videoController != null && _videoController!.value.isInitialized
            ? GestureDetector(
                onTap: () => setState(() { if (_videoController!.value.isPlaying) _videoController!.pause(); else _videoController!.play(); }),
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),
                  if (!_videoController!.value.isPlaying) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 48)),
                ]),
              )
            : const CircularProgressIndicator(color: starWhite))
          : InteractiveViewer(child: Image.file(File(widget.media.path), fit: BoxFit.contain, errorBuilder: (ctx, e, s) => const Icon(Icons.broken_image, color: lightGray, size: 64))),
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  final List<Map<String, dynamic>> stars;
  final double animationValue;
  StarsPainter(this.stars, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final twinkle = sin(animationValue * 2 * pi * (star['twinkleSpeed'] as double));
      final opacity = ((star['opacity'] as double) * (0.5 + 0.5 * twinkle)).clamp(0.1, 1.0);
      final paint = Paint()..color = starWhite.withOpacity(opacity)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(star['x'] * size.width, star['y'] * size.height), star['size'] as double, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShootingStarsPainter extends CustomPainter {
  final List<Map<String, dynamic>> shootingStars;
  final double animationValue;
  ShootingStarsPainter(this.shootingStars, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in shootingStars) {
      final delay = star['delay'] as double;
      final speed = star['speed'] as double;
      final progress = ((animationValue * speed + delay) % 1.0);
      if (progress < 0.3) {
        final startX = (star['startX'] as double) * size.width;
        final startY = (star['startY'] as double) * size.height;
        final length = (star['length'] as double) * size.width;
        final currentX = startX + progress * length * 3;
        final currentY = startY + progress * length * 3;
        final opacity = (1 - progress / 0.3).clamp(0.0, 1.0);
        final paint = Paint()..shader = LinearGradient(colors: [Colors.white.withOpacity(opacity), Colors.white.withOpacity(0)]).createShader(Rect.fromPoints(Offset(currentX, currentY), Offset(currentX - length * 0.5, currentY - length * 0.5)));
        canvas.drawLine(Offset(currentX, currentY), Offset(currentX - length * 0.5, currentY - length * 0.5), paint..strokeWidth = 2);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
