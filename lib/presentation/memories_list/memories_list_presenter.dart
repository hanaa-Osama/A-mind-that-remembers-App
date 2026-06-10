import '../../domain/models/memory.dart';
import '../../domain/repositories/memory_repository.dart';

abstract class MemoriesListContract {
  void showMemories(List<Memory> memories);
  void showLoading();
  void hideLoading();
}

class MemoriesListPresenter {
  final MemoryRepository _repository;
  final MemoriesListContract _view;

  MemoriesListPresenter(this._repository, this._view);

  void loadMemories({String filter = 'All', String searchQuery = ''}) async {
    _view.showLoading();
    try {
      var memories = await _repository.getMemories();
      
      // تطبيق الفلترة
      if (filter == 'My Journal') {
        memories = memories.where((m) => m.isJournal).toList();
      } else if (filter == 'Favorites') {
        memories = memories.where((m) => m.isFavorite).toList();
      }

      // تطبيق البحث
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        memories = memories.where((m) {
          final titleMatch = m.title.toLowerCase().contains(query);
          final textMatch = m.pages.any((p) => p.text.toLowerCase().contains(query));
          return titleMatch || textMatch;
        }).toList();
      }

      memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _view.showMemories(memories);
    } catch (e) {
      // التعامل مع الخطأ
    } finally {
      _view.hideLoading();
    }
  }

  void toggleFavorite(Memory memory) async {
    final updated = Memory(
      id: memory.id,
      title: memory.title,
      createdAt: memory.createdAt,
      isJournal: memory.isJournal,
      isFavorite: !memory.isFavorite,
      pages: memory.pages,
    );
    await _repository.updateMemory(updated);
    // Reload with current settings would be better, but we don't store them here.
    // The view will likely call loadMemories again or we can just reload all.
    loadMemories();
  }
}
