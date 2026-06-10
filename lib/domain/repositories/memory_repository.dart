import '../models/memory.dart';
import '../models/media_item.dart';

abstract class MemoryRepository {
  Future<List<Memory>> getMemories();
  Future<void> saveMemory(Memory memory);
  Future<void> deleteMemory(String id);
  Future<void> updateMemory(Memory memory);
  
  // Media methods
  Future<List<MediaItem>> getAllMedia();
  Future<void> addStandaloneMedia(String path, MediaType type);
  Future<void> deleteStandaloneMedia(String path);
  Future<void> addMediaToMemory(String memoryId, String path, MediaType type);
}
