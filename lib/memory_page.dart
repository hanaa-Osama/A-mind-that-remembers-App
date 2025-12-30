import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  final titleController = TextEditingController();
  final textController = TextEditingController();
  final picker = ImagePicker();

  final recorder = FlutterSoundRecorder();
  final audioPlayer = AudioPlayer();

  bool recorderReady = false;
  bool isRecording = false;

  File? selectedVideo;
  String? audioPath;

  VideoPlayerController? previewController;

  List<Map<String, dynamic>> memories = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadMemories();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    previewController?.dispose();
    titleController.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await recorder.openRecorder();
    recorderReady = true;
  }

  Future<void> _loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('memories') ?? [];

    memories = raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();

    setState(() {});
  }

  Future<void> _saveMemory() async {
    if (titleController.text.trim().isEmpty &&
        textController.text.trim().isEmpty &&
        selectedVideo == null &&
        audioPath == null) {
      _snack("أضف محتوى للذكرى أولًا");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final memory = {
      "id": now.millisecondsSinceEpoch,
      "title": titleController.text.trim(),
      "text": textController.text.trim(),
      "video": selectedVideo?.path,
      "audio": audioPath,
      "createdAt": now.toIso8601String(),
    };

    final list = prefs.getStringList('memories') ?? [];
    list.add(jsonEncode(memory));
    await prefs.setStringList('memories', list);

    titleController.clear();
    textController.clear();
    selectedVideo = null;
    audioPath = null;
    previewController?.dispose();
    previewController = null;

    await _loadMemories();
    _snack("تم حفظ الذكرى بنجاح 🌸");
  }

  Future<void> _toggleRecord() async {
    if (!recorderReady) return;

    if (!isRecording) {
      final path =
          "${Directory.systemTemp.path}/memory_${DateTime.now().millisecondsSinceEpoch}.aac";
      await recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      audioPath = path;
      setState(() => isRecording = true);
    } else {
      await recorder.stopRecorder();
      setState(() => isRecording = false);
    }
  }

  Future<void> _pickVideo() async {
    await Permission.camera.request();
    await Permission.microphone.request();

    final XFile? x = await picker.pickVideo(source: ImageSource.camera);
    if (x == null) return;

    final file = File(x.path);
    previewController?.dispose();
    previewController = VideoPlayerController.file(file);
    await previewController!.initialize();

    setState(() => selectedVideo = file);
  }

  void _openHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: warmBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final m = memories[index];
                final date = DateFormat(
                  'EEEE d MMMM yyyy – hh:mm a',
                  'ar',
                ).format(DateTime.parse(m['createdAt']));

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    onTap: () => _openDetails(m, index),
                    title: Text(
                      "📝 ${m['title'].isEmpty ? "ذكرى بدون عنوان" : m['title']}",
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      "📅 $date",
                      textAlign: TextAlign.right,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.red),
                      onPressed: () async {
                        memories.removeAt(index);

                        final prefs =
                        await SharedPreferences.getInstance();
                        await prefs.setStringList(
                          'memories',
                          memories
                              .reversed
                              .map((e) => jsonEncode(e))
                              .toList(),
                        );

                        setModalState(() {});
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

  void _openDetails(Map<String, dynamic> m, int index) {
    VideoPlayerController? detailsVideoController;
    if (m['video'] != null) {
      detailsVideoController =
      VideoPlayerController.file(File(m['video']))
        ..initialize();
    }

    showDialog(
      context: context,
      builder: (_) {
        final date = DateFormat(
          'EEEE d MMMM yyyy – hh:mm a',
          'ar',
        ).format(DateTime.parse(m['createdAt']));

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "📝 ${m['title']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("📅 $date"),
                const Divider(),
                if (m['text'] != null &&
                    m['text'].toString().isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "✍️ ${m['text']}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () async {
                          m['text'] = "";
                          _updateMemory();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                if (m['audio'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await audioPlayer
                                .setFilePath(m['audio']);
                            audioPlayer.play();
                          },
                          icon:
                          const Icon(Icons.play_arrow),
                          label:
                          const Text("🎙️ تشغيل الصوت"),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () async {
                          m['audio'] = null;
                          _updateMemory();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ],
                if (m['video'] != null &&
                    detailsVideoController != null) ...[
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: detailsVideoController
                        .value.aspectRatio,
                    child:
                    VideoPlayer(detailsVideoController),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () async {
                        m['video'] = null;
                        _updateMemory();
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            )
          ],
        );
      },
    );
  }

  Future<void> _updateMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'memories',
      memories.reversed.map((e) => jsonEncode(e)).toList(),
    );
    setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        backgroundColor: powderPink,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "💗 ذِكرى لا أنساها",
          style: TextStyle(
              color: purplePink,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _field(titleController, "📝 عنوان الذكرى"),
            const SizedBox(height: 12),
            _field(
              textController,
              "✨ دوّن ما لا يُنسى…",
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _toggleRecord,
              icon:
              Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording
                  ? "إيقاف التسجيل"
                  : "🎙️ تسجيل صوتي"),
            ),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: const Text("🎥 تصوير فيديو"),
            ),
            if (previewController != null)
              AspectRatio(
                aspectRatio:
                previewController!.value.aspectRatio,
                child:
                VideoPlayer(previewController!),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveMemory,
              style: ElevatedButton.styleFrom(
                  backgroundColor: roseGold),
              child: const Text("💾 حفظ الذكرى"),
            ),
            OutlinedButton.icon(
              onPressed: _openHistory,
              icon: const Icon(Icons.folder_open),
              label: const Text("📚 سجل الذكريات"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: warmBeige,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
