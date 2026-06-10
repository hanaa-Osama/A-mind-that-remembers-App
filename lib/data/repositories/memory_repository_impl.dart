import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/memory.dart';
import '../../domain/models/media_item.dart';
import '../../domain/repositories/memory_repository.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  static const String _memoriesKey = 'memories';
  static const String _standaloneKey = 'standalone_media';

  @override
  Future<List<Memory>> getMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? memoriesJson = prefs.getString(_memoriesKey);
    if (memoriesJson == null || memoriesJson.isEmpty) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(memoriesJson);
      return decoded.map((item) => Memory.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveMemory(Memory memory) async {
    final memories = await getMemories();
    memories.add(memory);
    await _saveMemoriesToPrefs(memories);
  }

  @override
  Future<void> deleteMemory(String id) async {
    final memories = await getMemories();
    memories.removeWhere((m) => m.id == id);
    await _saveMemoriesToPrefs(memories);
  }

  @override
  Future<void> updateMemory(Memory memory) async {
    final memories = await getMemories();
    final index = memories.indexWhere((m) => m.id == memory.id);
    if (index != -1) {
      memories[index] = memory;
      await _saveMemoriesToPrefs(memories);
    }
  }

  Future<void> _saveMemoriesToPrefs(List<Memory> memories) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(memories.map((m) => m.toJson()).toList());
    await prefs.setString(_memoriesKey, encoded);
  }

  @override
  Future<List<MediaItem>> getAllMedia() async {
    final List<MediaItem> allMedia = [];
    final memories = await getMemories();
    
    for (var memory in memories) {
      for (var page in memory.pages) {
        if (page.image != null && File(page.image!).existsSync()) {
          allMedia.add(MediaItem(
            id: 'mem_${memory.id}_img',
            path: page.image!,
            type: MediaType.image,
            memoryId: memory.id,
            memoryTitle: memory.title,
            createdAt: memory.createdAt,
            isStandalone: false,
          ));
        }
        if (page.video != null && File(page.video!).existsSync()) {
          allMedia.add(MediaItem(
            id: 'mem_${memory.id}_vid',
            path: page.video!,
            type: MediaType.video,
            memoryId: memory.id,
            memoryTitle: memory.title,
            createdAt: memory.createdAt,
            isStandalone: false,
          ));
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final standaloneJson = prefs.getString(_standaloneKey);
    if (standaloneJson != null && standaloneJson.isNotEmpty) {
      final List<dynamic> standaloneList = jsonDecode(standaloneJson);
      for (var item in standaloneList) {
        final path = item['path']?.toString();
        if (path != null && File(path).existsSync()) {
          allMedia.add(MediaItem(
            id: item['id']?.toString() ?? path,
            path: path,
            type: item['type'] == 'video' ? MediaType.video : MediaType.image,
            createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
            isStandalone: true,
            standaloneId: item['id']?.toString(),
          ));
        }
      }
    }

    allMedia.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allMedia;
  }

  @override
  Future<void> addStandaloneMedia(String path, MediaType type) async {
    final prefs = await SharedPreferences.getInstance();
    final mediaId = DateTime.now().millisecondsSinceEpoch.toString();
    final standaloneData = {
      'id': mediaId,
      'type': type == MediaType.video ? 'video' : 'image',
      'path': path,
      'createdAt': DateTime.now().toIso8601String()
    };
    
    List<dynamic> standaloneList = [];
    final standaloneJson = prefs.getString(_standaloneKey);
    if (standaloneJson != null && standaloneJson.isNotEmpty) {
      standaloneList = jsonDecode(standaloneJson);
    }
    
    standaloneList.add(standaloneData);
    await prefs.setString(_standaloneKey, jsonEncode(standaloneList));
  }

  @override
  Future<void> deleteStandaloneMedia(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final standaloneJson = prefs.getString(_standaloneKey);
    if (standaloneJson != null && standaloneJson.isNotEmpty) {
      List<dynamic> standaloneList = jsonDecode(standaloneJson);
      standaloneList.removeWhere((item) => item['path'] == path);
      await prefs.setString(_standaloneKey, jsonEncode(standaloneList));
    }
  }

  @override
  Future<void> addMediaToMemory(String memoryId, String path, MediaType type) async {
    final memories = await getMemories();
    final index = memories.indexWhere((m) => m.id == memoryId);
    
    if (index != -1) {
      final memory = memories[index];
      if (memory.pages.isNotEmpty) {
        final updatedPages = List<MemoryPageData>.from(memory.pages);
        final firstPage = updatedPages[0];
        
        updatedPages[0] = MemoryPageData(
          text: firstPage.text,
          image: type == MediaType.image ? path : firstPage.image,
          video: type == MediaType.video ? path : firstPage.video,
        );
        
        final updatedMemory = Memory(
          id: memory.id,
          title: memory.title,
          createdAt: memory.createdAt,
          isJournal: memory.isJournal,
          isFavorite: memory.isFavorite,
          pages: updatedPages,
        );
        
        memories[index] = updatedMemory;
        await _saveMemoriesToPrefs(memories);
      }
    }
  }
}
