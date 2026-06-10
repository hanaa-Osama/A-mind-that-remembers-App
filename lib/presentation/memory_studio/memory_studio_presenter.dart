import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/media_item.dart';
import '../../domain/models/memory.dart';
import '../../domain/repositories/memory_repository.dart';

abstract class MemoryStudioView {
  void showLoading();
  void hideLoading();
  void displayMedia(List<MediaItem> media);
  void displayMemories(List<Memory> memories);
  void showMessage(String message);
  void onMediaAdded();
}

class MemoryStudioPresenter {
  final MemoryRepository repository;
  final MemoryStudioView view;
  final ImagePicker _picker = ImagePicker();

  MemoryStudioPresenter(this.repository, this.view);

  Future<void> loadAllMedia() async {
    view.showLoading();
    try {
      final media = await repository.getAllMedia();
      view.displayMedia(media);
    } catch (e) {
      view.showMessage('Error loading media');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> loadMemories() async {
    try {
      final memories = await repository.getMemories();
      view.displayMemories(memories);
    } catch (e) {
      view.showMessage('Error loading memories');
    }
  }

  Future<void> pickAndSaveMedia(MediaType type) async {
    try {
      XFile? file;
      if (type == MediaType.image) {
        file = await _picker.pickImage(source: ImageSource.gallery);
      } else {
        file = await _picker.pickVideo(source: ImageSource.gallery);
      }

      if (file != null) {
        final dir = await getApplicationDocumentsDirectory();
        final mediaId = DateTime.now().millisecondsSinceEpoch.toString();
        final mediaDir = Directory('${dir.path}/standalone_media/$mediaId');
        await mediaDir.create(recursive: true);

        String savedPath = type == MediaType.image 
            ? '${mediaDir.path}/image_$mediaId.jpg' 
            : '${mediaDir.path}/video_$mediaId.mp4';
        
        await File(file.path).copy(savedPath);
        await repository.addStandaloneMedia(savedPath, type);
        
        view.onMediaAdded();
        await loadAllMedia();
      }
    } catch (e) {
      view.showMessage('Error picking media');
    }
  }

  Future<void> deleteMedia(MediaItem media) async {
    try {
      if (media.isStandalone) {
        await repository.deleteStandaloneMedia(media.path);
      } else if (media.memoryId != null) {
        final memories = await repository.getMemories();
        final index = memories.indexWhere((m) => m.id == media.memoryId);
        if (index != -1) {
          final memory = memories[index];
          final updatedPages = memory.pages.map((p) {
            return MemoryPageData(
              text: p.text,
              image: media.type == MediaType.image && p.image == media.path ? null : p.image,
              video: media.type == MediaType.video && p.video == media.path ? null : p.video,
            );
          }).where((p) => p.text.isNotEmpty || p.image != null || p.video != null).toList();

          if (updatedPages.isEmpty) {
            await repository.deleteMemory(memory.id);
          } else {
            final updatedMemory = Memory(
              id: memory.id,
              title: memory.title,
              createdAt: memory.createdAt,
              isJournal: memory.isJournal,
              isFavorite: memory.isFavorite,
              pages: updatedPages,
            );
            await repository.updateMemory(updatedMemory);
          }
        }
      }
      
      try {
        final file = File(media.path);
        if (file.existsSync()) await file.delete();
      } catch (e) {}

      await loadAllMedia();
    } catch (e) {
      view.showMessage('Error deleting media');
    }
  }

  Future<void> addMediaToMemory(MediaItem media, String memoryId) async {
    try {
      await repository.addMediaToMemory(memoryId, media.path, media.type);
      
      if (media.isStandalone) {
        await repository.deleteStandaloneMedia(media.path);
      }
      
      view.onMediaAdded();
      await loadAllMedia();
    } catch (e) {
      view.showMessage('Error adding to memory');
    }
  }
}
