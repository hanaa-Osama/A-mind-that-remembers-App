import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class MemoryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const MemoryDetailsPage({required this.data, super.key});

  @override
  State<MemoryDetailsPage> createState() => _MemoryDetailsPageState();
}

class _MemoryDetailsPageState extends State<MemoryDetailsPage> {
  VideoPlayerController? vid;
  final player = AudioPlayer();

  static const Color powderPink = Color(0xFFF4C2C2);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color purplePink = Color(0xFFC48BCB);

  @override
  void initState() {
    super.initState();

    if (widget.data["video"] != null) {
      vid = VideoPlayerController.file(File(widget.data["video"]))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    vid?.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.data["image"] != null;
    final hasVideo = widget.data["video"] != null;
    final hasAudio = widget.data["audio"] != null;

    return Scaffold(
      backgroundColor: powderPink,
      appBar: AppBar(
        title: Text(
          widget.data["title"],
          style: const TextStyle(
            fontFamily: 'Tajawal',
            color: purplePink,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: powderPink,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "📅 التاريخ: ${widget.data["date"]}",
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),
            const Text(
              "📝 الذكرى:",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: purplePink,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: warmBeige,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: roseGold),
              ),
              child: Text(
                widget.data["text"],
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(widget.data["image"])),
              ),
            if (hasVideo && vid != null)
              Column(
                children: [
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: vid!.value.aspectRatio,
                      child: VideoPlayer(vid!),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      vid!.value.isPlaying ? vid!.pause() : vid!.play();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roseGold,
                    ),
                    child: Text(
                      vid!.value.isPlaying
                          ? "إيقاف الفيديو"
                          : "تشغيل الفيديو",
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            if (hasAudio)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "🎤 تسجيل صوتي مرفق",
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      color: purplePink,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await player.setFilePath(widget.data["audio"]);
                      player.play();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: roseGold,
                    ),
                    child: const Text(
                      "تشغيل الصوت",
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
